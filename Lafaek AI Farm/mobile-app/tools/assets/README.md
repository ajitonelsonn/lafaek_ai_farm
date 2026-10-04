# Asset pipeline

The app's icons, crop thumbnails, mascot poses, scene photos and status
glyphs all come from one illustration sheet with a transparent background,
`all-images.png` in the repository root. These scripts cut it into the named
files under `assets/images/`.

Requires Python with Pillow (`pip install pillow numpy`).

```bash
cd "Lafaek AI Farm/mobile-app/tools/assets"

# 1. Find every sprite on the sheet and write numbered crops + index.json.
#    Only needed when the sheet changes; it is how the boxes in
#    export_assets.py were measured.
python3 split_sprites.py ../../../../all-images.png /tmp/sprites

# 2. Crop the sheet into the named app assets (83 files, ~1.6 MB).
python3 export_assets.py          # run from this directory

# 3. Rebuild the Android launcher icon from assets/images/logo.png.
python3 make_launcher.py
```

## How the split works

`split_sprites.py` flood-fills the alpha channel to find connected regions,
merges boxes that touch, and orders them top-to-bottom then left-to-right.
Sprites that genuinely touch on the sheet — the two overlapping mascots and
the row of scene photos — are cut on measured seams listed in `MANUAL` at the
top of `export_assets.py`.

Nothing is recoloured or masked: the sheet is already transparent, so each
sprite is cropped to its own alpha bounding box and written out as-is.

## Naming

| Folder | Contents |
|---|---|
| `assets/images/icons/` | `ic_*.png` — navigation, farming, action and state icons (~80 px) |
| `assets/images/crops/` | `crop_*.png` — 13 crop thumbnails (~95 px) |
| `assets/images/mascot/` | `mascot_*.png` — 6 robot poses (~170×200 px) |
| `assets/images/scenes/` | `scene_*.png` — 7 wide landscape photos (~240×160 px) |
| `assets/images/status/` | `pill_*.png` with baked-in English text, `glyph_*.png` the icon alone |

`lib/core/app_assets.dart` is the single registry; nothing in the UI hard-codes
an asset path.

## Two things to know

* **The scene photos are ~240×160 px.** They are fine on crop cards and list
  thumbnails but too small for a full-bleed hero, which is why the Home and
  My Farm headers still use the high-resolution `bg.png`.
* **The `pill_*.png` images have English text baked in.** The UI uses the
  `glyph_*.png` crops beside live text instead, so badges stay crisp and can
  be translated into Tetun later.
