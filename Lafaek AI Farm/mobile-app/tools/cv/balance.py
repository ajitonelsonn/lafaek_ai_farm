"""Cap every class to the same size before training.

Class counts differ a lot between sources: tomato merges three PlantVillage
classes, while raw papaya has only 182 healthy leaves. Training on that
imbalance makes the loss favour the big classes, and `papaya_healthy` is
exactly the class a farmer will test first on the pawpaw in their yard.

Capping to a common ceiling is preferred over duplicating the small class,
because duplicates inflate the validation score without adding information.
"""
import os
import random
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(ROOT, 'data')
# Below this a class is too small to train on at all.
MIN_PER_CLASS = 120

random.seed(13)


def main() -> None:
    cap = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    classes = sorted(
        d for d in os.listdir(DATA) if os.path.isdir(os.path.join(DATA, d)))
    counts = {c: len(os.listdir(os.path.join(DATA, c))) for c in classes}

    small = {c: n for c, n in counts.items() if n < MIN_PER_CLASS}
    if small:
        print('WARNING: classes below the minimum, check the download:', small)

    if cap <= 0:
        # Twice the smallest usable class keeps the ratio within 2:1, which the
        # augmentation can absorb, without throwing away most of the big ones.
        usable = [n for n in counts.values() if n >= MIN_PER_CLASS]
        cap = max(MIN_PER_CLASS, min(usable) * 2)

    print(f'cap = {cap} images per class')
    moved = 0
    for c in classes:
        d = os.path.join(DATA, c)
        files = sorted(os.listdir(d))
        if len(files) <= cap:
            print(f'  {c:26s} {len(files):4d}  (kept)')
            continue
        random.shuffle(files)
        extra = os.path.join(ROOT, 'data_unused', c)
        os.makedirs(extra, exist_ok=True)
        for f in files[cap:]:
            os.replace(os.path.join(d, f), os.path.join(extra, f))
            moved += 1
        print(f'  {c:26s} {len(files):4d} -> {cap}')
    print(f'moved {moved} surplus images to tools/cv/data_unused/')


if __name__ == '__main__':
    main()
