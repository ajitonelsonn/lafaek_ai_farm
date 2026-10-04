/**
 * The synced content, as the app sees it.
 *
 * Everything here is produced by `scripts/sync.mjs` at build time, so the site
 * can never drift from the repository: there is no second copy of the prose to
 * keep up to date.
 */
import manifest from './content/manifest.json';
import { asset } from './markdown.js';

const files = import.meta.glob('./content/*.md', {
  query: '?raw',
  import: 'default',
  eager: true,
});

/** Published documents, in navigation order, each carrying its Markdown. */
export const docs = manifest.docs.map((doc) => ({
  ...doc,
  icon: doc.icon ? asset(doc.icon) : null,
  markdown: files[`./content/${doc.file}`] ?? '',
}));

/** The app's own artwork, copied into `public/brand/` by the sync script. */
export const brand = {
  logo: asset('brand/logo.png'),
  offline: asset('brand/offline.png'),
};

export const byRoute = new Map(docs.map((d) => [d.route, d]));

/** Documents grouped into the sidebar's sections, order preserved. */
export const groups = docs.reduce((acc, doc) => {
  const group = acc.find((g) => g.name === doc.nav);
  if (group) group.docs.push(doc);
  else acc.push({ name: doc.nav, docs: [doc] });
  return acc;
}, []);

export const meta = {
  generated: manifest.generated,
  repo: manifest.repo,
  apk: manifest.apk,
};

/** Previous and next document, for the footer links. */
export function neighbours(route) {
  const i = docs.findIndex((d) => d.route === route);
  if (i === -1) return { prev: null, next: null };
  return { prev: docs[i - 1] ?? null, next: docs[i + 1] ?? null };
}
