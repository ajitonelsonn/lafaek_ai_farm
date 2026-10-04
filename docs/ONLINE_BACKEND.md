# Online backend — FastAPI on Lightsail, Claude Haiku

The phone is the product. This service is the enhancement: when a farmer has a
signal, the result the on-device model already produced is sent here for a
second opinion from Claude Haiku, in plain language.

Its real job is to **hold the Anthropic API key**. The key never ships in the
APK; the phone talks to this service, and only this service talks to Claude.

## Shape

```
Phone                                 Lightsail (Ubuntu, 512 MB)
  local CV result (already saved)
            │  HTTPS, ~1 KB JSON
            ▼
     POST /api/v1/analyze  ───────▶  FastAPI
                                        │  ANTHROPIC_API_KEY (server only)
                                        ▼
                                   Claude Haiku
                                        │
            ◀───────────────────  structured JSON
  update the local record
```

**The photograph stays on the phone in every case except one.** For a normal
scan only the label the on-device model chose, its confidence and margin, and
the farm context are sent — about 1 KB — and Claude is told it cannot see the
image and must never describe it.

**The exception is `/api/v1/identify`.** When the on-device model returns
`unknown` or `other` — it genuinely could not place the leaf — the photo is
downscaled to 640 px and sent, because Claude can see images and the phone has
nothing else to offer. The farmer is told on the result screen: *"the phone
could not identify this, so the photo was sent to be looked at. Every other
scan stays on the device."*

## Deployment

| | |
|---|---|
| **Host** | Amazon Lightsail, Ubuntu 24.04, 512 MB RAM, us-east-1a |
| **Public IP** | `100.58.102.39` |
| **Service** | systemd unit `lafaek-api`, uvicorn on port 8000 |
| **Code** | `backend/` in this repository |
| **Secrets** | `/home/ubuntu/lafaek-backend/.env`, mode 600, never committed |

```bash
# from the repo root
tar czf /tmp/lafaek-backend.tgz -C backend app requirements.txt lafaek-api.service
scp -i <key>.pem /tmp/lafaek-backend.tgz ubuntu@100.58.102.39:/tmp/
ssh -i <key>.pem ubuntu@100.58.102.39 '
  mkdir -p ~/lafaek-backend && tar xzf /tmp/lafaek-backend.tgz -C ~/lafaek-backend
  cd ~/lafaek-backend && python3 -m venv .venv
  .venv/bin/pip install -r requirements.txt
  sudo cp lafaek-api.service /etc/systemd/system/
  sudo systemctl daemon-reload && sudo systemctl enable --now lafaek-api'
```

`.env` (copy from `.env.example`):

```
ANTHROPIC_API_KEY=sk-ant-...
CLAUDE_MODEL=claude-haiku-4-5-20251001
LAFAEK_APP_TOKEN=            # optional shared secret, sent as X-App-Token
```

## Endpoints

### `GET /health`

```json
{"status":"ok","model":"claude-haiku-4-5-20251001",
 "key_configured":true,"auth_required":false}
```

### The three endpoints, and when each is used

| Endpoint | Used when | Sends the photo? |
|---|---|---|
| `POST /api/v1/analyze` | The phone identified the crop confidently and the link is fast — a second opinion | No |
| `POST /api/v1/identify` | The phone returned `unknown`/`other` **and** the link is fast | **Yes**, downscaled to 640 px |
| `POST /api/v1/ask` | A question the offline library could not answer **and** the link is fast | No |

All three are skipped entirely when the measured round trip is **600 ms or
worse**, or when there is no internet. See the routing rules in
[ENGINEERING.md](ENGINEERING.md#routing-local-or-cloud).

### `POST /api/v1/analyze`

Request:

```json
{
  "local": {"label":"maize_leaf_blight","confidence":0.86,"margin":0.42,
            "runner_up":"maize_leaf_spot","model_name":"MobileNetV3-Small v1.1.0-dev"},
  "farm":  {"crop":"Maize","location":"Ermera, Timor-Leste",
            "growth_stage":"Vegetative","days_since_planting":35,
            "temperature_c":24,"humidity":85,"rain_chance":60,
            "soil_moisture":"Good"},
  "language": "en",
  "knowledge": "…optional article excerpt…"
}
```

Verified response from the deployed service:

```json
{
  "provider": "anthropic",
  "model": "claude-haiku-4-5-20251001",
  "summary": "Possible maize leaf blight detected with high confidence. The warm, humid conditions in Ermera favor this fungal disease. Early action can prevent spread to the whole plant.",
  "confirms_local": true,
  "actions": [
    "Remove and burn lower infected leaves to reduce spore spread.",
    "Improve air flow by spacing plants and removing weeds nearby.",
    "Avoid working in wet fields to prevent disease transmission.",
    "Monitor daily for new spots on upper leaves.",
    "Collect healthy seed from unaffected plants for next season."
  ],
  "ask_a_person": false,
  "caveat": "High humidity and recent rain create ideal conditions for blight. If disease spreads rapidly to upper leaves within 7 days, seek advice from an agricultural extension officer about fungicide options.",
  "elapsed_ms": 3035
}
```

### `POST /api/v1/identify` — Claude looks at the photo

Verified against the bundled maize-blight sample:

```json
{
  "crop": "Likely maize (corn) or sorghum",
  "condition": "Possible leaf spot disease or nutrient deficiency with water stress",
  "summary": "Leaf shows tan/brown streaking and necrotic patches. Low soil moisture and high humidity suggest fungal leaf disease or iron deficiency.",
  "actions": ["Check soil moisture deeply; irrigate if dry below 10cm", "…"],
  "confidence": "moderate",
  "ask_a_person": true,
  "caveat": "Image resolution and angle limit certainty. Bring a clear photo … to a local extension officer for definitive diagnosis.",
  "elapsed_ms": 3252
}
```

It correctly read maize from the image. `low` confidence always forces
`ask_a_person` server-side, whatever the model returned.

### `POST /api/v1/ask` — a question the library missed

Verified in Tetun:

```json
{
  "answer": "Papaya nian liman moras husi rai mamuk. Rai nian bee pouk liu…",
  "actions": ["Bee rai nian loron-loron…", "Halo sombra ki'ik ba papaya nian…"],
  "ask_a_person": true,
  "elapsed_ms": 3877
}
```

## Guardrails

These are in the system prompt and enforced again in code:

* **Never claims certainty** — "possible" and "likely" only.
* **Cannot see the photo**, and is told never to describe it.
* **No pesticide dosages or brand names.** Cultural and physical control first.
* **Fail-safe.** If local confidence < 0.6 or margin < 0.2, `ask_a_person` is
  forced true server-side, regardless of what the model said. The online path
  can never be *less* cautious than the phone's own margin guard.
* Actions must be doable by a smallholder with hand tools.
* Replies are capped and truncated server-side, so a long or malformed answer
  cannot break the phone's layout.

## Failure is normal, and harmless

The app treats every failure the same way: **keep the local result**.

`OnlineAnalysisService.reanalyse` returns `null` on timeout, DNS failure, non-200,
or malformed JSON, and logs it. Nothing is thrown at the UI. A farmer with no
signal sees exactly what a farmer with a signal sees first — the on-device
result — and simply does not get the second opinion.

This is why the service is small on purpose: two endpoints, one model call, no
database. There is nothing to be down.

## Honest limits

* **HTTP, not HTTPS.** The Lightsail instance serves plain HTTP on port 8000.
  The request carries no photograph, no name and no credentials, but a TLS
  certificate is the first thing to add for anything beyond a hackathon demo.
* **512 MB, one worker.** Fine for a demo, not sized for many users.
* **No rate limiting** beyond the optional shared token, and the token is off
  by default.
* The Anthropic free/standard tier applies; the service is non-commercial.
