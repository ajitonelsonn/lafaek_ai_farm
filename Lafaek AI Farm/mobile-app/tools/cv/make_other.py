"""Build the `other` class: photos that are not a crop leaf.

The classifier needs somewhere to put a photo of the ground, a hand, the sky
or a shoe. Without this class every such photo is forced into a disease label,
which is exactly the confident-but-wrong failure the challenge warns about.

Images are generated from this project's own bundled artwork — scenes,
crop illustrations, the mascot, the farmer character, icons and the app
background — under random crops, rotations and colour shifts. They are
synthetic, and `docs/DATASETS.md` says so.
"""
import os
import random

from PIL import Image, ImageEnhance

ROOT = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.abspath(os.path.join(ROOT, '..', '..', 'assets', 'images'))
OUT = os.path.join(ROOT, 'data', 'other')
TARGET = 500
SIZE = 256

random.seed(11)


def sources():
    """Every bundled image that is not a crop leaf photo."""
    out = []
    for folder in ['scenes', 'mascot', 'farmer', 'icons', 'crops']:
        d = os.path.join(ASSETS, folder)
        if not os.path.isdir(d):
            continue
        for f in sorted(os.listdir(d)):
            if f.endswith('.png'):
                out.append(os.path.join(d, f))
    for f in ['bg.png', 'logo.png']:
        p = os.path.join(ASSETS, f)
        if os.path.exists(p):
            out.append(p)
    return out


def variant(path, index):
    im = Image.open(path).convert('RGBA')
    # Flatten onto a random muted background so transparent art does not
    # become a black rectangle, which would be a trivial giveaway.
    bg = Image.new('RGBA', im.size, (
        random.randint(70, 230),
        random.randint(70, 230),
        random.randint(70, 230), 255))
    im = Image.alpha_composite(bg, im).convert('RGB')

    if im.width > 40 and im.height > 40:
        # Random crop of 55-100% of the shorter side.
        side = int(min(im.width, im.height) * random.uniform(0.55, 1.0))
        x = random.randint(0, im.width - side)
        y = random.randint(0, im.height - side)
        im = im.crop((x, y, x + side, y + side))

    im = im.rotate(random.uniform(-25, 25), expand=False,
                   fillcolor=(120, 120, 120))
    im = im.resize((SIZE, SIZE), Image.LANCZOS)
    im = ImageEnhance.Color(im).enhance(random.uniform(0.4, 1.5))
    im = ImageEnhance.Brightness(im).enhance(random.uniform(0.6, 1.35))
    im = ImageEnhance.Contrast(im).enhance(random.uniform(0.7, 1.4))
    if random.random() < 0.5:
        im = im.transpose(Image.FLIP_LEFT_RIGHT)

    os.makedirs(OUT, exist_ok=True)
    im.save(os.path.join(OUT, f'other_{index:04d}.jpg'), quality=88)


def main():
    files = sources()
    if not files:
        raise SystemExit(f'no source images under {ASSETS}')
    print(f'{len(files)} source images -> {TARGET} variants')
    for i in range(TARGET):
        variant(random.choice(files), i)
    print('wrote', len(os.listdir(OUT)), 'images to', OUT)


if __name__ == '__main__':
    main()
