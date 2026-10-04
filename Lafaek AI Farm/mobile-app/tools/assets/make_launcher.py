"""Build the Android launcher icon from the Lafaek logo.

Writes legacy square icons for every mipmap density plus an adaptive-icon
foreground (108 dp canvas, logo inside the 66 dp safe zone).
"""
import os
from PIL import Image

APP = '/Users/ajitonelsonluciodacosta/Documents/Hack-Nation-Global-AI-Hackathon/Lafaek AI Farm/mobile-app'
RES = os.path.join(APP, 'android/app/src/main/res')
logo = Image.open(os.path.join(APP, 'assets/images/logo.png')).convert('RGBA')
logo = logo.crop(logo.getbbox())

BG = (250, 252, 248, 255)          # AppColors.cream
DENS = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}


def compose(size, logo_frac, background):
    canvas = Image.new('RGBA', (size, size), background)
    side = int(size * logo_frac)
    art = logo.copy()
    art.thumbnail((side, side), Image.LANCZOS)
    canvas.paste(art, ((size - art.width) // 2, (size - art.height) // 2), art)
    return canvas


for name, px in DENS.items():
    out = os.path.join(RES, f'mipmap-{name}')
    os.makedirs(out, exist_ok=True)
    # Legacy icon: the logo nearly fills the tile.
    compose(px, 0.92, BG).save(os.path.join(out, 'ic_launcher.png'))
    # Adaptive foreground: 108 dp canvas, art kept inside the 66 dp safe zone.
    fg_px = round(px * 108 / 48)
    compose(fg_px, 66 / 108, (0, 0, 0, 0)).save(
        os.path.join(out, 'ic_launcher_foreground.png'))
    print(f'mipmap-{name}: {px}px legacy, {fg_px}px foreground')

# Adaptive icon descriptor + its background colour.
anydpi = os.path.join(RES, 'mipmap-anydpi-v26')
os.makedirs(anydpi, exist_ok=True)
xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
'''
for f in ('ic_launcher.xml', 'ic_launcher_round.xml'):
    open(os.path.join(anydpi, f), 'w').write(xml)

values = os.path.join(RES, 'values')
os.makedirs(values, exist_ok=True)
colors = os.path.join(values, 'colors.xml')
entry = '    <color name="ic_launcher_background">#FAFCF8</color>\n'
if os.path.exists(colors):
    body = open(colors).read()
    if 'ic_launcher_background' not in body:
        body = body.replace('</resources>', entry + '</resources>')
        open(colors, 'w').write(body)
else:
    open(colors, 'w').write(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        + entry + '</resources>\n')
print('wrote adaptive icon descriptors and background colour')
