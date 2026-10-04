# Engineering deep dive

The five on-device engines, in the order a scan touches them. For the system
view and diagrams see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 0. Routing — local or cloud

Decided **before any work is done**, from the *measured* round trip rather
than from "is there a Wi-Fi icon". `lib/services/cloud/ai_router.dart`.

```
no internet            → local
round trip ≥ 600 ms    → local
fast link, phone has a good answer   → local
fast link, phone has no good answer  → Claude
```

**600 ms** is the line because beyond it a request plus a model call makes the
farmer wait for something the phone has already computed. The threshold lives
in `NetworkProbe.slowThreshold`, so the probe, the status line (`Wi-Fi · 348
ms`) and the router can never disagree.

### What "no good answer" means

| Path | The phone has no answer when… | Then |
|---|---|---|
| **Scan** | the margin guard rejected the result, or the class was `other` — i.e. `unknown` | the photo is sent to `/identify`, because Claude can see images and the phone cannot place this one. The reply is **written to SQLite** and replaces `Unknown crop` on the screen and in the history |
| **Chat** | the best TF-IDF score is below **0.18** — a word matched, not the question | the question goes to `/ask` |

If the link is slow or absent, the same two cases fall back to the on-device
language model, and then to the honest *"I could not find this in the local
farming library"*.

### Why not always ask Claude when online

Because the farmer pays for the data. When the on-device model is confident
and the margin guard is satisfied, or the library genuinely answered, the app
has a good answer already — spending a connection to confirm it buys nothing.

Covered by `test/ai_router_test.dart` (11 tests).

---

## 1. Computer vision — `services/local_ai/`

**MobileNetV3-Small**, ImageNet backbone, fine-tuned. 14 classes, 1.9 MB
float16 TFLite, bundled in the APK. Runs through `tflite_flutter` on an
`IsolateInterpreter` so the UI never blocks.

```
camera / gallery bytes
  → decode + bake EXIF orientation        (compute isolate)
  → centre-crop to square → resize 224×224
  → float32 RGB 0–255                      (scaling is inside the graph)
  → TFLite                                 (interpreter isolate)
  → softmax over 14 classes
  → label = argmax only if p ≥ 0.55 AND (top1 − top2) ≥ 0.20, else "unknown"
  → band: ≥0.80 high · 0.60–0.79 moderate · <0.60 low
  → knowledge article for the condition
  → explanation: llama.cpp if loaded, else the article text (engine recorded)
  → CropAnalysis → crop_scans row + photo file + sync_queue
```

Preprocessing matches training exactly, because `include_preprocessing=True`
bakes MobileNetV3's scaling into the graph — the app only resizes and feeds
raw 0–255 pixels.

### The margin guard and why it exists

The first 11-class model scored 98.5% in validation and then called a **healthy
maize leaf `rice_bacterial_blight` at 74% confidence**. Maize/tomato came from
PlantVillage and rice from a different dataset, so the model had learned
*which dataset an image came from* — background and colour balance — rather
than what was on the leaf.

Three changes fixed it:

1. **Strong augmentation** — translation, ±30% zoom, 0.35 contrast, 0.25
   brightness, saturation/hue jitter, 15% grayscale. Colour and background
   stop being usable shortcuts.
2. **Label smoothing** 0.05, to curb over-confidence.
3. **The margin guard** — a result is reported only when `confidence ≥ 0.55`
   **and** `top1 − top2 ≥ 0.20`.

`CvResult` carries `margin` and `runnerUp` so the near-tie is visible rather
than hidden, and both are persisted so the guard still works when a scan is
reopened from history.

Measured on 168 held-out photos: **158 correct, 7 unclear, 3 wrong** — and the
healthy-maize photo that used to be misread now returns *unclear*.

This is also the challenge's pass/fail criterion: *"AI signposting to a
decision-maker when the data it is acting on is not enough … 'not sure — ask a
person' rather than guessing."*

### Camera

`scan_screen.dart` uses the `camera` plugin: preview only while the Scan tab is
visible, torch, front/back, 1×/2×/3× zoom, gallery via `image_picker`. With no
camera (emulator, denied permission, tests) a bundled CC0 PlantVillage photo is
used and labelled "Sample photo", so that path shows a genuine diagnosis rather
than an illustration.

---

## 2. Language model — optional, never required

**Farmer's choice** of Llama 3.2 1B Instruct (recommended) or Gemma 3 1B IT —
both GGUF Q4_K_M, ~770 MB — via **llama.cpp** through `llama_cpp_dart`. A 3B
option was removed: it needs 7 GB of RAM, which no phone this app is built for
has, so it only ever appeared as a greyed-out row. The package bundles a prebuilt arm64 AAR through a
native-assets hook, so there is no NDK or CMake in this repository.

| File | Role |
|---|---|
| `local_model_manager.dart` | Locate → verify (size + `GGUF` magic) → select by RAM → download with resume → delete |
| `device_capability_service.dart` | ABI, cores, RAM from `/proc/meminfo`, free storage; threads = cores − 2 (2–6) |
| `local_llm_service.dart` | `LlamaEngine.spawn` in a worker isolate; streamed tokens; cancel; dispose |
| `llm_prompt_builder.dart` | System prompt — persona, hedging rules, no pesticide dosages, JSON shape |
| `llm_output_parser.dart` | JSON validation + repair (fences, prose, truncation); never throws |

Parameters: nCtx 2048, nBatch 512, gpuLayers 0, mmap on; temperature 0.4,
top-p 0.9, top-k 40, min-p 0.05, repeat 1.1. Loads lazily on first use
(~5 s, ~1.1 GB RSS) and can be freed from Settings.

**A 1B model does not reliably emit valid JSON**, so the parser strips fences,
extracts the first `{…}`, salvages `"answer"` from truncated output, normalises
confidence and unknown categories, and otherwise shows the raw text.
`StructuredAnswer.structured` records which path was taken.

**The honesty rule.** With no model installed, answers come from the knowledge
library and are labelled **"Local knowledge (model not loaded)"** in the bubble,
the engine chip and the status sheet. Nothing canned is ever presented as AI.

---

## 3. Knowledge library and retrieval

**49 English articles** for Timor-Leste smallholders, bundled as JSON and
seeded into SQLite on first run (versioned by `app_meta.knowledge_seed_version`).

```
assets/data/agriculture/
├── crops.json          6   maize, rice, tomato, chili, beans, cassava
├── diseases.json      14   maize blight/rust/leaf spot/nutrient stress,
│                           rice blast/bacterial blight/brown spot,
│                           tomato early + late blight, chili anthracnose,
│                           bean rust, papaya leaf virus, papaya pest,
│                           healthy crop care
├── pests.json          8   fall armyworm, stem borers, aphids, planthopper,
│                           whitefly, fruit borer, storage weevils
├── soil.json           5   compost, mulching, rotation, slopes, reading soil
├── irrigation.json     4   when/how much, dry season, drainage, rice water
├── planting.json       4   TL calendar, seed selection, spacing, intercropping
├── climate.json        3   seasons & zones, El Niño, humidity ↔ disease
└── farming_tips.json   5   field walk, records, safe pesticide use, weeding,
                            harvest & storage
```

Retrieval is **TF-IDF cosine similarity**, hand-written:

```
question → tokenise (lower-case, strip punctuation, stop-words, light stemmer)
        → TF-IDF vector (title ×2, keywords ×2, summary, crop, symptoms, causes)
        → cosine against all articles (index built once, in memory)
        → ×1.35 bonus for crop match, +0.5 when the title appears in the query
        → top 3 with score > 0.02
```

No vector database. 49 sparse vectors, a query takes < 5 ms, and there is no
dependency to break offline. `forCondition(id)` maps a CV class straight to its
article.

One bug worth recording: the stemmer turned "diseases" into "diseas". It now
only strips `es` after a sibilant (`sses|xes|ches|shes|zes`).

**Articles contain no pesticide dosages or product names** — cultural and
physical control first, then an extension officer.

---

## 4. Risk engine — rules, not a model

`services/local_ai/local_risk_engine.dart`. Transparent weighted rules, because
a farmer can be shown *why*.

**Inputs** — temperature, humidity, rain chance, wind, crop, days since
planting, growth stage, recent scan statuses (14 days), soil moisture. Since
the weather phase these are **measured** values from Open-Meteo, not demo
numbers.

| Rule | weight |
|---|---|
| Humidity ≥ 80% | 2 |
| Rain chance ≥ 60% or recent rain ≥ 20 mm | 2 |
| Warm (24–30 °C) + wet + humid | 1 |
| Tomato and (humid or wet) — blight | 2 |
| Chili and wet — anthracnose | 1 |
| Rice, humidity ≥ 85% and ≤ 26 °C — blast | 2 |
| Rice, wet + wind ≥ 25 km/h — bacterial leaf blight | 1 |
| Maize, humid + warm — leaf blight | 1 |
| Maize 7–45 days after planting — fall armyworm window | 1 |
| Beans + humid — rust | 1 |
| ≥ 32 °C and dry — water stress | 1 |
| Soil moisture "dry" and no rain | 2 |
| Soil moisture "low" and no rain | 1 |
| Flowering / tasselling / heading stage | 1 |
| 1 recent problem scan / ≥ 2 | 1 / 2 |

Score 0–2 → **Low**, 3–5 → **Medium**, 6+ → **High**. Farm level = worst crop.
Every rule that fired is shown as a "Why:" bullet with one practical action.

> **A bug the measured data exposed.** The soil rule originally matched only
> the literal label `"low"` — all the demo data ever produced. Once Open-Meteo
> supplied real values it could also return `"Dry"`, which is *worse*, and the
> rule silently ignored it: parched ground scored **below** merely low ground.
> Both are now handled, `dry` weighs more, and two tests pin the ordering.
> `"Unknown"` adds nothing, because a missing reading must not be scored as
> either good or bad.

---

## 5. Local database — Drift + SQLite

SQLite is the device source of truth. Every write goes
`UI → state → repository → Drift → SQLite`; the UI never makes an API call.

* File: `<app documents>/lafaek.sqlite`, `shareAcrossIsolates: true`
* Schema version **3**, `PRAGMA foreign_keys = ON`
* Also on disk: scan photos, optional GGUF models, cached map tiles

| Table | Purpose |
|---|---|
| `farmers`, `farms`, `farm_locations` | Profile, farm, fields. `latitude`/`longitude` are set when a plot is pinned, and the first pinned plot is what the forecast is fetched for |
| `crops` | Crop, variety, area, status, growth stage, planted date |
| `farm_activities` | Planted / watered / fertilized / scanned / harvested |
| `crop_scans` | Every scan: image path, CV class, hedged label, confidence, **margin + runner-up**, severity, explanation, actions, model name, inference ms, engine. Plus the **online second opinion** columns (v2) and **Claude's identification** — `onlineCrop`, `onlineCondition`, `onlineConfidence` (v3) |
| `conversations`, `chat_messages` | Assistant history with engine and confidence |
| `knowledge_articles` | 49 seeded articles with JSON lists |
| `weather_cache` | One payload per location + `source` (`live`/`cached`/`manual`/`demo`) + `updatedAt` |
| `sync_queue` | Offline outbox |
| `recommendations`, `alerts`, `app_meta` | Dashboard cards, alerts, key/value settings |

### Offline outbox

```
id · entityType · entityId · operation · payload(JSON) · createdAt
attemptCount · lastAttemptAt · status(pending|syncing|synced|failed) · errorMessage
```

Upload is deliberately **disabled**. `sync()` walks pending rows, marks them
`syncing`, records `failed` with "Cloud upload not enabled in the local-first
phase", increments `attemptCount` and **never deletes**. Full cloud sync is
future work and is not claimed as built.

### Migrations

`onCreate` creates everything; `onUpgrade` added the margin, runner-up and
online-analysis columns for v2, and Claude's crop/condition/confidence for v3. Tests open both an in-memory database and a
file-backed one that is closed and reopened, to prove persistence.

---

## Engineering problems worth recording

| Problem | Resolution |
|---|---|
| Drift column named `text` shadowed the `text()` builder | renamed the column to `content` |
| DAO methods collided with table getters | renamed to `listConversations`, `listLocations`, … |
| Drift row classes collided with UI models | `@DataClassName('CropRow')` etc. |
| Widget tests hung — TFLite isolate work never completes under fake-async | wrap setup/dispose in `tester.runAsync` |
| Gradle 8.3 < required 8.14 | regenerated `android/`, re-applied manifest + label |
| `tflite_flutter` JVM target mismatch (Java 11 vs Kotlin 20) | `kotlin.jvm.target.validation.mode=warning` |
| App reported **offline for a moment on every launch** | connectivity check now waits for the first platform answer instead of assuming none |
| `LanguageState` declared after `FarmState` → "Provider not found" at boot | providers only see ones declared before them; reordered |
| Rice downloader returned 0 images for two classes | a rate limit emptied a page and `break` exited the loop — added a coarse label scan, miss counter and sleeps |
