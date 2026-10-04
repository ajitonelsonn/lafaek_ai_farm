"""5 — Crop scan sequence.

The single most important user journey, drawn as a sequence so the
offline-first ordering is unmistakable: the farmer is finished before the
network is ever consulted.
"""
from draw import (AMBER_LIGHT, BLUE, BLUE_LIGHT, BORDER, Canvas, GREEN,
                  GREEN_DARK, GREEN_LIGHT, GREY, INK, LAVENDER,
                  LAVENDER_LIGHT, MINT, WHITE, titled)

W, H = 1500, 900
c = Canvas(W, H)
titled(c, 'Crop Scan — Sequence',
       'Read top to bottom. Everything above the dashed line happens with no '
       'network at all.')

RED_INK = (175, 50, 40)
LANES = [
    ('Farmer', 120, GREEN_LIGHT, 'android'),
    ('Flutter UI', 370, MINT, 'flutter'),
    ('TFLite + rules', 620, GREEN_LIGHT, 'tensorflow'),
    ('SQLite', 870, BLUE_LIGHT, 'sqlite'),
    ('FastAPI', 1120, BLUE_LIGHT, 'fastapi'),
    ('Claude Haiku', 1360, LAVENDER_LIGHT, 'claude'),
]
TOP, BOTTOM = 112, 720
for name, x, fill, logo in LANES:
    c.box(x - 92, TOP, 184, 54, fill=fill, outline=BORDER)
    c.logo(logo, x - 76, TOP + 14, 24)
    c.text(x + 10, TOP + 20, name, size=12, weight='Bold', anchor='ma')
    c.d.line(c._s(x, TOP + 54, x, BOTTOM), fill=(206, 213, 219),
             width=int(2 * 2))


def msg(y, a, b, label, colour=GREEN, dashed=False, note=None):
    xa, xb = LANES[a][1], LANES[b][1]
    c.arrow(xa, y, xb, y, colour=colour, width=2.5, head=8, dashed=dashed,
            label=label, label_offset=-17)
    if note:
        mid = (xa + xb) / 2
        c.text(mid, y + 8, note, size=9, fill=GREY, anchor='ma',
               max_width=abs(xb - xa) - 20)


def band(y, h, label, fill, colour):
    c.box(56, y, 1400, h, fill=fill, outline=None, radius=10)
    c.text(72, y + 6, label, size=10, weight='Bold', fill=colour)


band(188, 200, 'OFFLINE — this is the whole product', GREEN_DARK, GREEN_LIGHT) \
    if False else None
c.box(56, 188, 1400, 232, fill=GREEN_LIGHT, outline=None, radius=12)
c.text(72, 196, 'OFFLINE  —  no network is touched, and none is needed',
       size=11, weight='Bold', fill=GREEN_DARK)

msg(238, 0, 1, 'photographs a leaf')
msg(276, 1, 2, 'bytes → isolate', note='decode, EXIF, centre-crop, 224×224')
msg(320, 2, 2, '')
c.box(540, 306, 170, 44, fill=WHITE, outline=GREEN, radius=10)
c.text(625, 314, 'inference 1.4 s', size=10, weight='SemiBold', anchor='ma')
c.text(625, 330, 'margin guard applied', size=9, fill=GREY, anchor='ma')
msg(374, 2, 3, 'CropAnalysis', note='label, confidence, margin, actions')
msg(404, 3, 1, 'saved', colour=GREEN)

c.box(56, 432, 1400, 56, fill=AMBER_LIGHT, outline=None, radius=12)
c.text(72, 442, 'The farmer is done here.', size=13, weight='Bold')
c.text(72, 464, 'A label, a hedged explanation, actions to take, and a record '
                'that survives a reboot. If the phone never sees a signal '
                'again, nothing is missing.', size=10, fill=INK,
       max_width=1360)

c.d.line(c._s(56, 508, 1456, 508), fill=(150, 165, 180), width=int(2 * 2))
c.text(760, 496, 'only if a signal exists', size=10, weight='SemiBold',
       fill=BLUE, anchor='ma')

c.box(56, 522, 1400, 198, fill=BLUE_LIGHT, outline=None, radius=12)
c.text(72, 530, 'ONLINE  —  an enhancement, attempted after the fact',
       size=11, weight='Bold', fill=BLUE)

msg(566, 1, 4, 'label + confidence + farm context', colour=BLUE, dashed=True,
    note='~1 KB JSON. The photo is sent only when the phone said \u201cunknown\u201d')
msg(606, 4, 5, 'prompt + guardrails', colour=LAVENDER, dashed=True)
msg(642, 5, 4, 'structured JSON', colour=LAVENDER, dashed=True)
msg(678, 4, 3, 'written to SQLite beside the local result', colour=BLUE,
    dashed=True)
msg(706, 3, 1, 'shown on screen, and kept in the history', colour=BLUE,
    dashed=True)

c.box(56, 746, 690, 120, fill=WHITE, outline=RED_INK, width=2)
c.text(76, 758, 'If any online step fails', size=13, weight='Bold',
       fill=RED_INK)
c.text(76, 782, 'Timeout, DNS failure, non-200, malformed JSON, service '
                'deleted — the call returns null, the failure is logged, and '
                'the screen does not change. There is no error for the farmer '
                'to act on, because nothing they needed failed.',
       size=10, fill=INK, max_width=650)

c.box(766, 746, 690, 120, fill=WHITE, outline=GREEN, width=2)
c.text(786, 758, 'The fail-safe runs on both sides', size=13, weight='Bold',
       fill=GREEN_DARK)
c.text(786, 782, 'The phone rejects a near-tie before the request is ever '
                 'made. The server independently forces “ask a person” when '
                 'confidence < 0.6 or margin < 0.2, so the online path can '
                 'never be less cautious than the device.',
       size=10, fill=INK, max_width=650)

c.save('05-crop-scan-sequence.png')
