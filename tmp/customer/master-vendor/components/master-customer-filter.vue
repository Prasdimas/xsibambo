<template>
    <v-dialog
        v-model="dialog"
        scrollable
        persistent 
        fullscreen
        transition="dialog-transition"
        content-class="dialog-filter"
        v-if="dialog"
    >
        <v-card>
            <v-card-title primary-title class="pa-2 purple white--text">
                <v-btn flat color="primary" class="ma-0 btn-icon mr-2 hidden-md-and-up" @click="dialog=!dialog" style="float:left">
                    <v-icon class="white--text" medium>arrow_back</v-icon>
                </v-btn>
                <h3 class="headline">FILTER</h3>
            </v-card-title>
            <v-card-text class="grow" grow>
                <v-layout row wrap>
                    <v-flex xs12 sm6 offset-xs0 offset-sm3>
                        <v-autocomplete
                            label="Propinsi"
                            v-model="selected_province"
                            :items="provinces"
                            auto-select-first
                            return-object
                            clearable
                            item-text="M_ProvinceName"
                            item-value="M_ProvinceID"
                            placeholder="Semua Propinsi"
                            solo
                            >
                            <template
                                slot="item"
                                slot-scope="{ item }"
                                >
                                <v-list-tile-content>
                                <v-list-tile-title v-text="item.M_ProvinceName"></v-list-tile-title>
                                <!-- <v-list-tile-sub-title v-text="getAddress(item)"></v-list-tile-sub-title> -->
                                </v-list-tile-content>
                            </template>

                        </v-autocomplete>
                    </v-flex>

                    <v-flex xs12 sm6 offset-xs0 offset-sm3>
                        <v-autocomplete
                            label="Kota"
                            v-model="selected_city"
                            :items="cities"
                            auto-select-first
                            return-object
                            clearable
                            item-text="M_CityName"
                            item-value="M_CityID"
                            placeholder="Semua Kota"
                            :disabled="selected_province == null"
                            solo
                            >
                            <template
                                slot="item"
                                slot-scope="{ item }"
                                >
                                <v-list-tile-content>
                                <v-list-tile-title v-text="item.M_CityName"></v-list-tile-title>
                                <!-- <v-list-tile-sub-title v-text="getAddress(item)"></v-list-tile-sub-title> -->
                                </v-list-tile-content>
                            </template>

                        </v-autocomplete>
                    </v-flex>

                    <v-flex xs12 sm6 offset-xs0 offset-sm3>
                        <v-select
                            :items="levels"
                            v-model="selected_level"
                            item-text="M_CustomerLevelName"
                            item-value="M_CustomerLevelID"
                            return-object
                            solo
                            placeholder="Semua Level"
                            clearable
                        ></v-select>  
                    </v-flex>
                </v-layout>

            </v-card-text>
            <v-card-actions>
                <!-- <v-btn color="primary" outline @click="dialog=!dialog">Tutup</v-btn> -->
                <v-layout row wrap>
                    <v-flex xs12 sm6 offset-xs0 offset-sm3>
                        <v-btn color="primary" @click="save" block>Terapkan</v-btn>        
                    </v-flex>
                </v-layout>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<style>
.dialog-filter .v-card__title, .dialog-filter .v-card__actions {
    flex-grow: 0 !important;
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
            get () { return this.$store.state.customer_filter.dialog_filter },
            set (v) { this.$store.commit('customer_filter/set_common', ['dialog_filter', v]) }
        },

        provinces () {
            return this.$store.state.customer_filter.provinces
        },

        cities () {
            return this.$store.state.customer_filter.cities
        },

        selected_province : {
            get () { return this.$store.state.customer_filter.selected_province },
            set (v) { 
                this.$store.commit('customer_filter/set_selected_province', v)
                this.$store.dispatch('customer_filter/search_city', {})
            }
        },

        selected_city : {
            get () { return this.$store.state.customer_filter.selected_city },
            set (v) { 
                this.$store.commit('customer_filter/set_selected_city', v)
            }
        },

        levels () {
            return this.$store.state.customer_new.customer_levels
        },

        selected_level : {
            get () { return this.$store.state.customer_filter.selected_level },
            set (v) { 
                this.$store.commit('customer_filter/set_selected_level', v)
            }
        }
    },

    methods : {
        save () {
            this.$store.commit('customer/set_provinces', this.provinces)
            this.$store.commit('customer/set_cities', this.cities)
            this.$store.commit('customer/set_selected_province', this.selected_province)
            this.$store.commit('customer/set_selected_city', this.selected_city)
            this.$store.commit('customer/set_selected_level', this.selected_level)
            this.$store.dispatch('customer/search', {})
            this.dialog=false
        }
    },

    watch : {
        dialog (v, o) {
            if (v && !o) {
                this.$store.commit('customer_filter/set_provinces', this.$store.state.customer.provinces)
                this.$store.commit('customer_filter/set_cities', this.$store.state.customer.cities)
                this.selected_province = this.$store.state.customer.selected_province,
                this.selected_city = this.$store.state.customer.selected_city
                this.selected_level = this.$store.state.customer.selected_level
            }
        }
    },

    mounted () {
        this.$store.dispatch('customer_filter/search_province')
    }
}
</script>