"""8 — Routing: local or cloud.

The decision the app makes before doing any work, drawn as a flow. Everything
hinges on one measured number, not on whether a Wi-Fi icon is showing.
"""
from draw import (AMBER_LIGHT, BLUE, BLUE_LIGHT, BORDER, Canvas, GREEN,
                  GREEN_DARK, GREEN_LIGHT, GREY, INK, LAVENDER,
                  LAVENDER_LIGHT, MINT, RED_LIGHT, WHITE, titled)

W, H = 1500, 940
c = Canvas(W, H)
titled(c, 'Routing — local or cloud',
       'Decided before any work is done, from the measured round trip. '
       'The phone always answers first; Claude is asked only when the phone '
       'cannot.')

RED_INK = (175, 50, 40)
AMBER_INK = (190, 120, 10)


def node(x, y, w, h, title, body, fill, outline=BORDER, tsize=13):
    c.box(x, y, w, h, fill=fill, outline=outline)
    c.text(x + 14, y + 12, title, size=tsize, weight='Bold')
    if body:
        c.text(x + 14, y + 12 + tsize + 8, body, size=10, fill=GREY,
               max_width=w - 28)


# ------------------------------------------------------------ the measure ---
c.box(40, 110, 300, 150, fill=GREEN_LIGHT, outline=GREEN, width=2)
c.text(62, 124, 'Measure, don’t assume', size=14, weight='Bold')
c.text(62, 150, 'A timed request to Android’s own 204 endpoint. '
                'The result is shown to the farmer as well:',
       size=10, fill=INK, max_width=260)
c.chip(62, 200, 'Wi-Fi · 348 ms', fill=WHITE, colour=GREEN_DARK)
c.text(62, 232, 'Throttled to one probe per 20 s.', size=10, fill=GREY)

c.arrow(344, 185, 384, 185, colour=GREEN, width=3)

# ----------------------------------------------------------- the decision ---
c.box(390, 110, 250, 150, fill=WHITE, outline=INK, width=2, radius=16)
c.text(515, 132, 'Round trip?', size=16, weight='Bold', anchor='ma')
c.text(515, 164, 'no internet', size=11, anchor='ma', fill=RED_INK)
c.text(515, 186, '≥ 600 ms', size=11, anchor='ma', fill=AMBER_INK)
c.text(515, 214, '< 600 ms', size=13, anchor='ma', weight='Bold',
       fill=GREEN_DARK)

c.arrow(515, 264, 515, 300, colour=GREEN, width=3,
        label='< 600 ms', label_offset=-24)
c.arrow(388, 185, 348, 320, colour=(190, 120, 10), width=3, dashed=True)
c.text(150, 300, 'no internet, or 600 ms and worse', size=12, weight='Bold',
       fill=(150, 95, 10))

# --------------------------------------------------------------- the paths --
c.box(40, 330, 300, 320, fill=AMBER_LIGHT, outline=None)
c.text(62, 344, 'Everything stays on the phone', size=14, weight='Bold')
steps_local = [
    ('Scan', 'TFLite → margin guard → knowledge article. Saved to SQLite.'),
    ('Question', 'TF-IDF over 49 articles → on-device model if installed.'),
    ('If neither can answer', '“I could not find this in the local farming '
     'library” — and ask an extension officer.'),
]
y = 376
for title, body in steps_local:
    c.text(62, y, title, size=11, weight='SemiBold', fill=GREEN_DARK)
    y = c.text(62, y + 18, body, size=10, fill=INK, max_width=260) + 14

c.text(62, 598, 'Waiting for a slow link buys nothing: the phone’s answer '
                'is already computed.', size=10, weight='SemiBold', fill=GREY,
       max_width=260)

# fast-link branch
c.box(390, 330, 1070, 320, fill=WHITE, outline=BLUE, width=2, dash=True)
c.text(412, 344, 'Fast link — but the phone still answers first', size=14,
       weight='Bold', fill=BLUE)

# Scan branch
c.box(412, 376, 500, 250, fill=GREEN_LIGHT, outline=None)
c.text(432, 388, 'Scan', size=13, weight='Bold')
c.text(432, 412, 'The on-device model runs and its result is saved — always, '
                 'before anything else.', size=10, fill=INK, max_width=460)

c.box(432, 446, 460, 76, fill=WHITE, outline=BORDER)
c.text(448, 456, 'Confident result', size=11, weight='SemiBold',
       fill=GREEN_DARK)
c.text(448, 476, 'Stay local. Spending a farmer’s data to confirm an answer '
                 'we already trust is rude.', size=10, fill=GREY,
       max_width=430)

c.box(432, 534, 460, 76, fill=LAVENDER_LIGHT, outline=None)
c.text(448, 544, 'unknown / other — the phone could not place it', size=11,
       weight='SemiBold', fill=(110, 80, 200))
c.text(448, 564, 'The photo is downscaled to 640 px and sent to Claude, which '
                 'can see images. The reply is written to SQLite and replaces '
                 '\u201cUnknown crop\u201d everywhere.', size=10, fill=INK, max_width=430)

# Chat branch
c.box(936, 376, 500, 250, fill=MINT, outline=None)
c.text(956, 388, 'Question', size=13, weight='Bold')
c.text(956, 412, 'TF-IDF searches the 49 offline articles first.', size=10,
       fill=INK, max_width=460)

c.box(956, 446, 460, 76, fill=WHITE, outline=BORDER)
c.text(972, 456, 'Score ≥ 0.18 — the library answered', size=11,
       weight='SemiBold', fill=GREEN_DARK)
c.text(972, 476, 'Stay local. The article is the answer, and it is free and '
                 'instant.', size=10, fill=GREY, max_width=430)

c.box(956, 534, 460, 76, fill=LAVENDER_LIGHT, outline=None)
c.text(972, 544, 'Score < 0.18 — a word matched, not the question', size=11,
       weight='SemiBold', fill=(110, 80, 200))
c.text(972, 564, 'Claude answers directly, in Tetun or English, with the farm '
                 'context attached.', size=10, fill=INK, max_width=430)

# ------------------------------------------------------------ what is sent --
c.box(40, 676, 700, 180, fill=WHITE, outline=RED_INK, width=2)
c.text(62, 690, 'What actually crosses the boundary', size=14, weight='Bold',
       fill=RED_INK)
rows = [
    ('Normal scan', 'a label, a confidence, a margin, farm conditions', '~1 KB',
     'no photo'),
    ('Question', 'the question text, farm conditions, one article excerpt',
     '~2 KB', 'no photo'),
    ('Unknown crop', 'the leaf photograph, downscaled to 640 px', '~50 KB',
     'PHOTO SENT'),
]
y = 722
for name, what, size, flag in rows:
    c.text(62, y, name, size=11, weight='SemiBold')
    c.text(190, y, what, size=10, fill=GREY, max_width=330)
    c.text(545, y, size, size=10, fill=GREY)
    c.text(620, y, flag, size=10, weight='Bold',
           fill=RED_INK if flag == 'PHOTO SENT' else GREEN_DARK)
    y += 34

c.text(62, 826, 'Never sent, in any case: the farmer’s name, their '
                'location history, or any credential.', size=10, fill=GREY,
       max_width=660)

# ------------------------------------------------------------- guarantees ---
c.box(770, 676, 690, 180, fill=GREEN_LIGHT, outline=None)
c.text(792, 690, 'What stays true whatever the network does', size=14,
       weight='Bold')
points = [
    'The on-device result is computed and saved before any request is made.',
    'Every cloud call can fail, time out or 502 — the screen does not change.',
    'Offline runs no probe at all, so being offline costs no battery or data.',
    'The server independently forces “ask a person” when confidence is low, '
    'so the online path is never less cautious than the phone.',
]
y = 718
for p in points:
    c.text(792, y, '✓', size=11, weight='Bold', fill=GREEN_DARK)
    y = c.text(812, y, p, size=10, fill=INK, max_width=630) + 6

c.save('08-routing.png')
