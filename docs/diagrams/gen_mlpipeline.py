"""4 — Data and ML pipeline.

Where the training data came from, what was done to it, and — the part the
challenge scores — what it does not cover.
"""
from draw import (AMBER_LIGHT, BLUE_LIGHT, BORDER, Canvas, GREEN, GREEN_DARK,
                  GREEN_LIGHT, GREY, INK, MINT, RED_LIGHT, WHITE, titled)

W, H = 1500, 1000
c = Canvas(W, H)
titled(c, 'Data & Model Pipeline',
       'Four openly-licensed sources → one 1.9 MB model on the phone. '
       'Every gap in the data is stated, because a confident wrong answer '
       'costs a farmer a crop.')

RED_INK = (175, 50, 40)

# ---------------------------------------------------------------- sources ---
c.text(40, 118, '1 — Sources', size=16, weight='Bold')
sources = [
    ('PlantVillage', 'CC0 1.0', 'maize ×4, tomato ×2', '~2,200 images',
     'Studio photos: one detached leaf,\nplain background, even light.',
     'huggingface', 40),
    ('minhhungg/rice-disease', 'Apache-2.0', 'rice ×4', '~1,280 images',
     'South-East Asian rice, but not\nTimorese varieties.',
     'huggingface', 400),
    ('AgML papaya (Bangladesh)', 'CC BY 4.0', 'papaya ×3', '~982 images',
     'Real field photos — but Bangladeshi\nvarieties, soils and light.',
     'huggingface', 760),
    ('Project artwork', 'own assets', 'other ×1', '500 images',
     'Synthetic. Lets the model say\n“that is not a leaf”.',
     'flutter', 1120),
]
for name, lic, classes, vol, gap, logo, x in sources:
    c.box(x, 146, 340, 190, fill=WHITE, outline=BORDER)
    c.logo(logo, x + 18, 164, 24)
    c.text(x + 50, 166, name, size=12, weight='Bold', max_width=270)
    c.chip(x + 18, 196, lic, fill=GREEN_LIGHT, size=10, h=20)
    c.text(x + 18, 226, classes, size=11, weight='SemiBold')
    c.text(x + 18, 246, vol, size=11, fill=GREY)
    c.box(x + 18, 270, 304, 54, fill=RED_LIGHT, outline=None, radius=8)
    c.text(x + 30, 278, 'Does not cover', size=9, weight='Bold', fill=RED_INK)
    yy = 294
    for line in gap.split('\n'):
        c.text(x + 30, yy, line, size=9, fill=RED_INK)
        yy += 13

for x in (380, 740, 1100):
    pass
c.arrow(750, 356, 750, 386, colour=GREEN, width=3, head=9)

# -------------------------------------------------------------- processing --
c.text(40, 380, '2 — Preparation', size=16, weight='Bold')
c.box(40, 408, 1420, 120, fill=GREEN_LIGHT, outline=None)

steps = [
    ('download_*.py', 'Pull balanced subsets through the HF datasets-server '
     'rows API — ~1,300 images instead of a 14 GB clone, the same constraint '
     'a farmer’s link faces.'),
    ('make_other.py', 'Generate 500 non-leaf images from the app’s own '
     'artwork under random crops, rotations and colour shifts.'),
    ('balance.py', 'Cap every class to a common ceiling. Raw papaya has only '
     '182 healthy leaves, so the others are capped rather than the small '
     'class duplicated.'),
]
x = 64
for name, body in steps:
    c.text(x, 424, name, size=12, weight='Bold', fill=GREEN_DARK)
    c.text(x, 448, body, size=10, fill=INK, max_width=430)
    x += 466

c.arrow(750, 540, 750, 568, colour=GREEN, width=3, head=9)

# --------------------------------------------------------------- training ---
c.text(40, 562, '3 — Training', size=16, weight='Bold')
c.box(40, 590, 700, 230, fill=WHITE, outline=BORDER)
c.logo('tensorflow', 64, 608, 30)
c.text(104, 610, 'MobileNetV3-Small, ImageNet backbone', size=13,
       weight='Bold')
c.text(64, 648, '4,028 images  ·  14 classes  ·  224×224  ·  15% held out',
       size=11)
c.text(64, 670, 'Head 5 epochs, then fine-tune the top 40 layers for 4',
       size=11, fill=GREY)
c.text(64, 692, 'Export: float16 TFLite, preprocessing baked into the graph',
       size=11, fill=GREY)

c.box(64, 718, 652, 86, fill=AMBER_LIGHT, outline=None)
c.text(84, 728, 'Two defences against a confident wrong answer', size=12,
       weight='Bold')
c.text(84, 750, 'Strong augmentation — translation, ±30% zoom, contrast, '
                'brightness, hue, 15% grayscale — so colour and background '
                'cannot be shortcuts between datasets.', size=10, fill=INK,
       max_width=620)
c.text(84, 784, 'Label smoothing 0.05, to curb over-confidence.', size=10,
       fill=INK)

# ---------------------------------------------------------------- results ---
c.box(780, 590, 680, 230, fill=WHITE, outline=GREEN, width=2)
c.text(804, 604, '4 — What came out', size=16, weight='Bold')
c.text(804, 636, '95.1%', size=34, weight='Bold', fill=GREEN_DARK)
c.text(940, 648, 'overall validation accuracy', size=12, fill=GREY)
c.text(940, 668, '1,969,344 bytes  ·  1.4 s per photo on device', size=11,
       fill=GREY)

bars = [
    ('papaya_healthy', 97, GREEN),
    ('rice / maize healthy', 100, GREEN),
    ('papaya_pest', 100, GREEN),
    ('papaya_leaf_disease', 94, GREEN),
    ('tomato_leaf_problem', 80, (240, 160, 30)),
    ('maize_leaf_spot', 78, (240, 160, 30)),
]
y = 694
for label, pct, colour in bars:
    c.text(804, y, label, size=10)
    c.box(1010, y + 1, 300, 12, fill=(238, 241, 243), outline=None, radius=6)
    c.box(1010, y + 1, 300 * pct / 100, 12, fill=colour, outline=None,
          radius=6)
    c.text(1330, y, f'{pct}%', size=10, weight='SemiBold')
    y += 20

# ------------------------------------------------------------- the honesty --
c.box(40, 840, 1420, 110, fill=RED_LIGHT, outline=None)
c.text(64, 852, 'Stated plainly, because the challenge scores it', size=14,
       weight='Bold', fill=RED_INK)
c.text(64, 878,
       'The sources were photographed in the United States, South-East Asia '
       'and Bangladesh — not in Timor-Leste. Cross-dataset generalisation to '
       'a real Timorese field photo is unverified. The two weakest classes '
       'merge several diseases into one label, so the model is being asked '
       'to draw a line the data does not draw sharply. This is exactly why '
       'the margin guard exists: on 168 held-out photos it turned near-ties '
       'into “unclear” and left only 3 wrong answers, none of them papaya.',
       size=11, fill=INK, max_width=1380)

c.save('04-data-and-model-pipeline.png')
