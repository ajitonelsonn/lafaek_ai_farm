<script setup>
import { docs } from '../content.js';
</script>

<template>
  <div class="doc-layout">
    <article class="doc">
      <h1>Not found</h1>
      <p class="blurb">
        There is no page at this address. It may have been a link to a document
        that is not published here — the site only publishes what git tracks.
      </p>
      <ul class="notfound-list">
        <li v-for="doc in docs" :key="doc.route">
          <RouterLink :to="doc.route">{{ doc.title }}</RouterLink>
          <span v-if="doc.blurb"> — {{ doc.blurb }}</span>
        </li>
      </ul>
    </article>
  </div>
</template>
