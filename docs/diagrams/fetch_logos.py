"""Download the technology logos used in the architecture diagrams.

Logos come from Simple Icons (https://simpleicons.org), which publishes brand
marks as SVG under CC0 1.0. They are rendered to transparent PNG at a fixed
height so every diagram uses the same visual weight.

Brand marks remain the property of their owners and are used here only to
identify the technology in a diagram, which is nominative use.
"""
import os
import urllib.request

import cairosvg

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'logos')
os.makedirs(OUT, exist_ok=True)
SIZE = 256

# slug on simpleicons.org -> (output name, brand hex colour)
LOGOS = {
    'flutter':        ('flutter', '02569B'),
    'dart':           ('dart', '0175C2'),
    'sqlite':         ('sqlite', '003B57'),
    'tensorflow':     ('tensorflow', 'FF6F00'),
    'python':         ('python', '3776AB'),
    'fastapi':        ('fastapi', '009688'),
    'anthropic':      ('anthropic', 'D97757'),
    'claude':         ('claude', 'D97757'),
    'amazonwebservices': ('aws', '232F3E'),
    'openstreetmap':  ('openstreetmap', '7EBC6F'),
    'huggingface':    ('huggingface', 'FFD21E'),
    'android':        ('android', '3DDC84'),
    'ubuntu':         ('ubuntu', 'E95420'),
    'googlemaps':     ('location', '4285F4'),
    'github':         ('github', '181717'),
}


def fetch(slug: str, name: str, colour: str) -> bool:
    url = f'https://cdn.simpleicons.org/{slug}/{colour}'
    try:
        req = urllib.request.Request(
            url, headers={'User-Agent': 'LafaekAIFarm-docs/1.0'})
        with urllib.request.urlopen(req, timeout=40) as r:
            svg = r.read()
        cairosvg.svg2png(bytestring=svg,
                         write_to=os.path.join(OUT, f'{name}.png'),
                         output_width=SIZE, output_height=SIZE)
        return True
    except Exception as e:
        print(f'  !! {slug}: {e}')
        return False


def main() -> None:
    ok = 0
    for slug, (name, colour) in LOGOS.items():
        if fetch(slug, name, colour):
            ok += 1
            print(f'  {name:16s} <- {slug}')
    print(f'\n{ok}/{len(LOGOS)} logos in {OUT}')


if __name__ == '__main__':
    main()
