import { fileURLToPath, URL } from 'node:url';

import vue from '@vitejs/plugin-vue';
import { defineConfig } from 'vite';

// GitHub Pages serves this repository from a sub-path, so the base is set from
// the environment at build time:  BASE_PATH=/lafaek_ai_farm/ npm run build
export default defineConfig({
  base: process.env.BASE_PATH || '/',
  plugins: [vue()],
  resolve: {
    alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) },
  },
  build: {
    outDir: 'dist',
    // The diagrams are large PNGs; keep them as files rather than inlining.
    assetsInlineLimit: 2048,
  },
});
