<template>
    <v-card depressed>
        <v-card-title primary-title class="py-2 px-3 body-1 bg-success text-white">Kontak (HP / Email)</v-card-title>
        <v-card-text class="px-3 py-3">
            <v-row row wrap no-gutters>
                <v-col cols="12" v-for="(c, n) in contacts" :key="n" class="pb-2">
                    <v-text-field
                        outlined dense clearable
                        hide-details
                        :placeholder="getPlaceholder(n)"
                        :label="getPlaceholder(n)"
                        @change="changeDesc(n, $event)"
                        :value="c.desc"
                    ></v-text-field>
                </v-col>
            </v-row>
        </v-card-text>
    </v-card>
</template>

<script>
module.exports = {
    props: ["id"],
    data () {
        return {

        }
    },

    computed : {
        __s () {
            return this.$store.state.misc
        },

        contacts () {
            return this.__s.contacts
        }
    },

    methods : {
        __d (x, y) {
            this.$store.commit("Mastermisc/SET_OBJECT", [x, y])    
        },
        getPlaceholder(index) {
        switch (index) {
            case 0:
                return 'Nomor HP';
            case 1:
                return 'Nomor WhatsApp';
            case 2:
                return 'Email';
            default:
                return 'Kontak ' + (index + 1) + ' (HP / Email)';
        }
    },
        changeDesc (x, y) {
            let z = JSON.parse(JSON.stringify(this.contacts))
            z[x].desc = y

            this.__d("contacts", z)
        }
    },

    mounted () {
        // let contacts = []
        // if (this.contacts.length < 1) {
        //     let c = this.__s.contact_default
        //     let n = this.__s.contacts_cnt
        //     for (let i = 0; i<n; i++) contacts.push(JSON.parse(JSON.stringify(c)))
        // } else {

        // }

        // this.__d("contacts", contacts)
    }
}