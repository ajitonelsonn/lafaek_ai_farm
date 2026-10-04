<script setup>
import { onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { useRoute } from 'vue-router';

import SearchDialog from './components/SearchDialog.vue';
import { brand, groups, meta } from './content.js';

const route = useRoute();
const sidebarOpen = ref(false);
const searchOpen = ref(false);
const theme = ref('auto');

const THEMES = ['auto', 'light', 'dark'];
const LABEL = { auto: 'Auto', light: 'Light', dark: 'Dark' };

function applyTheme(value) {
  if (value === 'auto') document.documentElement.removeAttribute('data-theme');
  else document.documentElement.setAttribute('data-theme', value);
  try {
    localStorage.setItem('lafaek-docs-theme', value);
  } catch {
    /* private browsing, or storage blocked — the choice simply will not stick */
  }
}

function cycleTheme() {
  theme.value = THEMES[(THEMES.indexOf(theme.value) + 1) % THEMES.length];
  applyTheme(theme.value);
}

function onKey(event) {
  const typing = /^(INPUT|TEXTAREA|SELECT)$/.test(event.target.tagName);
  if (event.key === '/' && !typing) {
    event.preventDefault();
    searchOpen.value = true;
  } else if (event.key.toLowerCase() === 'k' && (event.metaKey || event.ctrlKey)) {
    event.preventDefault();
    searchOpen.value = true;
  }
}

onMounted(() => {
  try {
    const saved = localStorage.getItem('lafaek-docs-theme');
    if (THEMES.includes(saved)) theme.value = saved;
  } catch {
    /* unreadable storage is not an error here */
  }
  applyTheme(theme.value);
  document.addEventListener('keydown', onKey);
});

onBeforeUnmount(() => document.removeEventListener('keydown', onKey));

watch(() => route.fullPath, () => { sidebarOpen.value = false; });
</script>

<template>
  <header class="topbar">
    <button
      class="icon-btn menu-btn"
      aria-label="Toggle navigation"
      @click="sidebarOpen = !sidebarOpen"
    >☰</button>

    <RouterLink to="/" class="brand">
      <img class="brand-mark" :src="brand.logo" alt="" width="30" height="30" />
      <span class="brand-text">
        <strong>Lafaek AI Farm</strong>
        <small>Documentation</small>
      </span>
    </RouterLink>

    <div class="topbar-spacer" />

    <button class="search-trigger" @click="searchOpen = true">
      <span>Search</span>
      <kbd>/</kbd>
    </button>

    <button class="icon-btn" :title="`Theme: ${LABEL[theme]}`"
            aria-label="Change theme" @click="cycleTheme">
      <span v-if="theme === 'auto'">◐</span>
      <span v-else-if="theme === 'light'">☀</span>
      <span v-else>☾</span>
    </button>

    <a class="topbar-link" :href="meta.repo" target="_blank"
       rel="noopener noreferrer">GitHub</a>
  </header>

  <div class="shell">
    <aside class="sidebar" :class="{ open: sidebarOpen }">
      <a class="apk-cta" :href="meta.apk" target="_blank"
         rel="noopener noreferrer">
        <img :src="brand.logo" alt="" width="26" height="26" />
        <span>
          Download the APK
          <small>Android 8+ · arm64</small>
        </span>
      </a>

      <nav>
        <div v-for="group in groups" :key="group.name" class="nav-group">
          <p class="nav-group-title">{{ group.name }}</p>
          <RouterLink
            v-for="doc in group.docs"
            :key="doc.route"
            :to="doc.route"
            class="nav-link"
          >
            <img v-if="doc.icon" :src="doc.icon" alt="" width="18" height="18" />
            <span>{{ doc.title }}</span>
          </RouterLink>
        </div>
      </nav>

      <p class="sidebar-foot">
        <img :src="brand.offline" alt="" width="22" height="22" />
        Every page here is the repository's own Markdown, synced at build time.
        If git does not track a file, it is not published.
      </p>
    </aside>

    <div
      v-if="sidebarOpen"
      class="sidebar-scrim"
      @click="sidebarOpen = false"
    />

    <main class="content">
      <RouterView />
    </main>
  </div>

  <SearchDialog :open="searchOpen" @close="searchOpen = false" />
</template>
