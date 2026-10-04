# Models

All inference runs on the phone. One vision model is bundled; the farmer picks
one of two language models (each a one-time download) in the AI status
sheet.

## 1a. Language model — Llama 3.2 1B Instruct (GGUF, Q4_K_M) — recommended

| | |
|---|---|
| **Purpose** | Farming assistant answers, scan explanations, risk explanations |
| **Version** | Llama 3.2 1B Instruct (Meta, Sept 2024), quantised by bartowski |
| **Source** | https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF (`Llama-3.2-1B-Instruct-Q4_K_M.gguf`) |
| **License** | Llama 3.2 Community License — redistribution permitted with attribution ("Built with Llama"); see https://www.llama.com/llama3_2/license/ |
| **File size** | 807,694,464 bytes (770 MB) |
| **Runtime** | llama.cpp via `llama_cpp_dart` 0.9 (CPU, arm64-v8a; prebuilt AAR bundled by the package) |
| **Input** | Chat messages rendered with the model's embedded chat template; system prompt in `llm_prompt_builder.dart` |
| **Output** | Streamed tokens; the app asks for a JSON object `{answer, confidence, category, recommended_actions, needs_more_information}` and falls back to plain text |
| **Context** | 2048 tokens, batch 512, threads = cores − 2 (2–6) |
| **Sampling** | temperature 0.4, top-p 0.9, top-k 40, min-p 0.05, repeat penalty 1.1 |
| **Memory** | ~1.1 GB RSS when loaded; loaded lazily on first use, can be unloaded from Settings |

## 1b. Language model — Gemma 3 1B IT (GGUF, Q4_K_M) — alternative

| | |
|---|---|
| **Purpose** | Farming assistant answers, scan explanations, risk explanations |
| **Version** | Gemma 3 1B instruction-tuned (Google, March 2025), quantised by ggml-org |
| **Source** | https://huggingface.co/ggml-org/gemma-3-1b-it-GGUF (`gemma-3-1b-it-Q4_K_M.gguf`) |
| **License** | Gemma Terms of Use — https://ai.google.dev/gemma/terms (redistribution allowed with the terms and prohibited-use policy) |
| **File size** | 806,058,240 bytes (769 MB) |
| **Runtime** | llama.cpp via `llama_cpp_dart` 0.9 (CPU, arm64-v8a) |
| **Input / output** | Same as Llama below (chat template embedded in the GGUF; Gemma folds the system prompt into the first user turn) |
| **Notes** | Same speed as Llama 3.2 1B on the test phone; in side-by-side farming questions Llama gave better answers, so Llama is the recommended default and Gemma stays available as a choice |

### Selection rule

`LocalModelManager.selectBest`: the farmer's saved choice (`app_meta.preferred_llm_id`) if installed → the recommended model (Llama 3.2 1B) if installed → any installed model that fits RAM. If the chosen model fails to load, the other installed model is tried. Switching models in the sheet unloads the current one and loads the new one (~5 s).

### Installation (not bundled in the APK)

The GGUF is **not** inside the APK (Play-store size limits, and it is a one-time install). The app looks in:

1. `<app support dir>/models/` — where the in-app downloader writes
2. `/sdcard/Android/data/com.lafaek.lafaek_ai_farm/files/models/` — app-private external storage, `adb push`-able

Options:

```bash
# A. adb (fastest for demos; no internet needed on the phone)
adb push gemma-3-1b-it-Q4_K_M.gguf          /sdcard/Android/data/com.lafaek.lafaek_ai_farm/files/models/
adb push Llama-3.2-1B-Instruct-Q4_K_M.gguf  /sdcard/Android/data/com.lafaek.lafaek_ai_farm/files/models/

# B. In-app: AI status pill → Language model → Download on the card you want (needs Wi-Fi once)
```

The manager verifies size + `GGUF` magic before loading. A failed/partial file is rejected and the assistant answers from the knowledge library instead (clearly labelled).

## 2. Vision model — crop condition classifier (TensorFlow Lite)

| | |
|---|---|
| **Purpose** | Classify a leaf photo into crop + condition on the Scan screen |
| **Version** | `crop_condition_mnv3s` 1.2.0-dev (trained 4 Oct 2026) |
| **Architecture** | MobileNetV3-Small, ImageNet-pretrained backbone, fine-tuned (top 40 layers) + new softmax head |
| **Source** | Trained by this project — `mobile-app/tools/cv/train.py`; data via `download_plantvillage.py`, `download_rice.py`, `download_papaya.py` and `make_other.py`, balanced by `balance.py` |
| **Training data** | 4,028 images across 14 classes. Maize + tomato from **PlantVillage** (CC0, Hughes & Salathé 2015) via `leoho36/plant_village_dataset`; rice from **minhhungg/rice-disease-dataset** (Apache-2.0); papaya from **Project-AgML/papaya_leaf_disease_classification_bangladesh** (CC BY 4.0, `raw` config); plus 500 `other` non-leaf images generated from the app's own imagery. Full detail and the gaps in [DATASETS.md](DATASETS.md) |
| **License** | Training data: CC0 (PlantVillage) + Apache-2.0 (rice) + CC BY 4.0 (papaya); MobileNetV3 backbone Apache-2.0 |
| **File size** | 1,969,344 bytes (1.9 MB), float16 weights |
| **Runtime** | TensorFlow Lite via `tflite_flutter` 0.12 (LiteRT 1.4, XNNPACK CPU), inference on a dedicated isolate |
| **Input** | `[1, 224, 224, 3]` float32, RGB in **0–255** (MobileNetV3 rescaling is inside the graph); centre-crop → resize |
| **Output** | `[1, 14]` softmax |
| **Validation** | 95.1% overall on a 15% held-out split |
| **Latency** | 64–240 ms on an Apple M-series host; **1.4 s measured on the OPPO CPH2577** (arm64, real camera photo) |
| **Status** | **Development.** Trained on public datasets photographed outside Timor-Leste — mostly studio imagery, with real field photos only for papaya. Not field-validated in Timor-Leste. Every output is presented as "possible/likely", never a confirmed diagnosis. |

### Classes (14)

| Class | Knowledge article | Val. accuracy |
|---|---|---|
| `maize_healthy` | healthy_crop | 100% |
| `maize_leaf_blight` | maize_leaf_blight | 97% |
| `maize_leaf_rust` | maize_leaf_rust | 100% |
| `maize_leaf_spot` | maize_leaf_spot | 78% |
| `rice_healthy` | healthy_crop | 100% |
| `rice_blast` | rice_blast | 100% |
| `rice_bacterial_blight` | rice_bacterial_leaf_blight | 94% |
| `rice_brown_spot` | rice_brown_spot | 94% |
| `tomato_healthy` | healthy_crop | 100% |
| `tomato_leaf_problem` | tomato_early_blight | 80% |
| `papaya_healthy` | healthy_crop | 97% |
| `papaya_leaf_disease` | papaya_leaf_disease | 94% |
| `papaya_pest` | papaya_pest | 100% |
| `other` (not a leaf photo) | — | 100% |

Papaya was added because it grows in most Timorese house yards, so a farmer
can test the app on a plant they already have. `papaya_healthy` at 97% is the
class that matters most for that, since a healthy tree is what they will
photograph first.

The two weakest classes are `maize_leaf_spot` (78%) and `tomato_leaf_problem`
(80%) — both merge several diseases into one label, so the model is being
asked to draw a line the data does not draw sharply. The margin guard turns
most of those into "unclear" rather than a wrong answer.

### Guarding against confident mistakes

The guard, and the confidently-wrong failure that caused it, are explained in
[ENGINEERING.md](ENGINEERING.md#the-margin-guard-and-why-it-exists). In short:
a result is reported only when `confidence ≥ 0.55` **and** `top1 − top2 ≥ 0.20`.

Measured on 168 photos (12 per class, surplus images held out of training where
available): **158 correct, 7 unclear, 3 wrong.** All three errors are maize,
between `leaf_blight` and `leaf_spot`; none are papaya.

Confidence bands: ≥ 0.80 high · 0.60–0.79 moderate · < 0.60 low.
`other` → "No leaf detected" with retake guidance.

### Not in v1

`maize_nutrient_stress` (no permissively-licensed dataset found — PlantVillage
has no nutrient-stress class). Yellowing from nutrient stress is covered by the
knowledge article `maize_nutrient_stress` and the assistant. Adding it is a
data task in `tools/cv/`, not a code change: the app reads its class list from
`model_meta.json` at runtime.

Files shipped in the APK: `assets/models/crop_condition_mnv3s.tflite`,
`model_meta.json` (read at runtime), `labels.txt`, and
`assets/images/sample_leaf.jpg` — a real CC0 PlantVillage maize-blight photo
used as the Scan sample when the device has no camera, so that path shows a
genuine diagnosis (96–99% confidence) rather than an illustration.
