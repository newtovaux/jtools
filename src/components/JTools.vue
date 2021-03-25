<template>
    <v-container>
        <v-row class="mt-3">
            <v-col cols="8">
                <v-textarea
                    outlined
                    name="input-7-4"
                    :label="listlabel"
                    placeholder="email@domain.com or http://www.web.com"
                    v-model="inputs"
                    hide-details="true"
                    class="elevation-1"
                ></v-textarea>
            </v-col>
            <v-col cols="4">
                <v-textarea
                    outlined
                    name="input-7-4"
                    :label="emaillabel"
                    placeholder="gmail.com"
                    v-model="emailsprovidersinput"
                    hide-details="true"
                    class="elevation-1"
                ></v-textarea>
            </v-col>
        </v-row>
        <v-row>
            <v-col>
                <v-progress-linear
                    height="25"
                    :value="progress()"
                    :color="progressColor"
                    class="elevation-1"
                >
                    <template v-slot:default="{ value }">
                        <strong class="mr-2">{{ Math.ceil(value) }}%</strong>({{
                            processedoutput()
                        }}
                        / {{ processedinput() }})
                    </template>
                </v-progress-linear>
            </v-col>
        </v-row>
        <v-row>
            <v-col>
                <v-card>
                    <v-card-title>
                        <v-btn
                            class="ma-1"
                            depressed
                            color="secondary"
                            @click="clear()"
                        >
                            Clear
                        </v-btn>
                        <v-btn
                            class="ma-1"
                            depressed
                            color="primary"
                            @click="process()"
                        >
                            Process
                        </v-btn>
                        <v-btn
                            class="ma-1"
                            depressed
                            color="secondary"
                            @click="excel()"
                        >
                            Export
                        </v-btn>
                        <v-spacer></v-spacer>
                        <v-text-field
                            v-model="search"
                            append-icon="mdi-magnify"
                            label="Search"
                            single-line
                            hide-details
                        ></v-text-field>
                    </v-card-title>
                    <v-data-table
                        dense
                        :headers="headers"
                        :items="items"
                        :search="search"
                        item-key="id"
                        class="elevation-1"
                    >
                        <template v-slot:[`item.email`]="{ item }">
                            <v-chip
                                small
                                :color="getEmailColor(item.email)"
                                dark
                            >
                                {{ item.email }}
                            </v-chip>
                        </template>
                        <template v-slot:[`item.resolves_http`]="{ item }">
                            <v-chip
                                small
                                :color="getResponseColor(item.resolves_http)"
                                dark
                            >
                                {{ item.resolves_http }}
                            </v-chip>
                        </template>
                        <template v-slot:[`item.resolves_https`]="{ item }">
                            <v-chip
                                small
                                :color="getResponseColor(item.resolves_https)"
                                dark
                            >
                                {{ item.resolves_https }}
                            </v-chip>
                        </template>
                    </v-data-table>
                </v-card>
            </v-col>
        </v-row>
    </v-container>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, computed } from "@vue/composition-api";
import { v4 as uuidv4 } from "uuid";
import axios from "axios";

let { json2excel } = require("js2excel");

interface Entity {
    id: string;
    input: string;
    url: string;
    email: string;
    resolves_http: string;
    resolves_https: string,
    meta: string;
    len: number;
}

export default defineComponent({
    name: "jTools",

    metaInfo: {
        title: "jTools",
    },

    setup() {
        const headers = [
            {
                text: "Input",
                align: "start",
                value: "input",
            },
            { text: "Processed URL", value: "url" },
            { text: "Matches Email Providers", value: "email" },
            { text: "Resolves http?", value: "resolves_http" },
            { text: "Resolves https?", value: "resolves_https" },
            { text: "Title", value: "meta" },
            { text: "Response Size (B)", value: "len" },
        ];

        const items = ref<Entity[]>([]);

        const inputs = ref(
            "me@my-website.co.uk\nwww.my-website.com\nhttp://my-website.com\nme@gmail.com\nmainbox@email.com\nwhwew@sdfgdgref.com\nhttp://www.yahoo.com\nhttps://www.secure.com\nwww.google.com\nthisisnotreallyadomainisitno.co.ac.uk\nwww.domain.com/something\n"
        );

        const emailsprovidersinput = ref("gmail.com\nhotmail.com\n");

        const emailproviders = ref<string[]>([]);

        const search = ref("");

        const processedinput = () => {
            let spl: Array<string> = inputs.value.split("\n");
            let count: number = 0;
            spl.forEach((element: string) => {
                if (element.trim() !== "") {
                    count++;
                }
            });
            return count;
        };

        const processedoutput = () => {
            let len: number = items.value.length;
            return len;
        };

        const progress = () => {
            // Prevents division by zero / NaN
            if (processedinput() === 0) {
                return 0;
            } else return (processedoutput() / processedinput()) * 100;
        };

        const progressColor = computed(() => {
            return progress() < 100 ? "primary" : "green";
        });

        const listlabel = computed(() => {
            return `Email or URL list (${processedinput()})`;
        });

        const emaillabel = computed(() => {
            return `Email providers (${processedemailproviders()})`;
        });

        const processedemailproviders = () => {
            let spl: Array<string> = emailsprovidersinput.value.split("\n");
            let count: number = 0;
            spl.forEach((element: string) => {
                if (element.trim() !== "") {
                    count++;
                }
            });
            return count;
        };

        const clear = () => {
            items.value = [];
            console.clear();
        };

        const getEmailColor = (email: string) => {
            if (email === "Yes") return "green";
            else return "red";
        };

        const getResponseColor = (response: string) => {
            if (response === "Yes") return "green";
            else if (response === "No") return "red";
            else return "orange";
        };

        const test = async (input: string) => {
            let domain = "";
            let email_regex = input.match(/(.*)@(?<domain>.*)/);
            let url_regex = input.match(
                /^(?:https?:\/\/)?(?:[^@\n]+@)?(?:www\.)?(?<domain>[^:\/?]+)/
            );

            if (email_regex != null) {
                // looks like an email
                domain = email_regex?.groups?.domain ?? "Unknown";
            } else if (url_regex != null) {
                // looks like an URL
                domain = url_regex?.groups?.domain ?? "Unknown";
            } else  {
                domain = "Unknown";
            }

            let meta = '';
            let http_len = 0;
            let https_len = 0;

            // do the http test

            let http_resolves = '';

            await axios
                .get('http://' + domain)
                .then((response: any) => {
                    let mm = response.data.match(
                        /<title>(?<title>.*?)<\/title>/ms
                    );
                    meta = mm != null ? mm.groups.title.trim() : null;
                    http_resolves = 'Yes';
                    http_len = response.data.length;
                })
                .catch((error: any) => {
                    // `error.request` is an instance of XMLHttpRequest in the browser
                    if (error.response) {
                        // Request made and server responded with an error
                        http_resolves = 'Error';
                    } else if (error.request) {
                        // The request was made but no response was received
                        http_resolves = 'No';
                    }
                });


            // do the https test

            let https_resolves = '';

            await axios
                .get('https://' + domain)
                .then((response: any) => {
                    let mm = response.data.match(
                        /<title>(?<title>.*?)<\/title>/ms
                    );
                    // don't overwite the meta data if you already have it
                    if (meta === "")
                    {
                        meta = mm != null ? mm.groups.title.trim() : null;
                    }
                    https_resolves = 'Yes';
                    https_len = response.data.length;
                })
                .catch((error: any) => {
                    // `error.request` is an instance of XMLHttpRequest in the browser
                    if (error.response) {
                        // Request made and server responded with an error
                        https_resolves = 'Error';
                    } else if (error.request) {
                        // The request was made but no response was received
                        https_resolves = 'No';
                    }
                });

            

            const e: Entity = {
                id: uuidv4(),
                input: input,
                url: domain,
                email: emailproviders.value.includes(domain)
                    ? "Yes"
                    : "No",
                resolves_http: http_resolves,
                resolves_https: https_resolves,
                meta: meta,
                len: Math.max(https_len, http_len)
            }
            return e;
        }

        const process = () => {
            clear();
            // Process the email providers

            emailsprovidersinput.value
                .split("\n")
                .forEach((element: string) => {
                    element = element.trim();
                    if (element !== "") {
                        emailproviders.value.push(element);
                    }
                });

            inputs.value.split("\n").forEach((element: string) => {
                element = element.trim();

                if (element !== "") {

                    test(element)
                    .then((response) => {
                        items.value.push(response)
                    });

                    // let domain = "";

                    // let em = element.match(/(.*)@(?<domain>.*)/);

                    // let um = element.match(
                    //     /^(?:https?:\/\/)?(?:[^@\n]+@)?(?:www\.)?(?<domain>[^:\/?]+)/
                    // );

                    // if (em != null) {
                    //     // looks like an email
                    //     domain = em?.groups?.domain ?? "Unknown";
                    // } else if (um != null) {
                    //     // looks like an URL
                    //     domain = um?.groups?.domain ?? "Unknown";
                    // } else  {
                    //     domain = "Unknown";
                    // }

                    // // check if the element matches

                    // axios
                    //     .get((https.value ? "https" : "http") + `://${domain}`)
                    //     .then((response: any) => {
                    //         let mm = response.data.match(
                    //             /<title>(?<title>.*?)<\/title>/ms
                    //         );

                    //         items.value.push({
                    //             id: uuidv4(),
                    //             input: element,
                    //             url: domain,
                    //             email: emailproviders.value.includes(domain)
                    //                 ? "Yes"
                    //                 : "No",
                    //             resolves:
                    //                 response.status === 200
                    //                     ? "Yes"
                    //                     : "No (Not 200)",
                    //             meta:
                    //                 mm != null ? mm.groups.title.trim() : null,
                    //             len: response.data.length,
                    //         });
                    //     })
                    //     .catch((error: any) => {
                    //         // `error.request` is an instance of XMLHttpRequest in the browser
                    //         if (error.response) {
                    //             // Request made and server responded
                    //             items.value.push({
                    //                 id: uuidv4(),
                    //                 input: element,
                    //                 url: domain,
                    //                 resolves: error.response.status,
                    //                 email: emailproviders.value.includes(domain)
                    //                     ? "Yes"
                    //                     : "No",
                    //                 meta: "",
                    //                 len: 0,
                    //             });
                    //         } else if (error.request) {
                    //             // The request was made but no response was received
                    //             items.value.push({
                    //                 id: uuidv4(),
                    //                 input: element,
                    //                 url: domain,
                    //                 resolves: "No",
                    //                 email: emailproviders.value.includes(domain)
                    //                     ? "Yes"
                    //                     : "No",
                    //                 meta: "",
                    //                 len: 0,
                    //             });
                    //         } else {
                    //             // Something happened in setting up the request that triggered an Error
                    //             items.value.push({
                    //                 id: uuidv4(),
                    //                 input: element,
                    //                 url: domain,
                    //                 resolves: "Error",
                    //                 email: emailproviders.value.includes(domain)
                    //                     ? "Yes"
                    //                     : "No",
                    //                 meta: "",
                    //                 len: 0,
                    //             });
                    //         }
                    //     });
                }
            });
        };

        const excel = () => {
            // strip out the id

            let data = items.value.map((x) => {
                return {
                    input: x.input,
                    url: x.url,
                    resolves_http: x.resolves_http,
                    resolves_https: x.resolves_https,
                    email: x.email,
                    meta: x.meta,
                    len: x.len,
                };
            });

            try {
                json2excel({
                    data,
                    name: "user-info-data",
                });
            } catch (e) {
                console.error("export error");
            }
        };

        onMounted(clear);

        return {
            headers,
            items,
            inputs,
            emailsprovidersinput,
            search,
            emailproviders,
            processedinput,
            processedoutput,
            progress,
            progressColor,
            listlabel,
            emaillabel,
            processedemailproviders,
            excel,
            process,
            getEmailColor,
            getResponseColor,
            clear,
        };
    },
});
</script>
