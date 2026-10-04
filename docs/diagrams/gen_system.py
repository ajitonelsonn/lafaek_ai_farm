"""1 — System architecture.

The headline diagram: what the farmer has, what runs on the phone, and what
the optional cloud adds. The dividing line is the point of the whole project,
so it is drawn literally.
"""
from draw import (AMBER, AMBER_LIGHT, BLUE, BLUE_LIGHT, BORDER, Canvas, GREEN,
                  GREEN_DARK, GREEN_LIGHT, GREY, INK, LAVENDER,
                  LAVENDER_LIGHT, MINT, PAPER, WHITE, titled)

W, H = 1500, 1000
c = Canvas(W, H)

titled(c, 'Lafaek AI Farm — System Architecture',
       'Everything the farmer needs runs on the phone. The cloud is an '
       'enhancement that may be absent.')

# ---------------------------------------------------------------- farmer ---
c.box(40, 110, 240, 190, fill=WHITE, outline=BORDER)
c.logo('android', 62, 132, 30)
c.text(102, 136, 'The farmer', size=16, weight='Bold')
c.text(102, 158, 'Ordinary Android phone', size=11, fill=GREY)
c.text(62, 196, 'Camera  ·  Storage  ·  GPS', size=12)
c.text(62, 218, 'Intermittent 3G/4G,', size=12, fill=GREY)
c.text(62, 236, 'often no signal at all', size=12, fill=GREY)
c.chip(62, 262, 'Tetun or English', fill=MINT)

# ------------------------------------------------------------ the device ---
c.box(320, 110, 700, 560, fill=WHITE, outline=GREEN, radius=18, width=3)
c.chip(340, 126, 'ON THE PHONE — works with no signal', fill=GREEN,
       colour=WHITE)

# UI layer
c.box(344, 170, 652, 92, fill=GREEN_LIGHT, outline=BORDER)
c.logo('flutter', 364, 196, 30)
c.logo('dart', 404, 196, 30)
c.text(448, 186, 'Flutter UI  ·  28 screens', size=14, weight='SemiBold')
c.text(448, 208, 'Provider state  ·  English + Tetun  ·  360 dp first',
       size=11, fill=GREY)
c.text(448, 230, 'Onboarding creates the farmer’s own records — no demo data',
       size=11, fill=GREY)

# AI engines
c.box(344, 276, 318, 200, fill=WHITE, outline=BORDER)
c.text(362, 290, 'Local AI', size=14, weight='Bold')

c.logo('tensorflow', 362, 318, 26)
c.text(398, 318, 'TensorFlow Lite', size=12, weight='SemiBold')
c.text(398, 336, 'MobileNetV3-Small · 14 classes · 1.9 MB', size=10, fill=GREY)
c.text(398, 352, 'maize · rice · tomato · papaya · other', size=10, fill=GREY)

c.box(362, 376, 282, 44, fill=GREEN_LIGHT, outline=None, radius=10)
c.text(374, 384, 'Margin guard — answers “unclear” and', size=10,
       weight='SemiBold', fill=GREEN_DARK)
c.text(374, 400, 'points to a person rather than guessing', size=10,
       fill=GREEN_DARK)

c.text(362, 430, 'llama.cpp  ·  optional 770 MB GGUF', size=11,
       weight='SemiBold')
c.text(362, 448, 'TF-IDF retrieval  ·  rule-based risk engine', size=11,
       fill=GREY)

# Data layer
c.box(678, 276, 318, 200, fill=WHITE, outline=BORDER)
c.text(696, 290, 'Local data', size=14, weight='Bold')
c.logo('sqlite', 696, 316, 26)
c.text(732, 318, 'SQLite via Drift  ·  14 tables', size=12, weight='SemiBold')
c.text(696, 346, 'Farmer · farm · crops · scans · chats', size=10, fill=GREY)
c.text(696, 362, 'Weather cache · offline outbox', size=10, fill=GREY)
c.text(696, 390, '49 knowledge articles (bundled)', size=11)
c.text(696, 408, 'Scan photos → app storage, never uploaded', size=10,
       fill=GREY)
c.text(696, 432, 'Map tiles cached on disk', size=11)
c.text(696, 450, 'Survives restart, reboot and airplane mode', size=10,
       fill=GREY)

# Honest status line
c.box(344, 490, 652, 64, fill=AMBER_LIGHT, outline=None, radius=12)
c.text(362, 500, 'The app always says what it is doing', size=12,
       weight='Bold', fill=INK)
c.text(362, 520,
       '“Local knowledge (model not loaded)” · “Live · Open-Meteo” vs “Saved” · '
       '“Wi-Fi · no internet” · “no local data for this crop”',
       size=10, fill=GREY, max_width=620)

c.text(344, 570, 'Four challenge rules, met on this side of the line:',
       size=12, weight='SemiBold')
c.text(344, 592, '✓ runs on a device she already has      '
                 '✓ core feature works offline', size=11, fill=GREEN_DARK)
c.text(344, 612, '✓ 1.9 MB model side-loads over a weak link      '
                 '✓ Tetun interface', size=11, fill=GREEN_DARK)

# ------------------------------------------------------------- the cloud ---
c.box(1060, 110, 400, 412, fill=WHITE, outline=BLUE, radius=18, width=3,
      dash=True)
c.chip(1080, 126, 'OPTIONAL — only when there is a signal', fill=BLUE_LIGHT,
       colour=BLUE)

c.box(1084, 170, 352, 130, fill=BLUE_LIGHT, outline=None)
c.logo('aws', 1104, 188, 40)
c.text(1104, 222, 'Amazon Lightsail', size=13, weight='SemiBold')
c.text(1104, 240, 'Ubuntu · 512 MB · us-east-1', size=10, fill=GREY)
c.logo('fastapi', 1300, 188, 26)
c.logo('python', 1336, 188, 26)
c.text(1104, 262, 'FastAPI — 2 endpoints, no database', size=11)
c.text(1104, 280, 'Holds the API key. That is its job.', size=10, fill=GREY)

c.box(1084, 314, 352, 100, fill=LAVENDER_LIGHT, outline=None)
c.logo('claude', 1104, 332, 30)
c.text(1144, 334, 'Claude Haiku 4.5', size=13, weight='SemiBold')
c.text(1104, 364, 'Second opinion in plain language,', size=11)
c.text(1104, 382, 'in Tetun or English', size=11)

RED_INK = (175, 50, 40)
c.text(1084, 428, 'Never sent: the photograph,', size=11, weight='SemiBold',
       fill=RED_INK)
c.text(1084, 446, 'the farmer’s name, any credential.', size=11,
       weight='SemiBold', fill=RED_INK)
c.text(1084, 468, 'Sent: a label, a confidence, farm conditions.', size=10,
       fill=GREY)

# ------------------------------------------------------------ the arrows ---
c.arrow(282, 205, 318, 205, colour=GREEN, width=3)
c.arrow(1022, 250, 1058, 250, colour=BLUE, width=3, dashed=True,
        label='~1 KB JSON', label_offset=-20)
c.arrow(1058, 300, 1022, 300, colour=BLUE, width=3, dashed=True,
        label='structured reply', label_offset=8)

c.box(1060, 540, 400, 130, fill=AMBER_LIGHT, outline=None, radius=14)
c.text(1082, 552, 'If the cloud is unreachable or slow', size=14, weight='Bold')
c.text(1082, 576,
       'Nothing breaks. The local result is already on screen and already '
       'saved. Over 600 ms the app does not even try — waiting buys nothing.',
       size=11, fill=INK, max_width=356)
c.text(1082, 638, 'This is the difference between offline-first and '
                  'offline-tolerant.', size=10, weight='SemiBold', fill=GREY,
       max_width=356)

# ------------------------------------------------------- external sources ---
c.box(320, 700, 1140, 160, fill=WHITE, outline=BORDER)
c.text(344, 714, 'External data — fetched when online, cached on the phone, '
                 'read locally ever after', size=13, weight='Bold')

cols = [
    ('openstreetmap', 'OpenStreetMap', 'Map tiles, ODbL.\nCached on disk so a\nfield opened once\nstill draws offline.', 344),
    ('location', 'Open-Meteo', 'Forecast + real soil\nmoisture. No API key.\nWritten to SQLite\nthe moment it lands.', 624),
    ('huggingface', 'Hugging Face', 'Training data only —\nPlantVillage, rice,\npapaya. Never at\nruntime.', 904),
    ('github', 'Model downloads', 'Optional GGUF\nlanguage models,\none time, over\nWi-Fi.', 1184),
]
for logo, name, body, x in cols:
    c.logo(logo, x, 742, 26)
    c.text(x + 34, 744, name, size=12, weight='SemiBold')
    y = 776
    for line in body.split('\n'):
        c.text(x, y, line, size=10, fill=GREY)
        y += 16

# ----------------------------------------------------------------- legend ---
c.text(40, 900, 'Legend', size=12, weight='Bold')
c.arrow(40, 930, 110, 930, colour=GREEN, width=3)
c.text(120, 923, 'always available — no network needed', size=11, fill=GREY)
c.arrow(460, 930, 530, 930, colour=BLUE, width=3, dashed=True)
c.text(540, 923, 'only when a signal is present; failure is harmless',
       size=11, fill=GREY)
c.box(960, 920, 22, 22, fill=WHITE, outline=GREEN, width=3)
c.text(992, 923, 'on-device', size=11, fill=GREY)
c.box(1090, 920, 22, 22, fill=WHITE, outline=BLUE, width=3, dash=True)
c.text(1122, 923, 'cloud, optional', size=11, fill=GREY)

c.text(40, 962, 'Hack-Nation × World Bank Youth Summit  ·  Challenge 04b '
                'Small AI for Development  ·  Track B: Agriculture  ·  '
                'Timor-Leste', size=10, fill=GREY)

c.save('01-system-architecture.png')
