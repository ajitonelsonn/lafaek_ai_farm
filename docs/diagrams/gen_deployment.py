"""3 — Deployment architecture.

What is installed where, how big it is, and which secrets live on which side
of the boundary. The size column matters: the challenge asks for model files
small enough to send over a weak connection.
"""
from draw import (AMBER_LIGHT, BLUE, BLUE_LIGHT, BORDER, Canvas, GREEN,
                  GREEN_DARK, GREEN_LIGHT, GREY, INK, MINT, PAPER, WHITE,
                  titled)

W, H = 1500, 950
c = Canvas(W, H)
titled(c, 'Deployment Architecture',
       'Two artefacts: an APK on a phone, and a 512 MB virtual machine. '
       'Nothing else has to exist for the app to work.')

RED_INK = (175, 50, 40)

# ------------------------------------------------------------------ phone ---
c.box(40, 110, 700, 560, fill=WHITE, outline=GREEN, radius=18, width=3)
c.logo('android', 62, 128, 28)
c.text(100, 130, 'Android phone  ·  arm64  ·  API 21+', size=16,
       weight='Bold')
c.text(100, 152, 'Verified on CPH2577 (Android 15, 360 dp) and Pixel 7 '
                 'API 33 emulator', size=10, fill=GREY)

c.box(64, 184, 652, 150, fill=GREEN_LIGHT, outline=None)
c.text(84, 196, 'app-release.apk  —  114 MB installed', size=14,
       weight='Bold', fill=GREEN_DARK)
rows = [
    ('Flutter engine + Dart app code', '~95 MB', 'the bulk is the Flutter runtime'),
    ('crop_condition_mnv3s.tflite', '1.9 MB', '14 classes — side-loads over a weak link'),
    ('49 knowledge articles (JSON)', '~0.4 MB', 'seeded into SQLite on first run'),
    ('Illustrated UI assets', '~4 MB', 'icons, crops, mascot, farmer, scenes'),
    ('Inter font', '~1 MB', 'bundled, no network fetch'),
]
y = 224
for name, size, note in rows:
    c.text(84, y, name, size=11)
    c.text(430, y, size, size=11, weight='SemiBold', anchor='ra')
    c.text(450, y, note, size=10, fill=GREY)
    y += 21

c.box(64, 350, 652, 134, fill=BLUE_LIGHT, outline=None)
c.text(84, 362, 'Written on the device at runtime', size=14, weight='Bold',
       fill=BLUE)
rows2 = [
    ('app_documents/lafaek.sqlite', 'farmer, farm, crops, scans, chats, outbox'),
    ('app_documents/lafaek/scans/*.jpg', 'scan photos — never uploaded'),
    ('app_support/models/*.gguf', 'optional language model, 770 MB, farmer-initiated'),
    ('app_support/map_tiles/*.png', 'OSM tiles, ~25–40 MB cap, trimmed oldest-first'),
]
y = 390
for path, note in rows2:
    c.text(84, y, path, size=11, weight='Medium')
    c.text(400, y, note, size=10, fill=GREY)
    y += 23

c.box(64, 500, 652, 66, fill=AMBER_LIGHT, outline=None)
c.text(84, 512, 'Permissions', size=13, weight='Bold')
c.text(84, 534, 'INTERNET · CAMERA · ACCESS_NETWORK_STATE · '
                'ACCESS_FINE/COARSE_LOCATION (optional — decline it and tap '
                'the map instead)', size=10, fill=INK, max_width=620)

c.box(64, 582, 652, 68, fill=WHITE, outline=RED_INK, width=2)
c.text(84, 594, 'No secret ships in the APK', size=13, weight='Bold',
       fill=RED_INK)
c.text(84, 616, 'No API key, no token, no account, no analytics SDK. '
                'Open-Meteo and OpenStreetMap need none; Anthropic’s key '
                'lives only on the server.', size=10, fill=INK, max_width=620)

# ------------------------------------------------------------- lightsail ---
c.box(780, 110, 680, 346, fill=WHITE, outline=BLUE, radius=18, width=3,
      dash=True)
c.logo('aws', 804, 126, 46)
c.text(804, 168, 'Amazon Lightsail  ·  Ubuntu 24.04', size=16, weight='Bold')
c.text(804, 190, '512 MB RAM · 2 vCPU · 20 GB SSD · us-east-1a · '
                 'public IPv4', size=10, fill=GREY)

c.box(804, 216, 632, 110, fill=BLUE_LIGHT, outline=None)
c.logo('python', 824, 234, 26)
c.logo('fastapi', 860, 234, 26)
c.text(900, 236, 'systemd unit  lafaek-api  →  uvicorn :8000', size=12,
       weight='SemiBold')
c.text(824, 268, 'GET  /health            liveness + whether a key is set',
       size=10, fill=GREY)
c.text(824, 286, 'POST /api/v1/analyze    one Claude call, no database',
       size=10, fill=GREY)
c.text(824, 306, 'Restart=always. If it dies, the phone does not notice.',
       size=10, fill=GREY)

c.box(804, 340, 632, 96, fill=WHITE, outline=RED_INK, width=2)
c.text(824, 352, 'The only secret, and the only place it exists', size=13,
       weight='Bold', fill=RED_INK)
c.text(824, 374, '/home/ubuntu/lafaek-backend/.env   mode 600', size=11,
       weight='Medium')
c.text(824, 396, 'ANTHROPIC_API_KEY  ·  git-ignored  ·  never committed  ·  '
                 'never sent to the phone', size=10, fill=GREY, max_width=600)

# ---------------------------------------------------------------- the gap ---
c.box(780, 480, 680, 190, fill=AMBER_LIGHT, outline=None)
c.text(804, 494, 'What happens when the server is gone', size=15,
       weight='Bold')
c.text(804, 520,
       'Stop the service, delete the instance, let the bill lapse — the app '
       'keeps working. Scanning, records, advice, risk and the knowledge '
       'library are all on the phone. The farmer loses the second opinion '
       'and nothing else.',
       size=12, fill=INK, max_width=630)
c.text(804, 606, 'That is the deployment argument for Small AI: the cloud is '
                 'a convenience, not a dependency.', size=11,
       weight='SemiBold', fill=GREEN_DARK, max_width=630)

# -------------------------------------------------------------- pipeline ----
c.box(40, 700, 1420, 180, fill=WHITE, outline=BORDER)
c.text(64, 714, 'Build and release', size=15, weight='Bold')

steps = [
    ('Train', 'tools/cv/\ndownload_* → balance → train', GREEN_LIGHT),
    ('Bundle', 'TFLite + meta into\nassets/models/', MINT),
    ('Test', 'flutter analyze\n91 tests', GREEN_LIGHT),
    ('Build', 'flutter build apk\n--release', MINT),
    ('Install', 'adb install -r\nor side-load', GREEN_LIGHT),
]
x = 64
for i, (name, body, fill) in enumerate(steps):
    c.box(x, 748, 220, 86, fill=fill, outline=None)
    c.text(x + 16, 760, name, size=13, weight='Bold')
    yy = 784
    for line in body.split('\n'):
        c.text(x + 16, yy, line, size=10, fill=GREY)
        yy += 15
    if i < len(steps) - 1:
        c.arrow(x + 226, 791, x + 254, 791, colour=GREEN, width=2.5, head=7)
    x += 260

c.box(1368, 748, 70, 86, fill=BLUE_LIGHT, outline=None)
c.logo('github', 1388, 766, 30)
c.text(1403, 802, 'repo', size=10, anchor='ma', fill=GREY)

c.text(64, 848, 'The model is reproducible from a clean checkout: every '
                'dataset is downloaded by a script in tools/cv/, and '
                'DATASETS.md records each licence and its gaps.',
       size=10, fill=GREY, max_width=1300)

c.text(40, 912, 'Hack-Nation × World Bank Youth Summit  ·  Challenge 04b  ·  '
                'Track B: Agriculture', size=10, fill=GREY)

c.save('03-deployment-architecture.png')
