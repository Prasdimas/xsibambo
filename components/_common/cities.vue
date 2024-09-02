<template>
    <v-select  label="Pilih Kota" density="comfortable" :items="" ></v-select>
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
            this.$store.commit("misc/SET_OBJECT", [x, y])
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