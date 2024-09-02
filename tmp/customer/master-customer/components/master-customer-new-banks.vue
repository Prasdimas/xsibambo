<template>
    <v-layout row wrap>
        <v-flex xs12>
            <v-card>
                <v-card-title primary-title class="cyan py-2 px-3 white--text">

                    <v-layout row wrap>
                        <v-flex xs12 class="text-xs-center">
                            <b>DATA REKENING</b>
                        </v-flex>
                        <v-divider class="my-1 white"></v-divider>
                        <v-flex xs6 class="text-xs-center">
                            NAMA BANK
                        </v-flex>
                        <v-flex xs6 class="text-xs-center">
                            NOMOR / NAMA REKENING
                        </v-flex>
                    </v-layout>
                </v-card-title>
                <v-card-text class="pt-2">
                    <div v-show="cbanks.length<1" class="text-xs-center">Belum ada data rekening</div>
                    <v-layout row wrap v-for="(cbank, n) in cbanks" :key="n" class="mb-1">
                        <!-- <v-flex xs1 class="text-xs-left" pt-2>{{n+1}}</v-flex> -->
                        <v-flex xs6>
                            <v-autocomplete
                                :items="banks"
                                item-value="bank_id"
                                item-text="bank_name"
                                return-object
                                persistent-hint
                                hint="nama bank"
                                solo
                                @change="update_cbank(n, 'bank', $event)" 
                                v-show="!cbank.bank"
                            ></v-autocomplete>
                            <v-text-field
                                :value="cbank.bank.bank_name"
                                v-if="!!cbank.bank"
                                readonly
                                clearable
                                solo
                                persistent-hint
                                hint="nama bank"
                                @click:clear="clear_bank(n)"
                            ></v-text-field>
                        </v-flex>
                        <v-flex xs5 pl-2>
                            <v-text-field
                                persistent-hint
                                hint="nomor rekening"
                                solo
                                @input="update_cbank(n, 'no', $event)"
                                :value="cbank.no"
                            ></v-text-field>
                        </v-flex>
                        <v-flex xs1>
                            <v-btn color="red" class="ma-0 mr-1" icon :dark="false" flat @click="del_cbank(n)"><v-icon>delete</v-icon></v-btn>
                        </v-flex>
                        <v-flex xs11>
                            <v-text-field
                                prefix="a/n"
                                solo
                                hide-details
                                @input="update_cbank(n, 'name', $event)"
                                :value="cbank.name"
                            ></v-text-field>
                        </v-flex>
                        <v-flex xs12>
                            <v-divider class="mb-1 mt-2"></v-divider>
                        </v-flex>
                    </v-layout>
                </v-card-text>
                <v-card-actions>
                    <v-layout row wrap>
                        <v-flex xs12 class="text-xs-center">
                            <v-btn color="primary btn-icon" @click="add_cbank" small><v-icon>add</v-icon></v-btn>
                        </v-flex>
                    </v-layout>
                    
                </v-card-actions>
            </v-card>
        </v-flex>
        
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
module.exports = {
    components : {
    },

    data () {
        return {
        }
    },

    computed : {
        edit () {
            return this.$store.state.customer_new.edit
        },

        banks () {
            return this.$store.state.customer_new.banks
        },

        cbanks () {
            return this.$store.state.customer_new.cbanks
        },

        selected_customer_type : {
            get () { return this.$store.state.customer_new.selected_customer_type },
            set (v) { this.$store.commit('customer_new/set_selected_customer_type', v) }
        }
    },

    methods : {
        add_cbank () {
            let x = this.cbanks
            x.push(JSON.parse(JSON.stringify(this.$store.state.customer_new.template_cbank)))

            this.$store.commit('customer_new/set_cbanks', x)
        },

        update_cbank (i, t, v) {
            let x = this.cbanks
            x[i][t] = v
            this.$store.commit('customer_new/set_cbanks', x)
        },

        del_cbank (n) {
            let x = this.cbanks
            x.splice(n, 1)
            this.$store.commit('customer_new/set_cbanks', x)
        },

        clear_bank (n) {
            let x = this.cbanks
            x[n]['bank'] = null
            this.$store.commit('customer_new/set_cbanks', x)
        }
    },

    mounted () {
    },

    watch : {
    }
}
</script>