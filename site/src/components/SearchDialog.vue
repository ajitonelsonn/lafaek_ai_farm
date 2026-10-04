<script setup>
import { computed, nextTick, ref, watch } from 'vue';
import { useRouter } from 'vue-router';

import { docs } from '../content.js';

const props = defineProps({ open: Boolean });
const emit = defineEmits(['close']);
const router = useRouter();

const query = ref('');
const cursor = ref(0);
const input = ref(null);

/**
 * Searching happens over the plain prose, not the rendered HTML, so a hit in a
 * code block or a table border cannot masquerade as a hit in the text.
 */
const index = docs.map((doc) => ({
  doc,
  text: doc.markdown
    .replace(/```[\s\S]*?```/g, ' ')
    .replace(/!\[[^\]]*\]\([^)]*\)/g, ' ')
    .replace(/\[([^\]]+)\]\([^)]*\)/g, '$1')
    .replace(/[#>*_`|~-]/g, ' ')
    .replace(/\s+/g, ' '),
}));

const results = computed(() => {
  const q = query.value.trim().toLowerCase();
  if (q.length < 2) return [];

  const out = [];
  for (const { doc, text } of index) {
    const haystack = text.toLowerCase();
    const titleHit = doc.title.toLowerCase().includes(q);
    const at = haystack.indexOf(q);
    if (!titleHit && at === -1) continue;

    let excerpt = doc.blurb;
    if (at !== -1) {
      const from = Math.max(0, at - 60);
      excerpt = `${from > 0 ? '…' : ''}${text.slice(from, at + q.length + 90).trim()}…`;
    }

    const count = at === -1 ? 0 : haystack.split(q).length - 1;
    out.push({ doc, excerpt, score: (titleHit ? 1000 : 0) + count });
  }
  return out.sort((a, b) => b.score - a.score).slice(0, 8);
});

watch(results, () => { cursor.value = 0; });

watch(() => props.open, async (open) => {
  if (!open) return;
  query.value = '';
  cursor.value = 0;
  await nextTick();
  input.value?.focus();
});

function go(result) {
  if (!result) return;
  router.push(result.doc.route);
  emit('close');
}

function onKey(event) {
  if (event.key === 'Escape') return emit('close');
  if (event.key === 'ArrowDown') {
    event.preventDefault();
    cursor.value = Math.min(cursor.value + 1, results.value.length - 1);
  } else if (event.key === 'ArrowUp') {
    event.preventDefault();
    cursor.value = Math.max(cursor.value - 1, 0);
  } else if (event.key === 'Enter') {
    event.preventDefault();
    go(results.value[cursor.value]);
  }
}
</script>

<template>
  <div v-if="open" class="search-backdrop" @click.self="emit('close')">
    <div class="search-panel" role="dialog" aria-label="Search documentation">
      <input
        ref="input"
        v-model="query"
        class="search-input"
        type="search"
        placeholder="Search the documentation…"
        autocomplete="off"
        spellcheck="false"
        @keydown="onKey"
      />

      <ul v-if="results.length" class="search-results">
        <li v-for="(r, i) in results" :key="r.doc.route">
          <button
            class="search-result"
            :class="{ active: i === cursor }"
            @click="go(r)"
            @mouseenter="cursor = i"
          >
            <img v-if="r.doc.icon" class="r-icon" :src="r.doc.icon" alt=""
                 width="22" height="22" />
            <span class="r-title">{{ r.doc.title }}</span>
            <span class="r-nav">{{ r.doc.nav }}</span>
            <span class="r-excerpt">{{ r.excerpt }}</span>
          </button>
        </li>
      </ul>

      <p v-else-if="query.trim().length >= 2" class="search-empty">
        Nothing matches “{{ query.trim() }}”.
      </p>
      <p v-else class="search-hint">
        Type at least two characters. <kbd>↑</kbd><kbd>↓</kbd> to move,
        <kbd>↵</kbd> to open, <kbd>esc</kbd> to close.
      </p>
    </div>
  </div>
</template>
