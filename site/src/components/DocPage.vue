<script setup>
import { computed, nextTick, ref, watch } from 'vue';
import { useRouter } from 'vue-router';

import { byRoute, neighbours } from '../content.js';
import { headings, render } from '../markdown.js';
import ImageLightbox from './ImageLightbox.vue';
import TableOfContents from './TableOfContents.vue';

const props = defineProps({ route: { type: String, required: true } });
const router = useRouter();

const doc = computed(() => byRoute.get(props.route));
const html = computed(() => (doc.value ? render(doc.value.markdown) : ''));
const toc = computed(() => (html.value ? headings(html.value) : []));
const around = computed(() => neighbours(props.route));

const article = ref(null);
const zoomed = ref(null);

/**
 * The rendered Markdown contains ordinary anchors. Internal ones are handed to
 * the router here rather than rewritten at render time, which keeps the
 * Markdown faithful to the file in the repository.
 */
function onClick(event) {
  const img = event.target.closest('.markdown-body img');
  if (img) {
    zoomed.value = { src: img.getAttribute('src'), alt: img.alt };
    return;
  }

  const link = event.target.closest('a');
  if (!link || link.target === '_blank' || event.metaKey || event.ctrlKey) return;

  const href = link.getAttribute('href') ?? '';
  if (!href.startsWith('/') || href.startsWith('/content-assets/')) return;

  event.preventDefault();
  router.push(href);
}

watch(html, async () => {
  await nextTick();
  article.value?.scrollTo?.({ top: 0 });
});
</script>

<template>
  <div v-if="doc" class="doc-layout">
    <article class="doc">
      <header class="doc-head">
        <p class="nav-crumb">
          <img v-if="doc.icon" :src="doc.icon" alt="" width="18" height="18" />
          {{ doc.nav }}
        </p>
        <p v-if="doc.blurb" class="blurb">{{ doc.blurb }}</p>
        <a class="source-link" :href="doc.sourceUrl" target="_blank"
           rel="noopener noreferrer">
          {{ doc.source }} <span aria-hidden="true">↗</span>
        </a>
      </header>

      <div
        ref="article"
        class="markdown-body"
        v-html="html"
        @click="onClick"
      />

      <nav class="pager">
        <RouterLink v-if="around.prev" class="pager-link prev"
                    :to="around.prev.route">
          <span class="pager-label">Previous</span>
          <span class="pager-title">{{ around.prev.title }}</span>
        </RouterLink>
        <span v-else />
        <RouterLink v-if="around.next" class="pager-link next"
                    :to="around.next.route">
          <span class="pager-label">Next</span>
          <span class="pager-title">{{ around.next.title }}</span>
        </RouterLink>
      </nav>
    </article>

    <TableOfContents :headings="toc" />

    <ImageLightbox
      v-if="zoomed"
      :src="zoomed.src"
      :alt="zoomed.alt"
      @close="zoomed = null"
    />
  </div>
</template>
