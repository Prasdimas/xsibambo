<template>
    <v-dialog
        v-model="dialog"
        scrollable
        :overlay="false"
        max-width="600px"
        :fullscreen="$vuetify.breakpoint.smAndDown"
        transition="dialog-transition"
        content-class="dialog-new"
    >
        <v-card>
            <v-card-title primary-title class="py-2 blue">
                <v-btn flat color="primary" class="ma-0 btn-icon mr-2 hidden-md-and-up" @click="dialog=!dialog" style="float:left">
                    <v-icon class="white--text" medium>arrow_back</v-icon>
                </v-btn>

                <h3 class="headline white--text pt-1" v-show="!edit">ALAMAT PENGIRIMAN BARU</h3>
                <h3 class="headline white--text pt-1" v-show="edit">UBAH DATA ALAMAT PENGIRIMAN</h3>
            </v-card-title>
            <v-card-text>
                <master-customer-new-address-form></master-customer-new-address-form>
            </v-card-text>

            <v-card-actions>
                <v-btn color="primary" flat @click="dialog=!dialog">Batal</v-btn>                
                <v-spacer></v-spacer>
                <v-btn color="primary" @click="save" 
                    :disabled="address_name == '' ||
                                address_desc.length<10">Simpan</v-btn>                
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>
<style>
.dialog-new {
    max-height: 98% !important;
}
.dialog-new .input-dense .v-input__control {
    min-height: 36px !important;
}
.dialog-new .v-text-field.v-text-field--solo .v-input__control {
    min-height: 36px;
    padding: 0;
}


</style>
<script>
module.exports = {
    components : {
        "master-customer-new-address-form" : httpVueLoader("./master-customer-new-address-form.vue?t=a1sd")
    },

    data () {
        return {
            
        }
    },

    computed : {
        edit () {
            return this.$store.state.address.edit
        },

        dialog : {
            get () { return this.$store.state.address.dialog_new },
            set (v) { this.$store.commit('address/set_common', ['dialog_new', v]) }
        },

        address_name () {
            return this.$store.state.address.address_name
        },

        address_desc () {
            return this.$store.state.address.address_desc
        }
    },

    methods : {
        save () {
            this.$store.dispatch('address/save')
        }
    },

    mounted () {
    },

    watch : {
    }
}
</script>