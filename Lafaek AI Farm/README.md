# Lafaek AI Farm — the app

> **AI that works where the internet doesn't.**
> Not a cloud application with an offline screen. The product runs on the
> phone; the cloud is an enhancement that may be absent.

Mobile app for smallholder farmers in Timor-Leste: scan a leaf, get farming
advice, track the farm, understand weather risk — **on the device**. Vision
(TensorFlow Lite), knowledge retrieval (SQLite + TF-IDF), risk rules and the
offline outbox all run locally. An optional language model (llama.cpp) and an
optional Claude Haiku backend add to that; neither is required.

For the problem statement, diagrams and evidence see the
[repository README](../README.MD) and [`docs/`](../docs/).

## Run

```bash
cd mobile-app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen (already committed)
flutter run -d <device>                                     # Android arm64 phone
```

Requires Flutter ≥ 3.44 (native-assets support for the bundled llama.cpp
library). Built and verified with **Flutter 3.47.5**.

**No API key, no account, no `.env`.** The app ships with no secrets.

### Tests

```bash
./tools/setup_tflite_host_tests.sh   # once (macOS): lets tests run real TFLite inference
flutter analyze
flutter test                          # 103 tests
```

| Suite | Covers |
|---|---|
| `database_test` (14) | schema v3, onboarding creates real records, **Claude's identification persists**, close/reopen |
| `local_ai_test` (30) | JSON repair, prompts, risk rules, **real TFLite inference** incl. papaya and the margin guard |
| `weather_test` (18) | WMO codes, soil moisture, rainfall, cached-forecast fallback |
| `language_test` (12) | **every Tetun string differs from English**, the fail-safe is translated |
| `connectivity_test` (11) | measured quality, "Wi-Fi with no internet", throttling |
| `ai_router_test` (11) | the 600 ms rule, when Claude is and is not asked |
| `app_test` (7) | navigation at 360/390/412, every route, scan → persist → save |

`screenshot_test` renders 14 screens at 360 dp to `build/screenshots/` with no
device: `SCREENSHOTS=1 flutter test test/screenshot_test.dart`.

### Optional: a language model (one time)

The 770 MB GGUF is not in the APK. In the app: **AI status pill → Language
model → Download** (Llama 3.2 1B recommended, or Gemma 3 1B). Or by `adb`:

```bash
curl -L -o Llama-3.2-1B-Instruct-Q4_K_M.gguf \
  https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf
adb shell mkdir -p /sdcard/Android/data/com.lafaek.lafaek_ai_farm/files/models
adb push Llama-3.2-1B-Instruct-Q4_K_M.gguf /sdcard/Android/data/com.lafaek.lafaek_ai_farm/files/models/
```

Without it the assistant answers from the offline library and **says so** —
"Local knowledge (model not loaded)".

## Offline demo (airplane mode)

1. **Clean install** → onboarding: name + municipality → farm, field, area →
   first crop. Saves with no signal. (The app ships with **no demo data**.)
2. Status pill → Vision ✓, Local Data ✓ (49 articles), Internet: Offline
3. **Scan** a leaf → "Using Local AI · MobileNetV3-Small" → result with model
   name and inference time → **Save to My Farm**
4. **AI Assistant** → ask a question → answered from the offline library,
   labelled as such
5. **My Farm** → crop status updated, activity logged
6. **Weather** → stored forecast, "Updated … · Saved · Open-Meteo", per-crop
   risk with *Why* bullets
7. **More → Language → Tetun** → the whole interface switches
8. Kill and reopen → everything still there (SQLite)
9. Restore the network → reopen a scan the phone could not identify → Claude's
   reading appears and is saved

## Structure (`mobile-app/lib`)

```
database/        Drift schema (14 tables, v3), DAOs — SQLite is the source of truth
l10n/            strings.dart — English + Tetun, compiler-checked
repositories/    LocalFarmRepository, LocalScanRepository, LocalChatRepository,
                 LocalWeatherService, LocalSyncQueueService
services/
  local_ai/      LocalAiEngine, LocalModelManager, DeviceCapabilityService,
                 LocalLlmService (llama.cpp), LlmPromptBuilder, LlmOutputParser,
                 LocalVisionService (TFLite) + ImagePreprocessor,
                 LocalKnowledgeService (TF-IDF), LocalRiskEngine, LocalAIOrchestrator
  cloud/         AiRouter (the 600 ms rule), OnlineAnalysisService
  weather/       OpenMeteoClient          map/  tile cache + GPS
  network_probe  measured connection quality
state/           ConnectivityState, FarmState, ChatState, LanguageState
screens/ widgets/ navigation/ theme/ models/
tools/cv/        dataset downloads → balance.py → train.py → TFLite
tools/assets/    sprite-sheet cutting + launcher icon
assets/models/   crop_condition_mnv3s.tflite (14 classes) + model_meta.json
assets/data/agriculture/   49 knowledge articles (JSON)
```

## Where answers come from

```
no internet            → local
round trip ≥ 600 ms    → local
fast link, the phone has a good answer   → local
fast link, the phone has no good answer  → Claude Haiku
```

The on-device result is always computed and saved **first**. Claude is asked
only when the phone genuinely could not answer — and for a leaf photo it
cannot place, the image itself is sent, which the app tells the farmer.

## Licences

Built with Llama (Llama 3.2 Community License) · Gemma Terms of Use ·
PlantVillage CC0 · rice dataset Apache-2.0 · papaya dataset CC BY 4.0 ·
Open-Meteo CC BY 4.0 · OpenStreetMap ODbL · Inter SIL OFL 1.1 ·
llama.cpp MIT · TensorFlow Lite Apache-2.0
