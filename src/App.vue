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

<script>
import JTools from './components/JTools';

export default {
  name: 'App',

  components: {
    JTools,
  },

  data: () => ({
    //
  }),
};
</script>
