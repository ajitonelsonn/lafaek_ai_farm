<script setup>
import { onBeforeUnmount, onMounted } from 'vue';

defineProps({ src: String, alt: String });
const emit = defineEmits(['close']);

const onKey = (e) => { if (e.key === 'Escape') emit('close'); };

onMounted(() => {
  document.addEventListener('keydown', onKey);
  document.body.style.overflow = 'hidden';
});
onBeforeUnmount(() => {
  document.removeEventListener('keydown', onKey);
  document.body.style.overflow = '';
});
</script>

<template>
  <!-- The diagrams carry small type, so they need to be openable full-size. -->
  <div class="lightbox" @click="emit('close')">
    <img :src="src" :alt="alt" />
    <p v-if="alt" class="lightbox-caption">{{ alt }}</p>
    <button class="lightbox-close" aria-label="Close">×</button>
  </div>
</template>
