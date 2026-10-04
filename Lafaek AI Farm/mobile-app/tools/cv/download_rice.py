"""Download a balanced rice-leaf subset for training.

Source: minhhungg/rice-disease-dataset (Apache-2.0) on Hugging Face, pulled
through the datasets-server rows API so we fetch only the images we need
instead of the full 14 GB parquet set.

Classes produced (folder names match the model's class ids):
  rice_healthy · rice_blast · rice_bacterial_blight · rice_brown_spot
"""
import concurrent.futures
import json
import os
import sys
import time
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, 'data')
DATASET = 'minhhungg/rice-disease-dataset'
PER_CLASS = int(sys.argv[1]) if len(sys.argv) > 1 else 320

# split -> {dataset label: our class folder}
WANTED = {
    'healthy': {None: 'rice_healthy'},          # whole split is healthy rice
    'diseases': {
        'Blast': 'rice_blast',
        'Bacterial Leaf Blight': 'rice_bacterial_blight',
        'Brown Spot': 'rice_brown_spot',
    },
}
ROWS = ('https://datasets-server.huggingface.co/rows?dataset={ds}&config=default'
        '&split={split}&offset={off}&length={n}')


def rows(split, offset, length=100, attempts=5):
    url = ROWS.format(ds=urllib.parse.quote(DATASET, safe=''), split=split,
                      off=offset, n=length)
    for a in range(attempts):
        try:
            with urllib.request.urlopen(url, timeout=90) as r:
                return json.load(r)
        except Exception:
            time.sleep(2 + 3 * a)
    return {'rows': []}


def fetch(job):
    url, path = job
    if os.path.exists(path) and os.path.getsize(path) > 0:
        return 'skip'
    os.makedirs(os.path.dirname(path), exist_ok=True)
    for a in range(5):
        try:
            with urllib.request.urlopen(url, timeout=90) as r, open(path + '.part', 'wb') as w:
                w.write(r.read())
            os.replace(path + '.part', path)
            return 'ok'
        except Exception:
            time.sleep(1 + 2 * a)
    return 'fail'


def label_offsets(split, total, step=200):
    """Map dataset label -> sorted offsets where it appears.

    The split is grouped by label, so a coarse scan is enough to find where
    each class lives; that keeps us well under the API's rate limit.
    """
    seen = {}
    for off in range(0, total, step):
        batch = rows(split, off, 1)
        for r in batch.get('rows', []):
            seen.setdefault(r['row'].get('label'), []).append(off)
        time.sleep(0.2)
    return seen


def main():
    jobs, counts = [], {}
    for split, mapping in WANTED.items():
        total = rows(split, 0, 1).get('num_rows_total', 0)
        print(f'{split}: {total} rows')
        if None in mapping:                      # whole split is one class
            starts = [0]
        else:
            found = label_offsets(split, total)
            print('  labels:', {k: (v[0], v[-1]) for k, v in found.items()})
            starts = []
            for label, cls in mapping.items():
                offs = found.get(label)
                if not offs:
                    print('  !! label not found:', label)
                    continue
                starts.append(max(0, offs[0] - 200))
        for start in starts:
            offset, misses = start, 0
            while offset < total and misses < 5 and any(
                    counts.get(c, 0) < PER_CLASS for c in mapping.values()):
                batch = rows(split, offset, 100)
                if not batch.get('rows'):
                    misses += 1
                    offset += 100
                    time.sleep(3)
                    continue
                misses = 0
                added = 0
                for r in batch['rows']:
                    row = r['row']
                    cls = mapping.get(row.get('label')) or mapping.get(None)
                    if cls is None or counts.get(cls, 0) >= PER_CLASS:
                        continue
                    src = row['image']['src']
                    name = f'{cls}_{r["row_idx"]:06d}.jpg'
                    jobs.append((src, os.path.join(OUT, cls, name)))
                    counts[cls] = counts.get(cls, 0) + 1
                    added += 1
                offset += 100
                time.sleep(0.2)
                # Past this label's block: nothing new for several pages.
                if added == 0 and offset > start + 1500:
                    break
    print('queued', len(jobs), 'images:', counts)

    res = {'ok': 0, 'skip': 0, 'fail': 0}
    with concurrent.futures.ThreadPoolExecutor(12) as ex:
        for i, out in enumerate(ex.map(fetch, jobs)):
            res[out] += 1
            if i % 200 == 0:
                print(i, res, flush=True)
    print('done', res)
    for cls in sorted({c for m in WANTED.values() for c in m.values()}):
        p = os.path.join(OUT, cls)
        print(cls, len(os.listdir(p)) if os.path.exists(p) else 0)


if __name__ == '__main__':
    main()
