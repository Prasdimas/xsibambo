<template>
    <v-layout row wrap>
        <v-flex xs12>
            <v-card>
                <v-card-title primary-title class="orange py-2 px-3 white--text">
                    <v-layout row wrap>
                        <v-flex xs10 class="text-xs-center" v-if="!!selected_customer_type">
                            NOMOR TELEPON / HP {{ selected_customer_type.id == "Y" ? "PERUSAHAAN" : "PERSONAL" }}
                        </v-flex>
                        <v-flex xs1 class="text-xs-center">
                            WA
                        </v-flex>
                        <v-flex xs1 class="text-xs-center">
                        </v-flex>
                    </v-layout>
                </v-card-title>
                <v-card-text class="pt-2">
                    <div v-show="phones.length<1" class="text-xs-center">Belum ada nomor telepon</div>
                    <v-layout row wrap v-for="(phone, n) in phones" :key="n" class="mb-1">
                        <v-flex xs1 class="text-xs-left" pt-2>{{n+1}}</v-flex>
                        <v-flex xs9>
                            <v-text-field
                                solo
                                prefix="+62"
                                hide-details
                                :value="phone.no"
                                @change="update_phone(n,'no',$event)"
                                dense
                                
                            ></v-text-field>
                        </v-flex>
                        <v-flex xs1 pl-2 pt-1>
                            <v-checkbox 
                                :input-value="phone.wa"
                                :value="phone.wa"
                                true-value="Y"
                                false-value="N"
                                hide-details
                                @change="update_phone(n,'wa',$event)"
                                style="margin-top:0px !important"></v-checkbox>
                        </v-flex>
                        <v-flex xs1>
                            <v-btn color="red" class="ma-0 mr-1" icon :dark="false" flat @click="del_phone(n)"><v-icon>delete</v-icon></v-btn>
                        </v-flex>
                    </v-layout>
                </v-card-text>
                <v-card-actions>
                    <v-layout row wrap>
                        <v-flex xs12 class="text-xs-center">
                            <v-btn color="primary btn-icon" @click="add_phone" small><v-icon>add</v-icon></v-btn>        
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

        phones () {
            return this.$store.state.customer_new.phones
        },

        selected_customer_type : {
            get () { return this.$store.state.customer_new.selected_customer_type },
            set (v) { this.$store.commit('customer_new/set_selected_customer_type', v) }
        }
    },

    methods : {
        add_phone () {
            let x = this.phones
            x.push(JSON.parse(JSON.stringify(this.$store.state.customer_new.template_phone)))

            this.$store.commit('customer_new/set_phones', x)
        },

        update_phone (i, t, v) {
            let x = this.phones
            x[i][t] = v
            this.$store.commit('customer_new/set_phones', x)
        },

        del_phone (n) {
            let x = this.phones
            x.splice(n, 1)
            this.$store.commit('customer_new/set_phones', x)
        }
    },

    mounted () {
    },

    watch : {
    }
}
</script>