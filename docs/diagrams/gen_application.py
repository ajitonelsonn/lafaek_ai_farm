"""2 — Application architecture.

The layers inside the app and the data flow between them, plus the three AI
pipelines. This is the view that answers "how is the code organised".
"""
from draw import (AMBER_LIGHT, BLUE, BLUE_LIGHT, BORDER, Canvas, GREEN,
                  GREEN_DARK, GREEN_LIGHT, GREY, INK, LAVENDER_LIGHT, MINT,
                  WHITE, titled)

W, H = 1500, 1040
c = Canvas(W, H)
titled(c, 'Application Architecture',
       'One direction of dependency: UI → state → repositories → storage. '
       'No widget ever calls a service or a network directly.')

LAYERS = [
    ('Flutter UI', '28 screens · 5 tabs · English + Tetun',
     'screens/  widgets/  l10n/', GREEN_LIGHT, 118),
    ('State (Provider)', 'ConnectivityState · FarmState · ChatState · '
     'LanguageState · LocalAiEngine', 'state/', MINT, 212),
    ('Repositories & services', 'LocalFarmRepository · LocalScanRepository · '
     'LocalChatRepository · LocalWeatherService · LocalSyncQueueService',
     'repositories/', WHITE, 306),
    ('Storage & engines', 'SQLite (Drift) · TFLite · llama.cpp · TF-IDF · '
     'rule engine · file storage', 'database/  services/local_ai/',
     BLUE_LIGHT, 400),
]
for title, body, path, fill, y in LAYERS:
    c.box(40, y, 700, 80, fill=fill, outline=BORDER)
    c.text(62, y + 14, title, size=15, weight='Bold')
    c.text(62, y + 38, body, size=11, fill=GREY, max_width=600)
    c.text(718, y + 14, path, size=10, fill=GREY, anchor='ra')

for y in (198, 292, 386):
    c.arrow(390, y, 390, y + 14, colour=GREEN, width=2.5, head=7)

c.box(40, 500, 700, 96, fill=AMBER_LIGHT, outline=None)
c.text(62, 514, 'The one rule that makes the swap possible', size=14,
       weight='Bold')
c.text(62, 538,
       'Every engine sits behind an interface — AIService, FarmService, '
       'WeatherService, CropScanService, SyncService. LocalAIService is '
       'active; the cloud path is another implementation, not a rewrite. '
       'main.dart is the only file that wires them together.',
       size=11, fill=INK, max_width=660)

# ---------------------------------------------------------- the pipelines ---
c.text(790, 110, 'The three AI pipelines', size=18, weight='Bold')
c.text(790, 136, 'All three complete without a network.', size=12, fill=GREY)

def pipeline(y, name, steps, accent, note):
    c.box(790, y, 670, 112, fill=WHITE, outline=BORDER)
    c.text(812, y + 12, name, size=14, weight='Bold', fill=accent)
    # Fit however many steps there are inside the card rather than
    # overflowing it.
    gap, inner = 12, 1460 - 812 - 22
    w = (inner - gap * (len(steps) - 1)) / len(steps)
    x = 812
    for i, step in enumerate(steps):
        c.box(x, y + 38, w, 34, fill=GREEN_LIGHT if i % 2 == 0 else MINT,
              outline=None, radius=8)
        c.text(x + w / 2, y + 48, step, size=10, weight='Medium', anchor='ma',
               max_width=w - 8)
        if i < len(steps) - 1:
            c.arrow(x + w + 1, y + 55, x + w + gap - 1, y + 55, colour=accent,
                    width=2, head=5)
        x += w + gap
    c.text(812, y + 84, note, size=10, fill=GREY, max_width=620)

pipeline(168, 'Crop scan',
         ['photo', 'preprocess', 'TFLite', 'margin guard', 'knowledge',
          'save'],
         GREEN,
         'Isolates keep the UI at 60 fps. The result is written to SQLite '
         'before anything else is attempted.')
pipeline(296, 'Ask a question',
         ['question', 'TF-IDF top 3', 'farm context', 'llama.cpp', 'answer'],
         BLUE,
         'With no language model installed the knowledge text is returned '
         'instead, labelled “Local knowledge (model not loaded)”.')
pipeline(424, 'Risk & weather',
         ['forecast', 'soil moisture', 'crop + stage', 'rule engine',
          '“Why” bullets'],
         (124, 92, 214),
         'Transparent weighted rules, not a black box: every rule that fired '
         'is shown to the farmer as a bullet.')

# ------------------------------------------------------------- honesty UI ---
c.box(790, 556, 670, 150, fill=LAVENDER_LIGHT, outline=None)
c.text(812, 570, 'The fail-safe is a first-class component', size=14,
       weight='Bold')
c.text(812, 594,
       'The challenge marks responsible AI pass/fail: the tool must signpost '
       'to a person when its data is not enough. In this app that is code, '
       'not a disclaimer.',
       size=11, fill=INK, max_width=626)
c.text(812, 644, 'confidence ≥ 0.55   AND   top1 − top2 ≥ 0.20', size=13,
       weight='Bold', fill=GREEN_DARK)
c.text(812, 668,
       'Otherwise: “The image is not clear enough to identify the problem '
       'confidently” + ask an extension officer. Measured: 0 wrong answers '
       'on papaya.', size=11, fill=INK, max_width=626)

# ------------------------------------------------------------- data flow ----
c.box(40, 620, 700, 300, fill=WHITE, outline=BORDER)
c.text(62, 634, 'Where a scan actually goes', size=14, weight='Bold')

nodes = [
    (70, 684, 'Camera', GREEN_LIGHT),
    (210, 684, 'TFLite\nisolate', MINT),
    (350, 684, 'CropAnalysis', GREEN_LIGHT),
    (490, 684, 'SQLite\ncrop_scans', BLUE_LIGHT),
    (630, 684, 'sync_queue', BLUE_LIGHT),
]
for x, y, label, fill in nodes:
    c.box(x, y, 104, 54, fill=fill, outline=BORDER, radius=10)
    yy = y + (14 if '\n' in label else 20)
    for line in label.split('\n'):
        c.text(x + 52, yy, line, size=11, weight='Medium', anchor='ma')
        yy += 16
for x in (174, 314, 454, 594):
    c.arrow(x, 711, x + 34, 711, colour=GREEN, width=2.5, head=7)

c.text(70, 756, 'Photo file → app storage. Only the path goes in the '
                'database, and the image never leaves the phone.',
       size=11, fill=GREY, max_width=640)

c.box(70, 788, 300, 100, fill=GREEN_LIGHT, outline=None)
c.text(86, 800, 'Offline', size=12, weight='Bold', fill=GREEN_DARK)
c.text(86, 822, 'Complete. The farmer has a label, an explanation, '
                'actions and a saved record. Nothing is pending that '
                'they need.', size=10, fill=INK, max_width=272)

c.box(392, 788, 326, 100, fill=BLUE_LIGHT, outline=None)
c.text(408, 800, 'Online, afterwards', size=12, weight='Bold', fill=BLUE)
c.text(408, 822, 'A second opinion is fetched and stored beside the local '
                 'result — never replacing it. Schema v2 added the columns '
                 'for exactly this.', size=10, fill=INK, max_width=298)

c.box(790, 730, 670, 190, fill=WHITE, outline=BORDER)
c.text(812, 744, 'Evidence it works', size=14, weight='Bold')
rows = [
    ('Vision model', '95.1% validation on 14 classes. 158 correct / 7 unclear '
     '/ 3 wrong on 168 held-out photos.'),
    ('Papaya', '97% on healthy leaves. On a real Timorese field photo the '
     'guard said \u201cunclear\u201d and Claude identified it from the image.'),
    ('Tests', '103 automated tests, flutter analyze clean. 12 assert the Tetun '
     'translation is real; 11 pin the routing rules.'),
    ('On device', 'Clean install → onboarding → real records. Verified on '
     'CPH2577 (Android 15) and a Pixel 7 emulator.'),
    ('Latency', 'CV 1.4 s on device. Claude second opinion 3.0 s. '
     'Neither blocks the farmer.'),
]
yy = 772
for label, body in rows:
    c.text(812, yy, label, size=11, weight='SemiBold', fill=GREEN_DARK)
    c.text(906, yy, body, size=10, fill=GREY, max_width=540)
    yy += 29

c.text(40, 952, 'Legend', size=12, weight='Bold')
c.arrow(40, 980, 100, 980, colour=GREEN, width=2.5)
c.text(110, 973, 'data flow / dependency', size=11, fill=GREY)
c.box(330, 970, 20, 20, fill=GREEN_LIGHT, outline=BORDER)
c.text(360, 973, 'on-device compute', size=11, fill=GREY)
c.box(530, 970, 20, 20, fill=BLUE_LIGHT, outline=BORDER)
c.text(560, 973, 'persistence', size=11, fill=GREY)
c.box(700, 970, 20, 20, fill=AMBER_LIGHT, outline=BORDER)
c.text(730, 973, 'design rule', size=11, fill=GREY)

c.save('02-application-architecture.png')
