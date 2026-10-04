# Documentation site

A Vue 3 site that publishes **the repository's own Markdown**. It holds no prose
of its own, so it cannot drift from the documentation it displays.

```bash
npm install
npm run dev        # sync, then serve on :5173
npm run build      # sync, then build to dist/
npm run check      # report what would be synced, write nothing
```

## How it decides what to publish

Two rules, in this order:

1. **The document is listed in `DOCS` in [`scripts/sync.mjs`](scripts/sync.mjs)** —
   which also gives it its route, its sidebar group, and its icon.
2. **git tracks it.** If a file is matched by `.gitignore`, it is not tracked,
   so it is not published. `docs/CHANGELOG.md`, `hackathon.md`,
   `lightshail_setup/` and the rest drop out on their own; the script never
   needs to know their names.

That second rule is also applied to **links**. A link pointing at an excluded
document degrades to plain text rather than becoming a dead link, and the sync
prints a warning saying so.

| In the Markdown | On the site |
|---|---|
| `[DATASETS.md](DATASETS.md)` | a route — `/datasets` |
| `![x](diagrams/01-….png)` | copied to `public/content-assets/`, rebased for the deploy path |
| `[screenshots/](screenshots/)` | the folder on GitHub |
| `[CHANGELOG.md](CHANGELOG.md)` | plain text, because git does not track it |
| `https://…` | untouched, opened in a new tab |

## Where the artwork comes from

The logo, the sidebar icons and the offline glyph are copied out of
`Lafaek AI Farm/mobile-app/assets/images/` at sync time, so the site wears the
app's own artwork rather than inventing a second visual language. Change an icon
in the app and it changes here.

## Adding a page

Add an entry to `DOCS` in `scripts/sync.mjs`:

```js
{ slug: 'my-page', source: 'docs/MY_PAGE.md', nav: 'Design',
  icon: 'ic_knowledge', title: 'My page', blurb: 'One line for the header' },
```

`icon` is any filename from the app's icon folder, without the extension. The
route, the sidebar entry, the search index and the previous/next links all
follow from that one object.

## Layout

```
scripts/sync.mjs     the only thing that reads the repository
src/content/         generated — Markdown + manifest.json  (git-ignored)
public/content-assets/  generated — images from the docs   (git-ignored)
public/brand/        generated — artwork from the app      (git-ignored)
src/markdown.js      markdown-it, highlighting, anchors, asset rebasing
src/content.js       the generated content, as the app consumes it
src/App.vue          shell: topbar, sidebar, theme, search
src/components/      DocPage, TableOfContents, SearchDialog, ImageLightbox
```

Nothing under `src/content/`, `public/content-assets/` or `public/brand/` is
committed: a second copy of the documentation in the repository would be free to
go stale, which is the problem this site exists to avoid.

## Deploying

[`.github/workflows/docs-site.yml`](../.github/workflows/docs-site.yml) builds
and publishes to GitHub Pages on every push that touches the documentation.
Enable it once under **Settings → Pages → Source → GitHub Actions**.

For any other host, build with the sub-path it will be served from:

```bash
BASE_PATH=/lafaek_ai_farm/ npm run build
```

Serve `dist/`, with `404.html` as a copy of `index.html` so that deep links
survive a reload.
