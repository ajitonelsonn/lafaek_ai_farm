/**
 * Markdown rendering.
 *
 * The documents were written to be read as plain files in the repository, so
 * the renderer's job is to stay faithful to them: no rewriting of content, only
 * the affordances a browser can add — anchored headings, highlighted code, and
 * external links that announce themselves.
 */
import hljs from 'highlight.js/lib/common';
import MarkdownIt from 'markdown-it';
import anchor from 'markdown-it-anchor';

export const md = new MarkdownIt({
  html: false,            // the sources are trusted, but nothing needs raw HTML
  linkify: true,
  typographer: false,     // the prose already uses real dashes and quotes
  highlight(code, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return hljs.highlight(code, { language: lang, ignoreIllegals: true })
          .value;
      } catch {
        /* fall through to plain text */
      }
    }
    return '';
  },
});

md.use(anchor, {
  level: [2, 3],
  permalink: anchor.permalink.linkInsideHeader({
    symbol: '#',
    placement: 'after',
    class: 'heading-anchor',
    ariaHidden: true,
  }),
});

// Mark external links so they open in a new tab and can be styled.
const defaultLink = md.renderer.rules.link_open
  ?? ((tokens, i, options, _env, self) => self.renderToken(tokens, i, options));

md.renderer.rules.link_open = (tokens, i, options, env, self) => {
  const href = tokens[i].attrGet('href') ?? '';
  if (/^https?:/i.test(href)) {
    tokens[i].attrSet('target', '_blank');
    tokens[i].attrSet('rel', 'noopener noreferrer');
    tokens[i].attrJoin('class', 'external');
  }
  return defaultLink(tokens, i, options, env, self);
};

// Wrap tables so a wide one scrolls inside the column instead of stretching it.
md.renderer.rules.table_open = () => '<div class="table-scroll"><table>';
md.renderer.rules.table_close = () => '</table></div>';

/**
 * The sync script writes image paths rooted at `/content-assets/`. On GitHub
 * Pages the site is served from a sub-path, so they are rebased here rather
 * than in the Markdown, which keeps the synced files deployment-agnostic.
 */
export const asset = (p) =>
  `${import.meta.env.BASE_URL.replace(/\/$/, '')}/${p.replace(/^\//, '')}`;

const defaultImage = md.renderer.rules.image;
md.renderer.rules.image = (tokens, i, options, env, self) => {
  const src = tokens[i].attrGet('src') ?? '';
  if (src.startsWith('/')) tokens[i].attrSet('src', asset(src));
  tokens[i].attrSet('loading', 'lazy');
  return defaultImage(tokens, i, options, env, self);
};

export function render(markdown) {
  return md.render(markdown);
}

/**
 * Headings for the table of contents, read back out of the rendered HTML so the
 * ids can never disagree with the ones markdown-it-anchor actually produced.
 */
export function headings(html) {
  const doc = new DOMParser().parseFromString(html, 'text/html');
  return [...doc.querySelectorAll('h2[id], h3[id]')].map((el) => ({
    id: el.id,
    level: Number(el.tagName[1]),
    text: el.textContent.replace(/#$/, '').trim(),
  }));
}
