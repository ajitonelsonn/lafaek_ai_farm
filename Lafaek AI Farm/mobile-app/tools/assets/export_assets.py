"""Crop the sprite sheet into named app assets.

The sheet already has a transparent background, so each sprite is cropped to
its own alpha bounding box and written straight out — no recolouring, no
background removal.
"""
import json
import os
from PIL import Image

SHEET = '/Users/ajitonelsonluciodacosta/Documents/Hack-Nation-Global-AI-Hackathon/all-images.png'
DEST = '/Users/ajitonelsonluciodacosta/Documents/Hack-Nation-Global-AI-Hackathon/Lafaek AI Farm/mobile-app/assets/images'

sheet = Image.open(SHEET).convert('RGBA')
index = {e['file']: e for e in json.load(open('sprites/index.json'))}

# Sprites the component pass merged because they touch; cut on measured seams.
MANUAL = {
    'mascot/mascot_chat.png':      (836, 23, 1010, 224),
    'mascot/mascot_question.png':  (1013, 23, 1172, 224),
    'scenes/scene_valley.png':     (21, 687, 308, 847),
    'scenes/scene_leaves.png':     (314, 687, 553, 847),
    'scenes/scene_assistant.png':  (559, 687, 791, 847),
    'scenes/scene_village.png':    (797, 687, 1038, 847),
    'scenes/scene_mountains.png':  (1044, 687, 1281, 847),
    'scenes/scene_farmhouse.png':  (1287, 687, 1515, 847),
}

# One sprite -> one asset path.
NAMES = {
    # mascot
    'r01_c01.png': 'mascot/mascot_wave.png',
    'r01_c02.png': 'mascot/mascot_hello.png',
    'r01_c04.png': 'mascot/mascot_scan.png',
    'r01_c05.png': 'mascot/mascot_celebrate.png',
    # primary navigation + farming icons
    'r02_c01.png': 'icons/ic_home.png',
    'r02_c02.png': 'icons/ic_scan.png',
    'r02_c03.png': 'icons/ic_assistant.png',
    'r02_c04.png': 'icons/ic_farm.png',
    'r02_c05.png': 'icons/ic_weather.png',
    'r02_c06.png': 'icons/ic_more.png',
    'r02_c07.png': 'icons/ic_crop_field.png',
    'r02_c08.png': 'icons/ic_planting.png',
    'r02_c09.png': 'icons/ic_location.png',
    'r02_c10.png': 'icons/ic_water.png',
    'r02_c11.png': 'icons/ic_fertilizer.png',
    'r02_c12.png': 'icons/ic_pest.png',
    'r02_c13.png': 'icons/ic_protect.png',
    'r02_c14.png': 'icons/ic_soil.png',
    # actions
    'r03_c01.png': 'icons/ic_camera.png',
    'r03_c02.png': 'icons/ic_gallery.png',
    'r03_c03.png': 'icons/ic_reports.png',
    'r03_c04.png': 'icons/ic_knowledge.png',
    'r03_c05.png': 'icons/ic_history.png',
    'r03_c06.png': 'icons/ic_sync.png',
    'r03_c07.png': 'icons/ic_settings.png',
    'r03_c08.png': 'icons/ic_profile.png',
    'r03_c09.png': 'icons/ic_alerts.png',
    'r03_c10.png': 'icons/ic_search.png',
    'r03_c11.png': 'icons/ic_edit.png',
    'r03_c12.png': 'icons/ic_delete.png',
    'r03_c13.png': 'icons/ic_add.png',
    'r03_c14.png': 'icons/ic_check.png',
    'r03_c15.png': 'icons/ic_close.png',
    'r03_c16.png': 'icons/ic_back.png',
    # status pills (text baked in)
    'r04_c01.png': 'status/pill_online_ai.png',
    'r04_c02.png': 'status/pill_offline_ai.png',
    'r04_c03.png': 'status/pill_syncing.png',
    'r04_c04.png': 'status/pill_risk_low.png',
    'r04_c05.png': 'status/pill_risk_medium.png',
    'r04_c06.png': 'status/pill_risk_high.png',
    'r04_c07.png': 'status/pill_healthy.png',
    'r04_c08.png': 'status/pill_monitor.png',
    'r04_c09.png': 'status/pill_diseased.png',
    # crops
    'r05_c01.png': 'crops/crop_maize.png',
    'r05_c02.png': 'crops/crop_rice.png',
    'r05_c03.png': 'crops/crop_tomato.png',
    'r05_c04.png': 'crops/crop_chili.png',
    'r05_c05.png': 'crops/crop_onion.png',
    'r05_c06.png': 'crops/crop_cassava.png',
    'r05_c07.png': 'crops/crop_beans.png',
    'r05_c08.png': 'crops/crop_sweet_potato.png',
    'r05_c09.png': 'crops/crop_banana.png',
    'r05_c10.png': 'crops/crop_cabbage.png',
    'r05_c11.png': 'crops/crop_greens.png',
    'r05_c12.png': 'crops/crop_potato.png',
    'r05_c13.png': 'crops/crop_seedling.png',
    # states
    'r07_c01.png': 'icons/ic_empty_growth.png',
    'r07_c02.png': 'icons/ic_empty_none.png',
    'r07_c03.png': 'icons/ic_offline.png',
    'r07_c04.png': 'icons/ic_upload.png',
    'r07_c05.png': 'icons/ic_voice.png',
    'r07_c06.png': 'icons/ic_tip.png',
    'r07_c07.png': 'icons/ic_warning.png',
    'r07_c08.png': 'icons/ic_success.png',
    'r07_c09.png': 'icons/ic_info.png',
    'r07_c10.png': 'scenes/scene_farmer.png',
}

written = []


def save(rel, box):
    path = os.path.join(DEST, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    crop = sheet.crop(box)
    bbox = crop.getbbox()          # tighten to the visible pixels
    if bbox:
        crop = crop.crop(bbox)
    crop.save(path, optimize=True)
    written.append((rel, crop.width, crop.height, os.path.getsize(path)))


for rel, box in MANUAL.items():
    save(rel, box)

for src, rel in NAMES.items():
    e = index[src]
    x0, y0, x1, y1 = e['box']
    save(rel, (x0, y0, x1 + 1, y1 + 1))

# The pill glyphs on their own, so badges can keep crisp live text next to
# the artwork instead of a baked-in bitmap label.
for rel in ['status/pill_risk_low.png', 'status/pill_risk_medium.png',
            'status/pill_risk_high.png', 'status/pill_healthy.png',
            'status/pill_monitor.png', 'status/pill_diseased.png',
            'status/pill_online_ai.png', 'status/pill_offline_ai.png',
            'status/pill_syncing.png']:
    src = Image.open(os.path.join(DEST, rel)).convert('RGBA')
    side = src.height
    glyph = src.crop((0, 0, side, side))
    bbox = glyph.getbbox()
    if bbox:
        glyph = glyph.crop(bbox)
    out = rel.replace('pill_', 'glyph_')
    glyph.save(os.path.join(DEST, out), optimize=True)
    written.append((out, glyph.width, glyph.height,
                    os.path.getsize(os.path.join(DEST, out))))

total = sum(w[3] for w in written)
for rel, w, h, size in sorted(written):
    print(f'{rel:42s} {w:4d}x{h:<4d} {size/1024:7.1f} KB')
print(f'\n{len(written)} files, {total/1024:.0f} KB total')
