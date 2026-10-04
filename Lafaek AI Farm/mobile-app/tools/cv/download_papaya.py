"""Download papaya (pawpaw) leaf images for the crop classifier.

Source: Project-AgML/papaya_leaf_disease_classification_bangladesh, CC-BY-4.0,
1,400 raw field photographs in six classes. The `raw` config is used rather
than `augmented`, because augmentation is done during training and duplicated
images would inflate the validation score.

The six source classes collapse to three the app can give different advice for:

    Healthy Leaf                      -> papaya_healthy
    Leaf Curl, Mosaic, Ring Spot      -> papaya_leaf_disease   (viral//disorder)
    Mealybug, Mite Disease            -> papaya_pest           (visible pests)

Papaya matters here because it grows in almost every Timorese house yard, so a
farmer can test the app on a plant they already have.
"""
import concurrent.futures
import json
import os
import time
import urllib.request

DATASET = 'Project-AgML/papaya_leaf_disease_classification_bangladesh'
CONFIG = 'raw'
SPLIT = 'train'
OUT = os.path.join(os.path.dirname(__file__), 'data')
PER_CLASS = 400

CLASS_MAP = {
    'Healthy Leaf': 'papaya_healthy',
    'Leaf Curl': 'papaya_leaf_disease',
    'Mosaic': 'papaya_leaf_disease',
    'Ring Spot': 'papaya_leaf_disease',
    'Mealybug': 'papaya_pest',
    'Mite Disease': 'papaya_pest',
}


def rows(offset, length):
    url = (f'https://datasets-server.huggingface.co/rows?dataset='
           f'{DATASET.replace("/", "%2F")}&config={CONFIG}&split={SPLIT}'
           f'&offset={offset}&length={length}')
    for attempt in range(5):
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                return json.load(r)
        except Exception as e:
            print(f'  retry {attempt + 1}: {e}')
            time.sleep(2 + 3 * attempt)
    return {}


def fetch(job):
    src, path = job
    if os.path.exists(path):
        return 'skip'
    os.makedirs(os.path.dirname(path), exist_ok=True)
    for attempt in range(3):
        try:
            with urllib.request.urlopen(src, timeout=60) as r, \
                    open(path + '.part', 'wb') as w:
                w.write(r.read())
            os.replace(path + '.part', path)
            return 'ok'
        except Exception:
            time.sleep(1 + 2 * attempt)
    return 'fail'


def main():
    names = None
    first = rows(0, 1)
    for f in first.get('features', []):
        if f['name'] == 'label':
            names = f['type'].get('names')
    if not names:
        raise SystemExit('could not read the label names')
    print('source classes:', names)

    total = first.get('num_rows_total') or 1400
    jobs, counts = [], {}
    offset = 0
    while offset < total and any(
            counts.get(c, 0) < PER_CLASS for c in set(CLASS_MAP.values())):
        batch = rows(offset, 100)
        if not batch.get('rows'):
            offset += 100
            time.sleep(2)
            continue
        for r in batch['rows']:
            row = r['row']
            label = row.get('label')
            source = names[label] if isinstance(label, int) else label
            cls = CLASS_MAP.get(source)
            if cls is None or counts.get(cls, 0) >= PER_CLASS:
                continue
            jobs.append((row['image']['src'],
                         os.path.join(OUT, cls, f'{cls}_{r["row_idx"]:05d}.jpg')))
            counts[cls] = counts.get(cls, 0) + 1
        offset += 100
        time.sleep(0.2)

    print('queued', len(jobs), 'images:', counts)
    res = {'ok': 0, 'skip': 0, 'fail': 0}
    with concurrent.futures.ThreadPoolExecutor(12) as ex:
        for i, out in enumerate(ex.map(fetch, jobs)):
            res[out] += 1
            if i % 100 == 0:
                print(i, res, flush=True)
    print('done:', res)
    for cls in sorted(set(CLASS_MAP.values())):
        d = os.path.join(OUT, cls)
        n = len(os.listdir(d)) if os.path.isdir(d) else 0
        print(f'  {cls}: {n} images')


if __name__ == '__main__':
    main()
