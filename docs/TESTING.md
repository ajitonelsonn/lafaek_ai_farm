# Offline Testing

## Automated

```bash
cd "Lafaek AI Farm/mobile-app"
flutter analyze
./tools/setup_tflite_host_tests.sh     # once per machine (macOS): TFLite dylib for host tests
flutter test                            # 103 tests
```

| Suite | Covers |
|---|---|
| `test/database_test.dart` (14) | schema, farmer/farm, crop, location, activity, scan, chat pagination, **a fresh install is empty and asks for onboarding**, **onboarding creates farmer + farm + field + crop**, **an unknown scan keeps Claude's identification**, **close/reopen persistence**, outbox dry-run & status, knowledge seed + retrieval, stemmer |
| `test/local_ai_test.dart` (30) | JSON parser (6), prompts, model verify, LLM not-loaded / missing-file error states, risk rules (6, incl. **dry soil must outrank low soil** and unknown soil scoring nothing), preprocessor (2), **real TFLite inference** (9, incl. the four rice classes, the three papaya classes, the bundled sample photo and the margin guard), bands, orchestrator knowledge fallback (2) |
| `test/app_test.dart` (7) | 5-tab navigation at 360/390/412, every named route, **sample photo → real CV → result persisted → save**, offline banner + local engine, assistant answer persisted |
| `test/connectivity_test.dart` (11) | probe verdicts, **Wi-Fi with a dead router is offline not "good"**, **ordinary mobile data is good not "limited"**, slow link → limited, offline never probes, throttling, demo override still wins, startup waits for the first platform answer |
| `test/ai_router_test.dart` (11) | the 600 ms rule, **a confident local result stays local even online**, unclear + fast link → Claude, slow or offline → always local, a weak keyword match is not an answer |
| `test/language_test.dart` (12) | **every Tetun string differs from English**, none empty, crop names in Tetun, the fail-safe sentence is translated, `missingTetun` is honest, English is the default, the Tetun choice survives a restart |
| `test/weather_test.dart` (18) | WMO code mapping (incl. **never guess sunny**), soil-moisture labels + 24 h delta, parsing a recorded Open-Meteo response, real rainfall in mm per day, incomplete response rejected, **demo data carries no rainfall figures**, cached-forecast fallback when a fetch fails, staleness labelling |

`test/screenshot_test.dart` renders fourteen screens at 360 dp to
`build/screenshots/` so layout can be checked without a phone. It writes files
and asserts nothing, so it is skipped unless explicitly enabled:

```bash
SCREENSHOTS=1 flutter test test/screenshot_test.dart
```

Material icons render as empty boxes in those PNGs — the icon font is not
loaded in the test environment. The illustrated PNG icons do render, which is
what the shots are for. The `weather_live` shot seeds a recorded Open-Meteo
response so the rainfall chart draws real numbers with no network; map tiles
are blank there for the same reason.

An **emulator** also works for a full visual check without the user's phone:

```bash
flutter emulators --launch Pixel_7_API_33
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk
adb -s emulator-5554 shell am start -n com.lafaek.lafaek_ai_farm/.MainActivity
```

The widget tests run the real stack (in-memory SQLite, real TFLite, no LLM
file → knowledge fallback). Vision and DB work is kicked off inside
`tester.runAsync` because it uses isolates.

## On the phone (release APK)

```bash
flutter build apk --release
flutter install -d <device> --release
adb push gemma-3-1b-it-Q4_K_M.gguf /sdcard/Android/data/com.lafaek.lafaek_ai_farm/files/models/   # and/or Llama-3.2-1B-Instruct-Q4_K_M.gguf
```

Then walk this matrix; the app must behave identically in every row except
the Internet line in the status sheet:

Connection quality is **measured**, not guessed from the interface type, so
these rows depend on the real link (see "Connection quality" in
[WEATHER_AND_MAPS.md](WEATHER_AND_MAPS.md)). The status sheet always prints
what was measured, e.g. `Wi-Fi · 180 ms` or `Mobile data · no internet`.

| Network state | Expect |
|---|---|
| Wi-Fi or mobile data, working | green dot, `<transport> · <n> ms`. **Good 4G now reads "good"**, which the old type check called "limited" |
| A slow link (> 1500 ms round-trip) | amber dot, banner "Weak connection. Nothing changes — AI runs on this phone." |
| **Wi-Fi joined but no internet** (router off, captive portal, data bundle spent) | blue dot and `Wi-Fi · no internet`. The old type check wrongly said "good" here |
| **Airplane mode** | banner "You're offline. Lafaek AI works fully on this phone." No probe runs — offline costs no battery or data |
| Restart app while offline | Home shows the same farm, scans, chats; pill returns to Ready |
| Restart device while offline | same; model file still found (`files/models/`) |
| More → Offline & Sync → "Check now" | re-measures immediately and updates the line |

To force the no-internet case on an emulator: leave Wi-Fi on and run
`adb shell svc data disable` with the host network blocked, or point
`NetworkProbe.endpoint` at an unroutable address in a debug build.

Demo walk-through, in airplane mode:

1. **Clean install** → onboarding: name + municipality → farm, field, area →
   first crop. Everything saves with no signal. (`adb uninstall` first, or the
   app opens to the farm you already created.)
2. Open app → status pill → sheet shows Vision ✓, Language model ✓ (Llama 3.2 1B is marked Recommended; Gemma 3 1B is the alternative — pick in the sheet), Local Data ✓ (49 articles), Internet: Offline.
3. Scan → shutter (real camera) or Upload → Analyze → "Using Local AI · MobileNetV3-Small + Llama 3.2 1B" → result with model name + ms → Save to My Farm.
4. AI Assistant → ask "Why are my maize leaves turning yellow?" → "Preparing local AI…" on first use → streamed answer with "Llama 3.2 1B" on the bubble → sources line.
5. My Farm → crop status updated, activity logged.
6. Weather → the stored forecast appears instantly, labelled "Updated … · Saved · Open-Meteo" in airplane mode and "Live · Open-Meteo" with a signal. Rain-this-week bars, per-crop risk with "Why" bullets, the OpenStreetMap forecast point, and "Enter" for manual conditions.
7. More → Language → **Tetun** → the whole interface switches. Then
   More → Offline & Sync → Local AI on this phone (models, device) + outbox rows.
8. Kill and reopen the app → all of the above still there.
9. Restore the network → open a saved scan → Claude's second opinion appears
   *below* the local result, which has not changed.

### Things to watch

* First LLM load takes a few seconds and ~1.1 GB RAM; on a 3 GB phone close other apps first. If the chosen model fails to load, the app falls back to the other installed one, and to the knowledge library if neither works.
* If the model file is missing, the assistant still answers ("Local knowledge (model not loaded)") and the status sheet offers the download.
* Photos taken in poor light will often return "Possible crop issue (unclear photo)" — that is the low-confidence guard working.

## Performance (measured)

* SQLite CRUD: < 5 ms per operation in tests (in-memory); expect < 50 ms on device.
* CV: 64–240 ms/image on an M-series Mac; **1.4 s measured on the phone**.
* LLM: streaming; ~8–15 tok/s for 1B Q4 on a mid-range arm64 (device-dependent, not guaranteed).
* Claude second opinion: ~3.0 s round trip, and never on the critical path.
