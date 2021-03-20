<template>
    <v-container>
        <v-row class="text-center">
            <v-col>
                Ensure you have the
                <a
                    href="https://chrome.google.com/webstore/detail/allow-cors-access-control/lhobafahddgcelffkeicbaginigeejlf?hl=en"
                    >Chrome CORS plugin enabled</a
                >.
            </v-col>
        </v-row>
        <v-row>
            <v-col>
                <v-textarea
                    class="ma-6"
                    outlined
                    name="input-7-4"
                    label="Email or URL list"
                    placeholder="email@domain.com or http://www.web.com"
                    v-model="inputs"
                ></v-textarea>
            </v-col>
            <v-col>
                <v-textarea
                    class="ma-6"
                    outlined
                    name="input-7-4"
                    label="Email Providers"
                    placeholder="gmail.com"
                    v-model="emailsprovidersinput"
                ></v-textarea>
            </v-col>
        </v-row>
        <v-row>
            <v-col>
                <v-chip class="ma-1" color="primary">
                    <strong>Items:</strong>&nbsp;<span>{{
                        processedinput
                    }}</span>
                </v-chip>
                <v-chip class="ma-1" color="secondary">
                    <strong>Email Providers:</strong>&nbsp;<span>{{
                        processedemailproviders
                    }}</span>
                </v-chip>
                <v-chip class="ma-1" color="green">
                    <strong>Processed:</strong>&nbsp;<span>{{
                        processedoutput
                    }}</span>
                </v-chip>
            </v-col>
        </v-row>
        <v-row>
            <v-col>
                <v-btn class="ma-1" depressed color="primary" @click="process">
                    Process
                </v-btn>
                <v-btn class="ma-1" depressed color="secondary" @click="excel">
                    Export
                </v-btn>
                <v-btn
                    class="ma-1"
                    depressed
                    color="secondary"
                    @click="clear()"
                >
                    Clear
                </v-btn>
            </v-col>
        </v-row>
        <v-row>
            <v-col>
                <v-progress-linear height="25" :value="progress">
                    <template v-slot:default="{ value }">
                        <strong>{{ Math.ceil(value) }}%</strong>
                    </template>
                </v-progress-linear>
            </v-col>
        </v-row>
        <v-row>
            <v-col>
                <v-data-table
                    dense
                    :headers="headers"
                    :items="items"
                    item-key="id"
                    class="elevation-1"
                >
                    <template v-slot:[`item.email`]="{ item }">
                        <v-chip small :color="getEmailColor(item.email)" dark>
                            {{ item.email }}
                        </v-chip>
                    </template>
                    <template v-slot:[`item.resolves`]="{ item }">
                        <v-chip
                            small
                            :color="getResponseColor(item.resolves)"
                            dark
                        >
                            {{ item.resolves }}
                        </v-chip>
                    </template>
                </v-data-table>
            </v-col>
        </v-row>
    </v-container>
</template>

<script lang="ts">
import Vue from "vue";
import { v4 as uuidv4 } from "uuid";
import axios from "axios";

let { json2excel } = require("js2excel");

interface Entity {
    id: string;
    input: string;
    url: string;
    email: string;
    resolves: string;
    meta: string;
    len: number;
}

export default Vue.extend({
    name: "JTools",

    data: function () {
        return {
            headers: [
                {
                    text: "Input",
                    align: "start",
                    value: "input",
                },
                { text: "Processed URL", value: "url" },
                { text: "Matches Email Provider", value: "email" },
                { text: "Resolves?", value: "resolves" },
                { text: "Meta", value: "meta" },
                { text: "Response Size (B)", value: "len" },
            ],
            items: [] as Entity[],
            inputs: "me@gmail.com\nmainbox@email.com\nwhwew@sdfgdgref.com\nhttp://www.yahoo.com\nhttps://www.secure.com\nwww.google.com\nthisisnotreallyadomainisitno.co.ac.uk\nwww.domain.com/something" as string,
            emailsprovidersinput: "gmail.com\nhotmail.com" as string,
            emailproviders: [] as string[],
        };
    },
    computed: {
        processedinput: function (): number {
            let spl: Array<string> = this.inputs.split("\n");
            let count: number = 0;
            spl.forEach((element: string) => {
                if (element.trim() !== "") {
                    count++;
                }
            });
            return count;
        },
        processedoutput: function (): number {
            let len: number = this.items.length;
            return len;
        },
        processedemailproviders: function (): number {
            let spl: Array<string> = this.emailsprovidersinput.split("\n");
            let count: number = 0;
            spl.forEach((element: string) => {
                if (element.trim() !== "") {
                    count++;
                }
            });
            return count;
        },
        progress: function (): number {
            return (this.processedoutput / this.processedinput) * 100;
        },
    },
    methods: {
        getEmailColor(email: string) {
            if (email == "Yes") return "green";
            else return "red";
        },
        getResponseColor(response: string) {
            if (response == "Yes") return "green";
            else if (response == "No") return "red";
            else return "orange";
        },
        clear: function (): void {
            this.items = [];
            console.clear();
        },
        process: function (): void {
            this.clear();
            // Process the email providers

            this.emailsprovidersinput.split("\n").forEach((element: string) => {
                element = element.trim();
                if (element != "") {
                    this.emailproviders.push(element);
                }
            });

            this.inputs.split("\n").forEach((element: string) => {
                element = element.trim();

                if (element !== "") {
                    let domain = "";

                    let em = element.match(/(.*)@(?<domain>.*)/);

                    let um = element.match(/^http[s]?:\/\/(?<domain>.*)/);

                    let im = element.match(/^(?<domain>\w+(\.\w+)+)/);

                    if (em != null) {
                        // looks like an email
                        domain = em?.groups?.domain ?? "Unknown";
                    } else if (um != null) {
                        // looks like an URL
                        domain = um?.groups?.domain ?? "Unknown";
                    } else if (im != null) {
                        domain = im?.groups?.domain ?? "Unknown";
                    }

                    // check if the element matches

                    axios
                        .get(`https://${domain}`)
                        .then((response: any) => {
                            let mm = response.data.match(
                                /<title>(?<title>.*?)<\/title>/ms
                            );

                            this.items.push({
                                id: uuidv4(),
                                input: element,
                                url: domain,
                                email: this.emailproviders.includes(domain)
                                    ? "Yes"
                                    : "No",
                                resolves:
                                    response.status == 200
                                        ? "Yes"
                                        : "No (Not 200)",
                                meta:
                                    mm != null ? mm.groups.title.trim() : null,
                                len: response.data.length,
                            });
                        })
                        .catch((error: any) => {
                            // `error.request` is an instance of XMLHttpRequest in the browser
                            if (error.response) {
                                // Request made and server responded
                                this.items.push({
                                    id: uuidv4(),
                                    input: element,
                                    url: domain,
                                    resolves: error.response.status,
                                    email: this.emailproviders.includes(domain)
                                        ? "Yes"
                                        : "No",
                                    meta: "",
                                    len: 0,
                                });
                            } else if (error.request) {
                                // The request was made but no response was received
                                this.items.push({
                                    id: uuidv4(),
                                    input: element,
                                    url: domain,
                                    resolves: "No",
                                    email: this.emailproviders.includes(domain)
                                        ? "Yes"
                                        : "No",
                                    meta: "",
                                    len: 0,
                                });
                            } else {
                                // Something happened in setting up the request that triggered an Error
                                this.items.push({
                                    id: uuidv4(),
                                    input: element,
                                    url: domain,
                                    resolves: "Error",
                                    email: this.emailproviders.includes(domain)
                                        ? "Yes"
                                        : "No",
                                    meta: "",
                                    len: 0,
                                });
                            }
                        });
                }
            });
        },
        excel: function () {
            // strip out the id

            let data = this.items.map((x) => {
                return {
                    input: x.input,
                    url: x.url,
                    resolves: x.resolves,
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
        },
    },
});
</script>
