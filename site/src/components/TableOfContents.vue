<script setup>
import { onBeforeUnmount, ref, watch } from 'vue';

const props = defineProps({ headings: { type: Array, default: () => [] } });

const active = ref('');
let observer = null;

function observe() {
  observer?.disconnect();
  if (!props.headings.length) return;

  // A heading counts as "current" once it reaches the top quarter of the
  // viewport, which matches where the eye actually is while reading.
  observer = new IntersectionObserver(
    (entries) => {
      const visible = entries
        .filter((e) => e.isIntersecting)
        .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
      if (visible.length) active.value = visible[0].target.id;
    },
    { rootMargin: '-80px 0px -75% 0px', threshold: 0 },
  );

  for (const h of props.headings) {
    const el = document.getElementById(h.id);
    if (el) observer.observe(el);
  }
}

watch(() => props.headings, () => {
  active.value = props.headings[0]?.id ?? '';
  requestAnimationFrame(observe);
}, { immediate: true, flush: 'post' });

onBeforeUnmount(() => observer?.disconnect());
</script>

<template>
  <aside v-if="headings.length > 2" class="toc">
    <p class="toc-title">On this page</p>
    <nav>
      <a
        v-for="h in headings"
        :key="h.id"
        :href="`#${h.id}`"
        class="toc-link"
        :class="[`level-${h.level}`, { active: active === h.id }]"
      >{{ h.text }}</a>
    </nav>
  </aside>
</template>
