import json, os, sys, urllib.request, urllib.parse, concurrent.futures, random, time
ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, 'data')
API = 'https://huggingface.co/api/datasets/leoho36/plant_village_dataset'
BASE = 'https://huggingface.co/datasets/leoho36/plant_village_dataset/resolve/main/'
MAP = {
  'Corn_(maize)___healthy': 'maize_healthy',
  'Corn_(maize)___Northern_Leaf_Blight': 'maize_leaf_blight',
  'Corn_(maize)___Common_rust_': 'maize_leaf_rust',
  'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot': 'maize_leaf_spot',
  'Tomato___healthy': 'tomato_healthy',
  'Tomato___Early_blight': 'tomato_leaf_problem',
  'Tomato___Late_blight': 'tomato_leaf_problem',
  'Tomato___Septoria_leaf_spot': 'tomato_leaf_problem',
}
PER_SOURCE = int(sys.argv[1]) if len(sys.argv) > 1 else 300
random.seed(7)
with urllib.request.urlopen(API, timeout=60) as r:
    d = json.load(r)
files = [s['rfilename'] for s in d['siblings'] if s['rfilename'].startswith('color/')]
jobs = []
for src, dst in MAP.items():
    fs = [f for f in files if f.split('/')[1] == src]
    random.shuffle(fs)
    n = PER_SOURCE if dst != 'tomato_leaf_problem' else PER_SOURCE // 2 + 50  # keep classes balanced
    for f in fs[:n]:
        jobs.append((f, dst))
print('jobs', len(jobs))
def fetch(job):
    f, dst = job
    name = os.path.basename(f).replace(' ', '_')
    path = os.path.join(OUT, dst, name)
    if os.path.exists(path) and os.path.getsize(path) > 0:
        return 'skip'
    os.makedirs(os.path.dirname(path), exist_ok=True)
    url = BASE + urllib.parse.quote(f)
    for attempt in range(6):
        try:
            with urllib.request.urlopen(url, timeout=60) as r, open(path + '.part', 'wb') as w:
                w.write(r.read())
            os.replace(path + '.part', path)
            return 'ok'
        except Exception as e:
            time.sleep(1 + attempt * 2)
    return 'fail'
res = {'ok': 0, 'skip': 0, 'fail': 0}
with concurrent.futures.ThreadPoolExecutor(16) as ex:
    for i, r in enumerate(ex.map(fetch, jobs)):
        res[r] += 1
        if i % 200 == 0: print(i, res, flush=True)
print('done', res)
for dst in set(MAP.values()):
    p = os.path.join(OUT, dst)
    print(dst, len(os.listdir(p)) if os.path.exists(p) else 0)
