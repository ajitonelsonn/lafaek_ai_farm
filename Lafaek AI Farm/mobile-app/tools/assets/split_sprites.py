"""Split the transparent sprite sheet into individual PNGs.

Finds connected regions of non-transparent pixels, merges boxes that belong to
the same sprite (overlapping or nearly touching), and writes one cropped PNG
per sprite, ordered top-to-bottom then left-to-right.
"""
import os
import sys
import json
import numpy as np
from PIL import Image

SRC = sys.argv[1]
OUT = sys.argv[2]
ALPHA_MIN = 12
MIN_AREA = 900          # ignore specks
GAP = 6                 # px: boxes closer than this horizontally merge

os.makedirs(OUT, exist_ok=True)
im = Image.open(SRC).convert('RGBA')
a = np.array(im)[:, :, 3]
h, w = a.shape
print('sheet', w, 'x', h)

mask = a > ALPHA_MIN

# ---- connected components (iterative flood fill, 8-connected) ----
labels = np.zeros((h, w), dtype=np.int32)
cur = 0
boxes = []
ys, xs = np.nonzero(mask)
for sy, sx in zip(ys, xs):
    if labels[sy, sx]:
        continue
    cur += 1
    stack = [(sy, sx)]
    labels[sy, sx] = cur
    x0 = x1 = sx
    y0 = y1 = sy
    n = 0
    while stack:
        y, x = stack.pop()
        n += 1
        if x < x0: x0 = x
        if x > x1: x1 = x
        if y < y0: y0 = y
        if y > y1: y1 = y
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                ny, nx = y + dy, x + dx
                if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not labels[ny, nx]:
                    labels[ny, nx] = cur
                    stack.append((ny, nx))
    boxes.append([x0, y0, x1, y1, n])

print('raw components:', len(boxes))
boxes = [b for b in boxes if (b[2] - b[0] + 1) * (b[3] - b[1] + 1) >= MIN_AREA]
print('after area filter:', len(boxes))


def overlaps(p, q, gap):
    return not (p[2] + gap < q[0] or q[2] + gap < p[0] or
                p[3] + gap < q[1] or q[3] + gap < p[1])


# ---- merge boxes that belong to one sprite ----
changed = True
while changed:
    changed = False
    out = []
    for b in boxes:
        hit = None
        for o in out:
            if overlaps(b, o, GAP):
                hit = o
                break
        if hit:
            hit[0] = min(hit[0], b[0]); hit[1] = min(hit[1], b[1])
            hit[2] = max(hit[2], b[2]); hit[3] = max(hit[3], b[3])
            hit[4] += b[4]
            changed = True
        else:
            out.append(list(b))
    boxes = out
print('after merge:', len(boxes))

# ---- order: rows top-to-bottom, then left-to-right ----
boxes.sort(key=lambda b: b[1])
rows, cur_row = [], []
row_bottom = -1
for b in boxes:
    cy = (b[1] + b[3]) / 2
    if cur_row and cy > row_bottom:
        rows.append(cur_row)
        cur_row = []
    if not cur_row:
        row_bottom = b[3]
    else:
        row_bottom = max(row_bottom, b[3])
    cur_row.append(b)
if cur_row:
    rows.append(cur_row)

index = []
n = 0
for ri, row in enumerate(rows, 1):
    row.sort(key=lambda b: b[0])
    for ci, b in enumerate(row, 1):
        n += 1
        x0, y0, x1, y1, _ = b
        crop = im.crop((x0, y0, x1 + 1, y1 + 1))
        name = f'r{ri:02d}_c{ci:02d}.png'
        crop.save(os.path.join(OUT, name))
        index.append({'file': name, 'row': ri, 'col': ci,
                      'box': [int(x0), int(y0), int(x1), int(y1)],
                      'w': int(x1 - x0 + 1), 'h': int(y1 - y0 + 1)})
print('wrote', n, 'sprites in', len(rows), 'rows')
for ri, row in enumerate(rows, 1):
    print(f'  row {ri}: {len(row)} sprites, h≈{max(b[3]-b[1] for b in row)}')
json.dump(index, open(os.path.join(OUT, 'index.json'), 'w'), indent=1)
