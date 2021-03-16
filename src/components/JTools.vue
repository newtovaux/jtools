<template>
  <v-container>
    <v-row class="text-center">
      <v-col>
        <v-textarea
            class="ma-6"
            outlined
            name="input-7-4"
            label="Email or URL list"
            placeholder="email@domain.com or http://www.web.com"
            v-model="inputs"
            @change="processedinput"
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
        <v-chip>
            <strong>Items:</strong>&nbsp;<span>{{ processedinput }}</span>
        </v-chip>
        <v-chip>
            <strong>Processed:</strong>&nbsp;<span>{{ processedoutput }}</span>
        </v-chip>
        <v-chip>
            <strong>Email Providers:</strong>&nbsp;<span>{{ processedemailproviders }}</span>
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
          @click="items = []"
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
        ></v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>

  import { v4 as uuidv4 } from 'uuid';
  import {json2excel} from 'js2excel';
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
            { text: 'Matches Email Provider', value: 'email' },
            { text: 'Processed URL', value: 'url' },
            { text: 'Resolves?', value: 'resolves' },
            { text: 'Meta', value: 'meta' },
            { text: 'Response Size (B)', value: 'len' },
        ],
        items: [],
        inputs: "mainbox@email.com\nwhwew@sdfgdgref.com\nhttp://www.yahoo.com\nhttps://www.secure.com\nwww.google.com\nthisisnotreallyadomainisitno.co.ac.uk\nwww.domain.com/something",
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
             var len = this.emailproviders.length;
            return len;
        }
    },
    methods:
    {
        inputchange: function () {
            this.processed.inputlines = this.inputs.split("\n").length();
        },
        process: function () {
            // Process the email providers

            this.emailsprovidersinput.split("\n").forEach(element => {
                element = element.trim();
                if (element != '') {
                    this.emailproviders.push(element);
                }
            });

            console.log(this.emailproviders);


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

                    //var pos = element.indexOf('@');
                    //var domain = element.substring(pos + 1);

                    // check if the element matches 

                    axios.get('http://' + domain)
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
                                resolves: 'No Response',
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
