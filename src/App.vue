<template>
    <v-app>
        <v-app-bar app color="primary" dark>
            <v-toolbar-title>jTools</v-toolbar-title>
            <v-spacer></v-spacer>
            <span>
                Ensure you have the
                <a class="white--text"
                    href="https://chrome.google.com/webstore/detail/allow-cors-access-control/lhobafahddgcelffkeicbaginigeejlf?hl=en"
                >
                    Chrome CORS plugin enabled</a>
            </span>
        </v-app-bar>

        <v-main>
            <JTools />
        </v-main>
    </v-app>
</template>

<script lang="ts">
import { Component, Vue } from "vue-property-decorator";
import JTools from "./components/JTools.vue";

@Component({
    components: {
        JTools,
    },
})
export default class App extends Vue {}
</script>
