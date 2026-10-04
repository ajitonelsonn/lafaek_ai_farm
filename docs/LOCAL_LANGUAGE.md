# Local language — Tetun

The challenge makes this a **rule**, not a feature request:

> *"at least one interaction is in a local language, by voice or text — name
> the language, and expect to be asked how the tool would fare in a
> less-supported one."* — §06 The Rules

**The named language is Tetun** (Tetun Dili), the national language of
Timor-Leste and the one most farmers speak at home. The whole interface is
translated. English remains the default because the knowledge library and the
language models are written in it; Tetun is one tap away in More → Language.

## What is translated, and what is not

| Part of the app | Tetun | Notes |
|---|---|---|
| Navigation, menus, buttons | ✅ | *Uma, Hare, Asistente AI, Ha'u-nia To'os, Seluk* |
| Onboarding (all three steps) | ✅ | The first thing a new farmer sees |
| Forms, labels, validation messages | ✅ | |
| Scan results and confidence wording | ✅ | including the "unclear photo" message |
| **The fail-safe sentence** | ✅ | see below |
| Risk levels and "Why" bullets | ✅ | |
| Weather screen | ✅ | |
| Crop-coverage explanations | ✅ | |
| Knowledge library articles | ❌ | 49 articles, English source material |
| Language-model answers | ❌ | Llama/Gemma have no real Tetun ability |

The Language screen states this gap plainly rather than implying full coverage:

> The whole interface is in Tetun: menus, forms, scan results and risk
> warnings. The knowledge articles and the AI model's answers are still in
> English, because that is the source material. The app does not pretend
> otherwise.

`TetunStrings.missingTetun` holds that list in code, so the honesty is a data
structure rather than a promise in a README.

## The fail-safe, in Tetun

The pass/fail judging criterion asks for AI that signposts to a person when it
is unsure. That sentence had to work in both languages:

> **EN** — "If you are not sure, ask your agricultural extension officer. This
> app informs your decision; it does not replace it."
>
> **TET** — "Se ita la serteza, husu ita-nia estensionista agrikultura nian.
> Aplikasaun ne'e ajuda ita deside; nia la troka ita-nia desizaun."

A test asserts this string is translated and non-empty, because a fail-safe
that silently reverts to English is not a fail-safe for a Tetun speaker.

![Language models and status](diagrams/07-app-screens.png)

## Vocabulary choices

Agricultural terms follow the words farmers and extension material actually
use, not invented equivalents:

| English | Tetun | |
|---|---|---|
| maize | **batar** | |
| rice | **hare** | |
| tomato | **tomate** | loanword in everyday use |
| chili | **ai-manas** | literally "hot plant" |
| beans | **koto** | |
| field / garden | **to'os** | |
| disease | **moras** | also "sickness" |
| soil / land | **rai** | |
| leaf | **tahan** | |

Loanwords that farmers genuinely say are kept — *umidade*, *risku*, *hektare*,
*perfil*, *konfigurasaun* — because an unfamiliar coined word helps nobody.
`TetunStrings.cropName()` maps crop names so "The camera can check Maize
leaves" becomes "Kamera bele hare **batar** nia tahan".

## How it is built

`lib/l10n/strings.dart` — one abstract `S` class, two implementations.

Hand-written rather than generated from ARB files. With two languages, a plain
Dart file keeps every Tetun string reviewable by a native speaker in one place,
which matters more here than tooling. The compiler enforces completeness: a
missing override will not build, so a string **cannot** silently fall back to
English.

```dart
S.of(context).navHome          // "Uma" or "Home"
S.of(context).cropScannable(c) // interpolates the Tetun crop name
```

`LanguageState` persists the choice in `app_meta.language`, so it survives a
restart with no account and no network. `LanguageScope` is an `InheritedWidget`
above `MaterialApp`; changing language rebuilds the tree immediately.

## Tests — `test/language_test.dart` (12)

* Every interface string **differs** from its English counterpart — a
  translation that silently fell through would let the app claim a language it
  does not have.
* No Tetun string is empty.
* Parameterised strings keep their value, and crop names come out in Tetun.
* The fail-safe sentence is translated.
* `missingTetun` is non-empty for Tetun and empty for English, so the app
  cannot over-claim.
* Default is English; the Tetun choice survives a restart; switching back
  persists too.
* `LanguageScope` falls back to English outside a scope.

## How it would fare in a less-supported language

The challenge says to expect this question.

**The interface would port easily.** Adding Portuguese or Bahasa Indonesia is
one more subclass of `S` — the structure, the compiler check and the honesty
list all come for free. Portuguese and Indonesian are both far better resourced
than Tetun.

**The hard parts would not port.**

1. **The language model.** Llama 3.2 and Gemma 3 have little Tetun and
   effectively none for a language with less web text. This is why the app
   never depends on the model: the knowledge library answers without it.
2. **Speech.** Voice is the right interface for a farmer with limited screen
   literacy, and it is the piece this build does not have. Tetun has very
   little public speech data; Mozilla Common Voice and Meta MMS are the
   realistic starting points, and MMS claims Tetun coverage. The mic button
   says voice is not available rather than pretending.
3. **The knowledge library.** 49 articles would need a translator who knows
   both agronomy and Tetun. Machine translation of agricultural advice is a
   way to get a farmer to damage a crop.

So the honest answer: **the interface scales to any language; the AI does
not.** The architecture is arranged around that — the parts that must work
offline and in-language are rule-based and translatable, and the parts that
cannot be translated are optional enhancements the app works without.
