/**
 * Sync the repository's Markdown into the site.
 *
 * The rule the site is built on: **if git does not track it, it does not ship.**
 * `.gitignore` is therefore the single source of truth for what is excluded —
 * `docs/CHANGELOG.md`, `hackathon.md`, `lightshail_setup/` and the rest are
 * skipped automatically, without this script needing to know their names.
 *
 * It copies the chosen documents into `src/content/`, copies every image they
 * reference into `public/content-assets/`, and rewrites their links so that
 * `[DATASETS.md](DATASETS.md)` becomes a route and an excluded document
 * degrades to plain text instead of a dead link.
 *
 *   node scripts/sync.mjs            write the content
 *   node scripts/sync.mjs --check    report only, change nothing
 */
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const SITE = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const REPO = path.resolve(SITE, '..');
const CONTENT = path.join(SITE, 'src', 'content');
const ASSETS = path.join(SITE, 'public', 'content-assets');
const CHECK_ONLY = process.argv.includes('--check');

const REPO_URL = 'https://github.com/ajitonelsonn/lafaek_ai_farm';
const APK_URL =
  'https://drive.google.com/file/d/134zTtlbgaEjsoSXXJ_4Q6iK-6ZXOaRA-/view?usp=sharing';

/**
 * The documents the site publishes, in navigation order. `source` is relative
 * to the repository root. Anything not listed here is simply not part of the
 * site; anything listed here but untracked by git is dropped with a warning.
 *
 * `icon` names a file in the mobile app's own icon set, so the site is dressed
 * in the product's artwork rather than a second visual language.
 *
 * Note that `docs/README.md` is deliberately absent: it restates the root
 * README almost line for line, and two identical overviews in one sidebar is
 * worse than one. The root README wins because it carries the APK link and the
 * install walkthrough.
 */
const DOCS = [
  { slug: '', source: 'README.MD', nav: 'Overview', title: 'Lafaek AI Farm',
    icon: 'ic_home',
    blurb: 'What it is, who it is for, and how it meets the challenge' },

  { slug: 'architecture', source: 'docs/ARCHITECTURE.md', nav: 'Design',
    icon: 'ic_more',
    title: 'Architecture', blurb: 'Eight views of the system, as diagrams' },
  { slug: 'engineering', source: 'docs/ENGINEERING.md', nav: 'Design',
    icon: 'ic_settings', title: 'Engineering',
    blurb: 'The on-device engines, the database schema, and the routing rules' },

  { slug: 'models', source: 'docs/MODELS.md', nav: 'Models and data',
    icon: 'ic_scan',
    title: 'Models', blurb: 'Model cards — licences, sizes, per-class accuracy' },
  { slug: 'datasets', source: 'docs/DATASETS.md', nav: 'Models and data',
    icon: 'ic_reports', title: 'Datasets',
    blurb: 'Every dataset, its licence, and what it does not cover' },
  { slug: 'crop-coverage', source: 'docs/CROP_COVERAGE.md',
    nav: 'Models and data', icon: 'ic_crop_field', title: 'Crop coverage',
    blurb: 'Which crops work offline, which need a connection' },

  { slug: 'weather-and-maps', source: 'docs/WEATHER_AND_MAPS.md',
    nav: 'Features', icon: 'ic_weather', title: 'Weather and maps',
    blurb: 'Open-Meteo, OpenStreetMap, tile caching, measured connection quality' },
  { slug: 'local-language', source: 'docs/LOCAL_LANGUAGE.md', nav: 'Features',
    icon: 'ic_assistant', title: 'Local language',
    blurb: 'Tetun — scope, vocabulary, and the limits of the approach' },
  { slug: 'online-backend', source: 'docs/ONLINE_BACKEND.md', nav: 'Features',
    icon: 'ic_sync', title: 'Online backend',
    blurb: 'FastAPI on Lightsail, Claude Haiku, and the guardrails' },

  { slug: 'testing', source: 'docs/TESTING.md', nav: 'Quality',
    icon: 'ic_check',
    title: 'Testing', blurb: 'The suites, and the airplane-mode matrix' },

  { slug: 'app', source: 'Lafaek AI Farm/README.md', nav: 'The app',
    icon: 'ic_farm', title: 'Running the app',
    blurb: 'Build it, test it, and the offline demo walkthrough' },
  { slug: 'asset-tools', source: 'Lafaek AI Farm/mobile-app/tools/assets/README.md',
    nav: 'The app', icon: 'ic_gallery', title: 'Asset tools',
    blurb: 'How the sprite sheets and the launcher icon are produced' },
];

/** Artwork taken from the app, copied into `public/brand/`. */
const APP_IMAGES = 'Lafaek AI Farm/mobile-app/assets/images';
const BRAND = {
  'logo.png': `${APP_IMAGES}/logo.png`,
  'offline.png': `${APP_IMAGES}/icons/ic_offline.png`,
};

const IMAGE_RE = /\.(png|jpe?g|gif|svg|webp)$/i;

// ----------------------------------------------------------------- git ----
function tracked() {
  const out = execFileSync('git', ['ls-files', '-z'], {
    cwd: REPO, maxBuffer: 64 * 1024 * 1024,
  }).toString('utf8');
  return new Set(out.split('\0').filter(Boolean));
}

/** Belt and braces: a file can be tracked *and* listed in .gitignore. */
function ignored(paths) {
  if (!paths.length) return new Set();
  try {
    const out = execFileSync('git', ['check-ignore', '--stdin'], {
      cwd: REPO, input: paths.join('\n'), maxBuffer: 16 * 1024 * 1024,
    }).toString('utf8');
    return new Set(out.split('\n').filter(Boolean));
  } catch {
    return new Set();           // exit code 1 simply means "none are ignored"
  }
}

// ------------------------------------------------------------- helpers ----
const warnings = [];
const warn = (m) => { warnings.push(m); console.warn(`  ! ${m}`); };

/** Repo-relative path for `href` as written inside `fromDoc`. */
function resolveFrom(fromDoc, href) {
  const dir = path.posix.dirname(fromDoc.split(path.sep).join('/'));
  return path.posix.normalize(path.posix.join(dir, href));
}

function titleOf(markdown, fallback) {
  const m = markdown.match(/^#\s+(.+)$/m);
  return m ? m[1].trim() : fallback;
}

/** Plain text for the search index: no code, no tables, no markup. */
function searchText(markdown) {
  return markdown
    .replace(/```[\s\S]*?```/g, ' ')
    .replace(/^\s*\|.*$/gm, ' ')
    .replace(/!\[[^\]]*\]\([^)]*\)/g, ' ')
    .replace(/\[([^\]]+)\]\([^)]*\)/g, '$1')
    .replace(/[#>*_`~]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

// ---------------------------------------------------------------- main ----
const trackedFiles = tracked();
const bySource = new Map(DOCS.map((d) => [d.source, d]));
const assetsToCopy = new Map();   // repo-relative -> public path

const present = DOCS.filter((d) => {
  if (!trackedFiles.has(d.source)) {
    warn(`skipped ${d.source} — not tracked by git (ignored, or never added)`);
    return false;
  }
  return true;
});

const ignoredDocs = ignored(present.map((d) => d.source));
const docs = present.filter((d) => {
  if (ignoredDocs.has(d.source)) {
    warn(`skipped ${d.source} — matched by .gitignore`);
    return false;
  }
  return true;
});

const routeOf = (source) => {
  const d = bySource.get(source);
  if (!d || !docs.includes(d)) return null;
  return d.slug === '' ? '/' : `/${d.slug}`;
};

/**
 * Rewrite one document's links.
 *
 * - a link to another published document  -> its route, anchors preserved
 * - a link to an image                    -> /content-assets/..., copied
 * - a link to a tracked file or directory -> the file on GitHub
 * - anything else (excluded, or missing)  -> the label, as plain text
 */
function rewrite(doc, markdown) {
  const linkRe = /(!?)\[([^\]]*)\]\(([^)\s]+)(\s+"[^"]*")?\)/g;
  return markdown.replace(linkRe, (whole, bang, label, href, titleAttr) => {
    const title = titleAttr ?? '';

    if (/^(https?:|mailto:|#)/.test(href)) return whole;

    const [rawPath, hash = ''] = href.split('#');
    const anchor = hash ? `#${hash}` : '';

    if (!rawPath) return whole;

    const target = resolveFrom(doc.source, decodeURIComponent(rawPath));

    if (bang || IMAGE_RE.test(target)) {
      if (!trackedFiles.has(target)) {
        warn(`${doc.source}: image not tracked, dropped — ${rawPath}`);
        return bang ? '' : label;
      }
      const pub = `/content-assets/${target.replace(/[^\w./-]/g, '_')}`;
      assetsToCopy.set(target, pub);
      return `${bang}[${label}](${pub}${title})`;
    }

    const route = routeOf(target);
    if (route) return `[${label}](${route}${anchor}${title})`;

    const isDir = rawPath.endsWith('/');
    const dirPrefix = isDir ? `${target.replace(/\/$/, '')}/` : null;
    const exists = isDir
      ? [...trackedFiles].some((f) => f.startsWith(dirPrefix))
      : trackedFiles.has(target);

    if (exists) {
      const kind = isDir ? 'tree' : 'blob';
      const url = `${REPO_URL}/${kind}/main/${target.split('/')
        .map(encodeURIComponent).join('/')}`;
      return `[${label}](${url}${title})`;
    }

    warn(`${doc.source}: link to an excluded or missing file — ${rawPath}`);
    return label;                               // degrade to plain text
  });
}

const manifest = { generated: new Date().toISOString(), repo: REPO_URL,
                   apk: APK_URL, docs: [] };

const BRAND_DIR = path.join(SITE, 'public', 'brand');

if (!CHECK_ONLY) {
  fs.rmSync(CONTENT, { recursive: true, force: true });
  fs.rmSync(ASSETS, { recursive: true, force: true });
  fs.rmSync(BRAND_DIR, { recursive: true, force: true });
  fs.mkdirSync(CONTENT, { recursive: true });
  fs.mkdirSync(BRAND_DIR, { recursive: true });
}

/** Copy one of the app's images into `public/brand/`, by its published name. */
function copyBrand(name, source) {
  if (!trackedFiles.has(source)) {
    warn(`brand artwork not tracked, skipped — ${source}`);
    return false;
  }
  if (!CHECK_ONLY) {
    fs.copyFileSync(path.join(REPO, source), path.join(BRAND_DIR, name));
  }
  return true;
}

let brandCount = 0;
for (const [name, source] of Object.entries(BRAND)) {
  if (copyBrand(name, source)) brandCount += 1;
}
for (const doc of DOCS) {
  if (!doc.icon) continue;
  if (copyBrand(`${doc.icon}.png`, `${APP_IMAGES}/icons/${doc.icon}.png`)) {
    brandCount += 1;
  }
}

console.log(`Syncing ${docs.length} documents from ${REPO}`);

for (const doc of docs) {
  const raw = fs.readFileSync(path.join(REPO, doc.source), 'utf8');
  const body = rewrite(doc, raw);
  const name = `${doc.slug || 'index'}.md`;

  if (!CHECK_ONLY) fs.writeFileSync(path.join(CONTENT, name), body, 'utf8');

  manifest.docs.push({
    slug: doc.slug,
    route: doc.slug === '' ? '/' : `/${doc.slug}`,
    file: name,
    nav: doc.nav,
    icon: doc.icon ? `brand/${doc.icon}.png` : null,
    title: doc.title ?? titleOf(raw, doc.slug),
    blurb: doc.blurb ?? '',
    source: doc.source,
    sourceUrl: `${REPO_URL}/blob/main/${doc.source.split('/')
      .map(encodeURIComponent).join('/')}`,
    words: searchText(raw).split(' ').length,
  });
  console.log(`  ${doc.source}  ->  ${name}`);
}

for (const [from, to] of assetsToCopy) {
  if (CHECK_ONLY) continue;
  const dest = path.join(SITE, 'public', to.replace(/^\//, ''));
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(path.join(REPO, from), dest);
}
console.log(`  ${assetsToCopy.size} images -> public/content-assets/`);
console.log(`  ${brandCount} app images -> public/brand/`);

if (!CHECK_ONLY) {
  fs.writeFileSync(path.join(CONTENT, 'manifest.json'),
    `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
}

const excluded = [...trackedFiles]
  .filter((f) => /\.mdx?$/i.test(f) && !bySource.has(f));
if (excluded.length) {
  console.log(`\n  not published (tracked, but not in the DOCS list):`);
  for (const f of excluded) console.log(`    ${f}`);
}

console.log(`\nDone — ${docs.length} documents, ${assetsToCopy.size} images,` +
            ` ${warnings.length} warning${warnings.length === 1 ? '' : 's'}.`);
if (CHECK_ONLY) console.log('(--check: nothing was written)');
