import { createRouter, createWebHistory } from 'vue-router';

import DocPage from './components/DocPage.vue';
import NotFound from './components/NotFound.vue';
import { docs } from './content.js';

const routes = docs.map((doc) => ({
  path: doc.route,
  name: doc.slug || 'home',
  component: DocPage,
  props: { route: doc.route },
  meta: { title: doc.title },
}));

routes.push({ path: '/:pathMatch(.*)*', name: 'not-found', component: NotFound });

export const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior(to, from, saved) {
    if (saved) return saved;
    if (to.hash) return { el: to.hash, top: 90, behavior: 'smooth' };
    if (to.path !== from.path) return { top: 0 };
    return undefined;
  },
});

router.afterEach((to) => {
  document.title = to.meta.title
    ? `${to.meta.title} — Lafaek AI Farm`
    : 'Lafaek AI Farm — documentation';
});
