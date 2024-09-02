<template>
    <v-layout row wrap>
        <v-flex xs12>
            <v-card>
                <v-card-title primary-title class="orange pa-1 white--text">
                    <v-layout row wrap align-center>
                        <v-flex xs11 class="text-xs-left pl-2">
                            <span class="mt-auto mb-auto">ALAMAT PENGIRIMAN LAIN</span>
                        </v-flex>
                        <v-flex xs1 class="text-xs-center">
                            <v-btn color="primary btn-icon ma-0" @click="add_address" small><v-icon>add</v-icon></v-btn>  
                        </v-flex>
                    </v-layout>
                </v-card-title>
                <v-card-text class="pt-2">
                    <div v-show="addresses.length < 1">
                        Belum ada alamat pengiriman lain
                    </div>
                    <!-- <div v-show="addresses.length<1" class="text-xs-center">Belum ada nomor telepon</div> -->
                    <v-layout row wrap v-for="(address, n) in addresses" :key="n" class="mb-1">
                        <!-- <v-flex xs1 class="text-xs-left" pt-2>{{n+1}}</v-flex> -->
                        <v-flex xs10 pt-2>
                            <span class="blue--text">{{address.address_name}}</span>
                            <span class="d-block caption">{{address.address_desc}}</span>
                            <span class="d-block caption">Kab / Kota {{address.address_city.name}}, Prop {{address.address_province.name}}</span>
                            <span class="d-block caption">Phone {{address.address_phone}}</span>
                        </v-flex>
                        <v-flex xs2 pt-2>
                            <v-btn color="primary" class="ma-0 mr-1" icon :dark="false" flat @click="edit_address(n)" small><v-icon>edit</v-icon></v-btn>
                            <v-btn color="red" class="ma-0 mr-1" icon :dark="false" flat @click="del_address(n)" small><v-icon>delete</v-icon></v-btn>
                        </v-flex>
                    </v-layout>
                </v-card-text>
                <!-- <v-card-actions>
                    <v-layout row wrap>
                        <v-flex xs12 class="text-xs-center">
                            <v-btn color="primary btn-icon" @click="add_address" small><v-icon>add</v-icon></v-btn>        
                        </v-flex>
                    </v-layout>
                    
                </v-card-actions> -->
            </v-card>
        </v-flex>
        <master-customer-new-address></master-customer-new-address>
    </v-layout>
</template>
<style>
.dialog-new .input-dense .v-input__control {
    min-height: 36px !important;
}
.dialog-new .v-text-field.v-text-field--solo .v-input__control {
    min-height: 36px;
    padding: 0;
}
</style>
<script>
let rnd = Math.round(Math.random() * 1e10)
module.exports = {
    components : {
        "master-customer-new-address" : httpVueLoader("./master-customer-new-address.vue?t="+rnd)
    },

    data () {
        return {
        }
    },

    computed : {
        edit () {
            return this.$store.state.customer_new.edit
        },

        addresses () {
            return this.$store.state.address.addresses
        }
    },

    methods : {
        add_address () {
            // let x = this.addresses
            // x.push(JSON.parse(JSON.stringify(this.$store.state.customer_new.template_address)))
            this.$store.commit('address/set_common', ['edit', false])
            this.$store.commit('address/set_common', ['address_id', 0])
            this.$store.commit('address/set_common', ['address_name', ''])
            this.$store.commit('address/set_common', ['address_desc', ''])
            this.$store.commit('address/set_common', ['address_pic_name', ''])
            this.$store.commit('address/set_common', ['address_postcode', ''])
            this.$store.commit('address/set_common', ['address_phone', ''])
            this.$store.commit('address/set_selected_province', null)
            this.$store.commit('address/set_selected_city', null)
            this.$store.commit('address/set_selected_district', null)
            this.$store.commit('address/set_selected_village', null)
            this.$store.commit('address/set_phones', [])

            this.$store.commit('address/set_common', ['dialog_new', true])
        },

        edit_address (n) {
            let x = this.addresses[n]
            // x.push(JSON.parse(JSON.stringify(this.$store.state.customer_new.template_address)))
            this.$store.commit('address/set_selected_address', x)
            this.$store.commit('address/set_common', ['edit', true])
            this.$store.commit('address/set_common', ['address_idx', n])
            this.$store.commit('address/set_common', ['address_id', x.address_id])
            this.$store.commit('address/set_common', ['address_name', x.address_name])
            this.$store.commit('address/set_common', ['address_desc', x.address_desc])
            this.$store.commit('address/set_common', ['address_pic_name', x.address_pic_name])
            this.$store.commit('address/set_common', ['address_postcode', x.address_postcode])
            this.$store.commit('address/set_common', ['address_phone', x.address_phone])
            this.$store.commit('address/set_phones', JSON.parse(x.address_phones))

            this.$store.commit('address/set_selected_province', null)
            this.$store.commit('address/set_selected_city', null)
            this.$store.commit('address/set_selected_district', null)
            this.$store.commit('address/set_selected_village', null)

            // Province
            this.$store.dispatch('address/search_province')

            this.$store.commit('address/set_common', ['dialog_new', true])
        },

        update_address (i, t, v) {
            // let x = this.addresses
            // x[i][t] = v
            // this.$store.commit('customer_new/set_addresses', x)
        },

        del_address (n) {
            let x = this.addresses
            x.splice(n, 1)
            this.$store.commit('customer_new/set_addresses', x)
        },

        format_phone (x) {
            let y = []
            for (let p of JSON.parse(x))
                y.push(p.no)

            return y.join(", ")
        }
    },

    mounted () {
    },

    watch : {
    }
}
</script>