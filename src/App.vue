<template>
  <v-app>
    <v-app-bar
      app
      color="primary"
      dark
    >
      <div class="d-flex align-center">
        jTools
      </div>

    </v-app-bar>

    <v-main>
      <JTools/>
    </v-main>
  </v-app>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import JTools from './components/JTools.vue';

@Component({
  components: {
    JTools,
  },
})
export default class App extends Vue {}
</script>
