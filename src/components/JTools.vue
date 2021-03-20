<template>
  <v-container>
    <v-row class="text-center">
      <v-col>
          Ensure you have the <a href="https://chrome.google.com/webstore/detail/allow-cors-access-control/lhobafahddgcelffkeicbaginigeejlf?hl=en">Chrome CORS plugin enabled</a>.
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
            <strong>Items:</strong>&nbsp;<span>{{ processedinput }}</span>
        </v-chip>
        <v-chip class="ma-1" color="secondary">
            <strong>Email Providers:</strong>&nbsp;<span>{{ processedemailproviders }}</span>
        </v-chip>
        <v-chip class="ma-1" color="green">
            <strong>Processed:</strong>&nbsp;<span>{{ processedoutput }}</span>
        </v-chip>
 </v-col>
    </v-row>
    <v-row>
        <v-col>
        <v-btn
          class="ma-1"
          depressed
          color="primary"
          @click="process"
        >
          Process
        </v-btn>
        <v-btn
          class="ma-1"
          depressed
          color="secondary"
          @click="excel"
        >
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
        <v-data-table
          dense
          :headers="headers"
          :items="items"
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

  import { v4 as uuidv4 } from 'uuid';
  let { json2excel } = require('js2excel');


  const axios = require('axios');

  export default {
    name: 'JTools',

    data: function () {
      return {
        headers: [
            {
            text: 'Input',
            align: 'start',
            value: 'input',
            },
            { text: 'Processed URL', value: 'url' },
            { text: 'Matches Email Provider', value: 'email' },
            { text: 'Resolves?', value: 'resolves' },
            { text: 'Meta', value: 'meta' },
            { text: 'Response Size (B)', value: 'len' },
        ],
        items: [],
        inputs: "me@gmail.com\nmainbox@email.com\nwhwew@sdfgdgref.com\nhttp://www.yahoo.com\nhttps://www.secure.com\nwww.google.com\nthisisnotreallyadomainisitno.co.ac.uk\nwww.domain.com/something",
        emailsprovidersinput: "gmail.com\nhotmail.com",
        emailproviders: [],
      }
  },
    computed:
    {
        processedinput: function () {
            var spl = this.inputs.split("\n");
            return spl.length;
        },
        processedoutput: function () {
            var len = this.items.length;
            return len;
        },
        processedemailproviders: function () {
            var spl = this.emailsprovidersinput.split("\n");
            return spl.length;
        }
    },
    methods:
    {
        getEmailColor (email) {
            if (email == 'Yes') return 'green'
            else return 'red'
        },
        getResponseColor (response) {
            if (response == 'Yes') return 'green'
            else if (response == 'No') return 'red'
            else return 'orange'
        },
        inputchange: function () {
            this.processed.inputlines = this.inputs.split("\n").length();
        },
        clear: function () {
            this.itmes = [];
            console.clear();
        },
        process: function () {
            // Process the email providers

            this.emailsprovidersinput.split("\n").forEach(element => {
                element = element.trim();
                if (element != '') {
                    this.emailproviders.push(element);
                }
            });

            this.inputs.split("\n").forEach(element => {

                element = element.trim();

                if (element != ''){

                    var domain = '';

                    var emailre = /(.*)@(?<domain>.*)/;
                    var em = element.match(emailre);

                    var urlre = /^http[s]?:\/\/(?<domain>.*)/;
                    var um = element.match(urlre);

                    var urire = /^(?<domain>\w+(\.\w+)+)/;
                    var im = element.match(urire);

                    if (em != null) {
                        // looks like an email
                        domain = em.groups.domain;          
                    } else if (um != null) {
                        // looks like an URL
                        domain = um.groups.domain;
                    } else if (im != null) {
                        domain = im.groups.domain;
                    }

                    // check if the element matches 

                    axios.get('https://' + domain)
                    .then((response) => {

                        var metare = /<title>(?<title>.*?)<\/title>/ms;
                        var mm = response.data.match(metare);

                        this.items.push({
                            id: uuidv4(), 
                            input: element, 
                            url: domain, 
                            email: this.emailproviders.includes(domain) ? 'Yes' : 'No',
                            resolves: response.status == 200 ? 'Yes' : 'No (Not 200)',
                            meta: mm != null ? mm.groups.title.trim() : null,
                            len: response.data.length
                        })
                    })
                    .catch((error) => {
                        // `error.request` is an instance of XMLHttpRequest in the browser
                        console.log(error.request);
                        if (error.response) {
                            // Request made and server responded
                            this.items.push({
                                id: uuidv4(), 
                                input: element, 
                                url: domain, 
                                resolves: error.response.status,
                                email: this.emailproviders.includes(domain) ? 'Yes' : 'No',
                            })

                        } else if (error.request) {
                            // The request was made but no response was received
                            this.items.push({
                                id: uuidv4(), 
                                input: element, 
                                url: domain, 
                                resolves: 'No',
                                email: this.emailproviders.includes(domain) ? 'Yes' : 'No',
                            })
                        } else {
                            // Something happened in setting up the request that triggered an Error
                            console.log('Cant request', error.message);
                            this.items.push({
                                id: uuidv4(), 
                                input: element, 
                                url: domain, 
                                resolves: 'Error',
                                email: this.emailproviders.includes(domain) ? 'Yes' : 'No',
                            })
                        }
                    
                    });

                }

            });

        },
        excel: function () {
            console.log('excel');

            let data = this.items;
            try {
                json2excel({
                    data,
                    name: 'user-info-data',
                });
            } catch (e) {
                console.error('export error');
            }
        }
    },
  }
</script>
