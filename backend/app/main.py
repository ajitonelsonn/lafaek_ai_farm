"""Lafaek AI Farm — online re-analysis service.

The phone does its own analysis first and saves it. This service is the
*enhancement*: when a farmer has a signal, the local result and the farm
context are sent here, and Claude Haiku is asked for a second opinion in
plain language.

Its only real job is to hold the Anthropic API key. The key never ships in the
APK; the phone talks to this service, and this service talks to Claude.

Endpoints:
    GET  /health             liveness, and whether a key is configured
    POST /api/v1/analyze     second opinion on a local scan result (no image)
    POST /api/v1/identify    the local model said "unknown" — Claude looks at
                             the photograph itself
    POST /api/v1/ask         a farming question the local library could not
                             answer well
"""
from __future__ import annotations

import json
import logging
import os
import time
from typing import Literal

import anthropic
from fastapi import FastAPI, Header, HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

log = logging.getLogger("lafaek")
logging.basicConfig(level=logging.INFO)

# Read at import so a missing key is obvious at boot rather than at first call.
ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "").strip()
APP_TOKEN = os.environ.get("LAFAEK_APP_TOKEN", "").strip()
MODEL = os.environ.get("CLAUDE_MODEL", "claude-haiku-4-5-20251001")
MAX_BODY_BYTES = 16 * 1024
# A 224-640 px JPEG is comfortably under this; the app downscales before sending.
MAX_IMAGE_BYTES = 1_500_000

app = FastAPI(
    title="Lafaek AI Farm — online re-analysis",
    version="1.0.0",
    docs_url="/docs",
)

client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY) if ANTHROPIC_API_KEY else None


# ---------------------------------------------------------------- models ----

class LocalResult(BaseModel):
    """What the on-device model already decided."""

    label: str = Field(..., max_length=80)
    confidence: float = Field(..., ge=0, le=1)
    margin: float = Field(0, ge=0, le=1)
    runner_up: str | None = Field(None, max_length=80)
    model_name: str = Field("", max_length=120)


class FarmContext(BaseModel):
    crop: str = Field(..., max_length=60)
    location: str = Field("", max_length=120)
    growth_stage: str = Field("", max_length=60)
    days_since_planting: int | None = Field(None, ge=0, le=2000)
    temperature_c: float | None = Field(None, ge=-20, le=60)
    humidity: int | None = Field(None, ge=0, le=100)
    rain_chance: int | None = Field(None, ge=0, le=100)
    soil_moisture: str = Field("", max_length=40)


class AnalyzeRequest(BaseModel):
    local: LocalResult
    farm: FarmContext
    language: Literal["en", "tet"] = "en"
    knowledge: str = Field("", max_length=4000)


class IdentifyRequest(BaseModel):
    """Sent only when the on-device model could not identify the crop."""

    image_base64: str = Field(..., max_length=2_200_000)
    mime_type: Literal['image/jpeg', 'image/png'] = 'image/jpeg'
    farm: FarmContext
    language: Literal['en', 'tet'] = 'en'
    local_label: str = Field('unknown', max_length=80)


class IdentifyResponse(BaseModel):
    provider: str = 'anthropic'
    model: str
    crop: str
    condition: str
    summary: str
    actions: list[str]
    confidence: Literal['high', 'moderate', 'low']
    ask_a_person: bool
    caveat: str
    elapsed_ms: int


class AskRequest(BaseModel):
    question: str = Field(..., max_length=1000)
    farm: FarmContext
    language: Literal['en', 'tet'] = 'en'
    knowledge: str = Field('', max_length=4000)


class AskResponse(BaseModel):
    provider: str = 'anthropic'
    model: str
    answer: str
    actions: list[str]
    ask_a_person: bool
    elapsed_ms: int


class AnalyzeResponse(BaseModel):
    provider: str = "anthropic"
    model: str
    summary: str
    confirms_local: bool
    actions: list[str]
    ask_a_person: bool
    caveat: str
    elapsed_ms: int


# ------------------------------------------------------------- prompting ----

SYSTEM = """You are an agricultural advisor for smallholder farmers in \
Timor-Leste. A small on-device model has already analysed a leaf photo and \
produced a result. You are giving a second opinion in plain language.

Rules you must follow:
- You cannot see the photo. Reason only from the label, the confidence, and \
the farm context given to you. Never describe the image.
- Never state a diagnosis as certain. Use "possible" and "likely".
- If the local confidence is below 0.6, or the margin over the runner-up is \
below 0.2, set ask_a_person to true and say the farmer should check with an \
agricultural extension officer.
- Never give pesticide dosages or product brand names. Cultural and physical \
controls first.
- Keep the summary under 60 words and each action under 20 words.
- Actions must be things a smallholder can actually do with hand tools.
- Reply with JSON only, no prose around it.

JSON shape:
{"summary": str, "confirms_local": bool, "actions": [str], \
"ask_a_person": bool, "caveat": str}"""


IDENTIFY_SYSTEM = """You are an agricultural advisor for smallholder farmers \
in Timor-Leste. A small on-device model looked at this leaf photograph and \
could not identify it, so you are being asked to look at the image yourself.

Rules you must follow:
- Identify the crop and the condition only if the image genuinely shows it. \
If the photo is blurred, too dark, not a plant, or shows a crop you cannot \
place, say so and set confidence to "low" and ask_a_person to true.
- Never state a diagnosis as certain. Use "possible" and "likely".
- Never give pesticide dosages or product brand names. Cultural and physical \
controls first.
- Keep the summary under 60 words and each action under 20 words.
- Actions must be things a smallholder can do with hand tools.
- Reply with JSON only.

JSON shape:
{"crop": str, "condition": str, "summary": str, "actions": [str], \
"confidence": "high"|"moderate"|"low", "ask_a_person": bool, "caveat": str}"""

ASK_SYSTEM = """You are a farming assistant for smallholder farmers in \
Timor-Leste. Answer the farmer's question directly and practically.

Rules you must follow:
- Answer for a smallholder with hand tools and little cash, in Timor-Leste's \
climate and growing seasons.
- Never give pesticide dosages or product brand names.
- If the question needs information you do not have — a diagnosis from a \
photo, a local price, a legal or medical matter — say so and set \
ask_a_person to true.
- Keep the answer under 120 words. Give at most 4 actions.
- Reply with JSON only.

JSON shape:
{"answer": str, "actions": [str], "ask_a_person": bool}"""

LANGUAGE_NOTE = {
    "en": "Write in clear, simple English.",
    "tet": (
        "Write in Tetun (Tetun Dili), the national language of Timor-Leste. "
        "Use farming words farmers use: batar (maize), hare (rice), to'os "
        "(field), moras (disease), rai (soil). Keep sentences short."
    ),
}


def build_prompt(req: AnalyzeRequest) -> str:
    f = req.farm
    lines = [
        f"On-device model: {req.local.model_name or 'unknown'}",
        f"Local label: {req.local.label}",
        f"Local confidence: {req.local.confidence:.2f}",
        f"Margin over runner-up: {req.local.margin:.2f}",
    ]
    if req.local.runner_up:
        lines.append(f"Runner-up label: {req.local.runner_up}")
    lines += [
        "",
        f"Crop: {f.crop}",
        f"Location: {f.location or 'Timor-Leste'}",
    ]
    if f.growth_stage:
        lines.append(f"Growth stage: {f.growth_stage}")
    if f.days_since_planting is not None:
        lines.append(f"Days since planting: {f.days_since_planting}")
    if f.temperature_c is not None:
        lines.append(f"Temperature: {f.temperature_c:.0f} C")
    if f.humidity is not None:
        lines.append(f"Humidity: {f.humidity}%")
    if f.rain_chance is not None:
        lines.append(f"Rain chance today: {f.rain_chance}%")
    if f.soil_moisture:
        lines.append(f"Soil moisture: {f.soil_moisture}")
    if req.knowledge:
        lines += ["", "Local knowledge article:", req.knowledge[:4000]]
    lines += ["", LANGUAGE_NOTE[req.language]]
    return "\n".join(lines)


def parse_reply(text: str) -> dict:
    """Pull the JSON object out of Claude's reply, tolerating stray prose."""
    text = text.strip()
    if text.startswith("```"):
        text = text.split("```")[1]
        if text.startswith("json"):
            text = text[4:]
    start, end = text.find("{"), text.rfind("}")
    if start == -1 or end == -1:
        raise ValueError("no JSON object in reply")
    return json.loads(text[start : end + 1])


# -------------------------------------------------------------- endpoints ---

@app.get("/health")
def health() -> dict:
    return {
        "status": "ok",
        "model": MODEL,
        "key_configured": client is not None,
        "auth_required": bool(APP_TOKEN),
    }


@app.post("/api/v1/analyze", response_model=AnalyzeResponse)
async def analyze(
    req: AnalyzeRequest,
    request: Request,
    x_app_token: str | None = Header(default=None),
) -> AnalyzeResponse:
    if APP_TOKEN and x_app_token != APP_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid app token")
    if client is None:
        raise HTTPException(
            status_code=503, detail="Online analysis is not configured"
        )

    body_len = int(request.headers.get("content-length") or 0)
    if body_len > MAX_BODY_BYTES:
        raise HTTPException(status_code=413, detail="Request too large")

    started = time.monotonic()
    try:
        message = client.messages.create(
            model=MODEL,
            max_tokens=700,
            temperature=0.3,
            system=SYSTEM,
            messages=[{"role": "user", "content": build_prompt(req)}],
        )
        data = parse_reply(message.content[0].text)
    except anthropic.APIStatusError as e:
        log.warning("claude error %s", e.status_code)
        raise HTTPException(status_code=502, detail="Upstream model error")
    except Exception as e:  # noqa: BLE001 - never leak internals to the phone
        log.exception("analyze failed")
        raise HTTPException(status_code=502, detail="Could not analyse") from e

    # The local margin guard decides this too; honour whichever is stricter,
    # so the online path can never be *less* cautious than the phone.
    unsure = req.local.confidence < 0.6 or req.local.margin < 0.2
    return AnalyzeResponse(
        model=MODEL,
        summary=str(data.get("summary", ""))[:600],
        confirms_local=bool(data.get("confirms_local", False)),
        actions=[str(a)[:200] for a in data.get("actions", [])][:6],
        ask_a_person=bool(data.get("ask_a_person", False)) or unsure,
        caveat=str(data.get("caveat", ""))[:300],
        elapsed_ms=int((time.monotonic() - started) * 1000),
    )


@app.post("/api/v1/identify", response_model=IdentifyResponse)
async def identify(
    req: IdentifyRequest,
    x_app_token: str | None = Header(default=None),
) -> IdentifyResponse:
    """Claude looks at the photograph, because the on-device model could not.

    This is the one path where an image leaves the phone. The app only calls
    it when the local model returned `unknown` or `other` *and* the connection
    measured fast, and the farmer is told before it happens.
    """
    if APP_TOKEN and x_app_token != APP_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid app token")
    if client is None:
        raise HTTPException(status_code=503,
                            detail="Online analysis is not configured")

    raw_len = len(req.image_base64) * 3 // 4
    if raw_len > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Image too large")

    f = req.farm
    context = [
        f"Crop the farmer recorded: {f.crop or 'not recorded'}",
        f"Location: {f.location or 'Timor-Leste'}",
    ]
    if f.growth_stage:
        context.append(f"Growth stage: {f.growth_stage}")
    if f.temperature_c is not None:
        context.append(f"Temperature: {f.temperature_c:.0f} C")
    if f.humidity is not None:
        context.append(f"Humidity: {f.humidity}%")
    if f.soil_moisture:
        context.append(f"Soil moisture: {f.soil_moisture}")
    context.append(f"The on-device model said: {req.local_label}")
    context.append(LANGUAGE_NOTE[req.language])

    started = time.monotonic()
    try:
        message = client.messages.create(
            model=MODEL,
            max_tokens=700,
            temperature=0.2,
            system=IDENTIFY_SYSTEM,
            messages=[{
                "role": "user",
                "content": [
                    {"type": "image", "source": {
                        "type": "base64",
                        "media_type": req.mime_type,
                        "data": req.image_base64,
                    }},
                    {"type": "text", "text": "\n".join(context)},
                ],
            }],
        )
        data = parse_reply(message.content[0].text)
    except anthropic.APIStatusError as e:
        log.warning("claude vision error %s", e.status_code)
        raise HTTPException(status_code=502, detail="Upstream model error")
    except Exception as e:  # noqa: BLE001
        log.exception("identify failed")
        raise HTTPException(status_code=502, detail="Could not analyse") from e

    confidence = str(data.get("confidence", "low")).lower()
    if confidence not in ("high", "moderate", "low"):
        confidence = "low"
    return IdentifyResponse(
        model=MODEL,
        crop=str(data.get("crop", "Unknown"))[:80],
        condition=str(data.get("condition", "Unclear"))[:120],
        summary=str(data.get("summary", ""))[:600],
        actions=[str(a)[:200] for a in data.get("actions", [])][:6],
        confidence=confidence,
        # Low confidence always routes to a person, whatever the model said.
        ask_a_person=bool(data.get("ask_a_person", False)) or confidence == "low",
        caveat=str(data.get("caveat", ""))[:300],
        elapsed_ms=int((time.monotonic() - started) * 1000),
    )


@app.post("/api/v1/ask", response_model=AskResponse)
async def ask(
    req: AskRequest,
    x_app_token: str | None = Header(default=None),
) -> AskResponse:
    """A farming question the on-device library could not answer well."""
    if APP_TOKEN and x_app_token != APP_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid app token")
    if client is None:
        raise HTTPException(status_code=503,
                            detail="Online analysis is not configured")

    f = req.farm
    parts = [f"Question: {req.question}", "",
             f"Crop: {f.crop or 'not recorded'}",
             f"Location: {f.location or 'Timor-Leste'}"]
    if f.temperature_c is not None:
        parts.append(f"Temperature: {f.temperature_c:.0f} C")
    if f.humidity is not None:
        parts.append(f"Humidity: {f.humidity}%")
    if f.soil_moisture:
        parts.append(f"Soil moisture: {f.soil_moisture}")
    if req.knowledge:
        parts += ["", "The phone's offline library had this, which may or may "
                      "not be relevant:", req.knowledge[:4000]]
    parts += ["", LANGUAGE_NOTE[req.language]]

    started = time.monotonic()
    try:
        message = client.messages.create(
            model=MODEL,
            max_tokens=700,
            temperature=0.3,
            system=ASK_SYSTEM,
            messages=[{"role": "user", "content": "\n".join(parts)}],
        )
        data = parse_reply(message.content[0].text)
    except anthropic.APIStatusError as e:
        log.warning("claude ask error %s", e.status_code)
        raise HTTPException(status_code=502, detail="Upstream model error")
    except Exception as e:  # noqa: BLE001
        log.exception("ask failed")
        raise HTTPException(status_code=502, detail="Could not answer") from e

    return AskResponse(
        model=MODEL,
        answer=str(data.get("answer", ""))[:1500],
        actions=[str(a)[:200] for a in data.get("actions", [])][:4],
        ask_a_person=bool(data.get("ask_a_person", False)),
        elapsed_ms=int((time.monotonic() - started) * 1000),
    )


@app.exception_handler(HTTPException)
async def http_error(_: Request, exc: HTTPException) -> JSONResponse:
    # The phone treats any failure the same way: keep the local result.
    return JSONResponse(
        status_code=exc.status_code, content={"error": exc.detail}
    )
