# Lafaek AI Farm

**AI that works where the internet doesn't.**

A farming assistant for smallholder farmers in Timor-Leste. It identifies crop
problems from a leaf photo, warns about weather risk, and answers farming
questions — **on an ordinary Android phone, with no signal**. When a signal
appears it can ask Claude Haiku for a second opinion, but it never needs to.

> Hack-Nation × World Bank Youth Summit · **Challenge 04b — Small AI for
> Development** · Track B: Agriculture

![System architecture](diagrams/01-system-architecture.png)

![The app](diagrams/07-app-screens.png)

---

## The problem, in one sentence

> Because of this tool, a smallholder farmer in Timor-Leste will **identify a
> crop problem and act on it the same day**, where they would otherwise wait
> for an extension officer who reaches the sub-county **twice a year at best**
> — and 60% of the country is not online to look it up instead.

Agriculture supports about **70%** of Timor-Leste's population, and the UN's
2025 analysis reports only **39.5%** internet use, concentrated in towns. A
tool that needs a connection is a tool most farmers cannot use.

---

## What it does

| | |
|---|---|
| 📷 **Scan a leaf** | 14-class model on the phone. Maize, rice, tomato, **papaya** — plus "that is not a leaf" |
| 🌦️ **Weather + risk** | Live forecast with real soil moisture; transparent rules say *why* a crop is at risk |
| 💬 **Ask a question** | 49 bundled articles, TF-IDF retrieval, optional on-device language model |
| 🗺️ **Pin your field** | OpenStreetMap, tiles cached for offline use; the forecast follows your plot |
| 🇹🇱 **Tetun or English** | The whole interface, not a token string |
| ☁️ **Claude when it helps** | If the phone cannot identify a leaf, the photo goes to Claude Haiku's vision. If the offline library cannot answer a question, Claude does. Only on a link measured under 600 ms |

Individual screens are in [`screenshots/`](screenshots/).

---

## How it meets the challenge

### The four rules (§06)

| Rule | How |
|---|---|
| Runs on a device the user already has | Ordinary Android phone — camera, storage, intermittent 3G |
| Its core feature works offline | Scanning, records, advice and risk are all on-device |
| Model files small enough to side-load or send over a weak connection | **1.9 MB** vision model, bundled. The optional 770 MB language models are *not* small enough — which is why the app works fully without them |
| At least one interaction in a local language | **Tetun** — named, and the entire interface. [Details](LOCAL_LANGUAGE.md) |

### The pass/fail criterion — responsible AI

The brief asks for a fail-safe: *"not sure — ask a person" rather than
guessing.* In this app that is **code, not a disclaimer**:

```
report a result only if   confidence ≥ 0.55   AND   top1 − top2 ≥ 0.20
otherwise                 "The image is not clear enough …" + ask an extension officer
```

This exists because an early model called a **healthy maize leaf
`rice_bacterial_blight` at 74% confidence**. A confidently wrong answer is
worse for a farmer than no answer. On 168 held-out photos the guard produced
**158 correct, 7 unclear, 3 wrong**.

### Data grounding (§7.2 — *scored*)

> *"You must also indicate what your data does not cover, and this is scored."*

Stated in full in **[DATASETS.md](DATASETS.md)**. The short version: the
training photographs were taken in the United States, South-East Asia and
Bangladesh — **not Timor-Leste**. PlantVillage is studio imagery on plain
backgrounds, which the brief itself names as a weakness. Generalisation to a
real Timorese field photo is unverified, and that is exactly why the margin
guard exists.

---

## Evidence it works

| | |
|---|---|
| Vision model | **95.1%** validation on 14 classes, 1.9 MB, 1.4 s per photo on device |
| When the phone cannot tell | Claude Haiku reads the photo. Verified on a real Timorese papaya: *"Papaya (Carica papaya) — possible nutrient deficiency and water stress"*, saved to the device |
| Papaya | **97%** on healthy leaves — the class a farmer tests first on the tree in their yard. 0 wrong |
| Held-out check | 158 correct · 7 unclear · **3 wrong** out of 168 |
| Tests | **103 automated tests**, `flutter analyze` clean |
| Tetun | 12 tests assert every string genuinely differs from English |
| On device | Clean install → onboarding → real records. Verified on CPH2577 (Android 15) and a Pixel 7 emulator |
| Backend | Live, verified, and answers **in Tetun** when asked |

---

## Documentation

**Start here**

| | |
|---|---|
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Seven diagrams — system, application, **routing**, deployment, data pipeline, sequence, screens |
| **[DATASETS.md](DATASETS.md)** | Every dataset, licence, and **what it does not cover** |
| **[CROP_COVERAGE.md](CROP_COVERAGE.md)** | Which crops work offline, which need internet, and how the app says so |
| **[LOCAL_LANGUAGE.md](LOCAL_LANGUAGE.md)** | Tetun — scope, vocabulary, and how it would fare in a less-supported language |

**Going deeper**

| | |
|---|---|
| [ENGINEERING.md](ENGINEERING.md) | The five on-device engines: vision, language model, retrieval, risk, database |
| [MODELS.md](MODELS.md) | Model cards — licences, sizes, per-class accuracy |
| [WEATHER_AND_MAPS.md](WEATHER_AND_MAPS.md) | Open-Meteo, OpenStreetMap, tile caching, measured connection quality |
| [ONLINE_BACKEND.md](ONLINE_BACKEND.md) | FastAPI on Lightsail, Claude Haiku, guardrails, deployment |
| [TESTING.md](TESTING.md) | How to run the tests and the airplane-mode matrix |
| [CHANGELOG.md](CHANGELOG.md) | What was built, phase by phase, with verification |

---

## Running it

```bash
cd "Lafaek AI Farm/mobile-app"
flutter pub get
flutter analyze && flutter test          # 103 tests
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Requires Flutter 3.47+. No API key, no account, no `.env` — the app has no
secrets. The optional language model is downloaded by the farmer from inside
the app.

The backend is optional; see [ONLINE_BACKEND.md](ONLINE_BACKEND.md) to deploy
your own.

---

## What the app does today, and what comes next

Everything below the line in each row is already running in the submitted
build. The right-hand column is the roadmap.

| | Today | Next |
|---|---|---|
| **Crop scanning** | 14 classes on-device: maize, rice, tomato, papaya | More crops — adding one is a data task, not a code change |
| **When the phone cannot tell** | The photo goes to Claude Haiku, which can see images | Learn from these cases to retrain the on-device model |
| **Farming questions** | 49 offline articles → on-device model → Claude on a fast link | A Tetun-language model, when one exists |
| **Language** | Tetun and English, whole interface | Tetun knowledge articles; Portuguese and Indonesian |
| **Voice** | Not available — and the app says so rather than pretending | Tetun speech-to-text; the right interface for low screen literacy |
| **Weather** | Live Open-Meteo forecast with real soil moisture, cached | Per-plot forecasts for farms spread across municipalities |
| **Maps** | OpenStreetMap, tiles cached as you browse | "Download this area" before leaving a signal |
| **Cloud sync** | Outbox records and retries; upload is deliberately off | Sync farm records so a lost phone is not a lost season |
| **Field validation** | Trained on public datasets from the US, South-East Asia and Bangladesh | Photographs from Timorese fields — the single biggest improvement available |
| **Backend security** | HTTP; carries no photo except the unknown-crop case, no name, no credential | TLS before anything beyond a hackathon |

Two things worth stating plainly, because they affect how the results should
be read:

* **The model has not been validated on a Timorese field photo.** Every output
  is a *possible* finding, and the margin guard sends uncertain cases to a
  person rather than guessing.
* **Open-Meteo's free tier is non-commercial**, so a released product needs
  their commercial plan or another source.

## Credits

Weather by [Open-Meteo](https://open-meteo.com) (CC BY 4.0) · Map data ©
[OpenStreetMap](https://www.openstreetmap.org/copyright) contributors (ODbL) ·
PlantVillage (CC0) · `minhhungg/rice-disease-dataset` (Apache-2.0) ·
`Project-AgML/papaya_leaf_disease_classification_bangladesh` (CC BY 4.0) ·
Inter font (SIL OFL 1.1) · Logos from [Simple Icons](https://simpleicons.org)
(CC0)
