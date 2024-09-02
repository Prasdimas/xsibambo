<template>
    <v-dialog
        v-model="dialog"
        scrollable
        :overlay="false"
        max-width="500px"
        :fullscreen="$vuetify.breakpoint.smAndDown"
        transition="dialog-transition"
        content-class="dialog-new"
    >
        <v-card>
            <v-card-title primary-title class="py-2 blue">
                <v-btn flat color="primary" class="ma-0 btn-icon mr-2 hidden-md-and-up" @click="dialog=!dialog" style="float:left">
                    <v-icon class="white--text" medium>arrow_back</v-icon>
                </v-btn>

                <h3 class="headline white--text pt-1">SIMILARS</h3>
            </v-card-title>
            <v-card-text>
                <v-layout row wrap v-for="(similar, n) in similars" :key="n">
                    
                        <v-flex xs12>
                            <h3>{{similar.customer_name}}</h3>
                        </v-flex>
                    
                    
                        <v-flex xs12 v-show="similar.customer_address!=''">
                            <div>{{similar.customer_address}}</div>
                            <span v-show="similar.customer_kelurahan!=''">Kel. {{similar.customer_kelurahan}}</span>
                            <span v-show="similar.customer_district!=''">Kec. {{similar.customer_district}}</span>
                            <span v-show="similar.customer_city!=''">Kota {{similar.customer_city}}</span>
                            <span v-show="similar.customer_province!=''">Propinsi {{similar.customer_province}}</span>
                        </v-flex>
                    
                        <v-flex xs12>
                            <v-divider class="my-2"></v-divider>        
                        </v-flex>
                    
                </v-layout>
            </v-card-text>

            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="primary" flat @click="dialog=!dialog">Tutup</v-btn>                
            </v-card-actions>
        </v-card>
        
    </v-dialog>
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
module.exports = {
    components : {
    },

    data () {
        return {
            
        }
    },

    computed : {
        dialog : {
            get () { return this.$store.state.customer_new.dialog_similar },
            set (v) { this.$store.commit('customer_new/set_common', ['dialog_similar', v]) }
        },

        similars () {
            return this.$store.state.customer_new.similars
        }
    },

    methods : {
        
    }
}
</script>