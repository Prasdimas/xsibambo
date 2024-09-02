<template>
    
                <v-layout row wrap>
                    <v-flex xs12 sm12 md12 :class="{'pr-4':$vuetify.breakpoint.mdAndUp,'pr-2':$vuetify.breakpoint.smOnly}">
                        <v-layout row wrap>
                            <v-flex xs12>
                                <v-text-field
                                    label="Beri LABEL untuk Alamat ini ..."
                                    v-model="address_name"
                                    :error="address_name==''"
                                    :error-count="address_name==''?1:0"
                                    :error-messages="address_name==''?['Wajib diisi']:[]"
                                >
                                </v-text-field>
                            </v-flex>                            

                            <v-flex xs12>
                                <v-text-field
                                    label="Alamat Customer"
                                    v-model="address_desc"
                                    prepend-inner-icon="place"
                                    :error="address_desc.length<10"
                                    :error-count="address_desc.length<10?1:0"
                                    :error-messages="address_desc.length<10?['Wajib diisi, Minimal 10 karakter']:[]"
                                ></v-text-field>
                            </v-flex>

                            <v-flex xs12 sm6 md6 :class="{'pr-2':$vuetify.breakpoint.smAndUp}">
                                <v-autocomplete
                                    label="Propinsi"
                                    v-model="selected_province"
                                    :items="provinces"
                                    auto-select-first
                                    return-object
                                    clearable
                                    item-text="M_ProvinceName"
                                    item-value="M_ProvinceID"
                                    placeholder="Pilih Propinsi"
                                    :error="!selected_province"
                                    :error-count="!selected_province?1:0"
                                    :error-messages="!selected_province?['Pilih salah satu']:[]"
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

                            <v-flex xs12 sm6 md6 :class="{'pl-2':$vuetify.breakpoint.smAndUp}">
                                <v-autocomplete
                                    label="Kota"
                                    v-model="selected_city"
                                    :items="cities"
                                    auto-select-first
                                    return-object
                                    clearable
                                    item-text="M_CityName"
                                    item-value="M_CityID"
                                    placeholder="Pilih Kota"
                                    :disabled="selected_province == null"
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

                            <v-flex xs12 sm6 md6 :class="{'pr-2':$vuetify.breakpoint.smAndUp}">
                                <v-autocomplete
                                    label="Kecamatan"
                                    v-model="selected_district"
                                    :items="districts"
                                    auto-select-first
                                    return-object
                                    clearable
                                    item-text="M_DistrictName"
                                    item-value="M_DistrictID"
                                    placeholder="Pilih Kecamatan"
                                    :disabled="selected_city == null"
                                    >
                                    <template
                                        slot="item"
                                        slot-scope="{ item }"
                                        >
                                        <v-list-tile-content>
                                        <v-list-tile-title v-text="item.M_DistrictName"></v-list-tile-title>
                                        <!-- <v-list-tile-sub-title v-text="getAddress(item)"></v-list-tile-sub-title> -->
                                        </v-list-tile-content>
                                    </template>

                                </v-autocomplete>
                            </v-flex>

                            <v-flex xs12 sm6 md6 :class="{'pl-2':$vuetify.breakpoint.smAndUp}">
                                <v-autocomplete
                                    label="Kelurahan"
                                    v-model="selected_village"
                                    :items="villages"
                                    auto-select-first
                                    return-object
                                    clearable
                                    item-text="M_KelurahanName"
                                    item-value="M_KelurahanID"
                                    placeholder="Pilih Kelurahan"
                                    :disabled="selected_district == null"
                                    >
                                    <template
                                        slot="item"
                                        slot-scope="{ item }"
                                        >
                                        <v-list-tile-content>
                                        <v-list-tile-title v-text="item.M_KelurahanName"></v-list-tile-title>
                                        <!-- <v-list-tile-sub-title v-text="getAddress(item)"></v-list-tile-sub-title> -->
                                        </v-list-tile-content>
                                    </template>

                                </v-autocomplete>
                            </v-flex>
                            
                            <v-flex xs12 sm4 md4 :class="{'pr-2':$vuetify.breakpoint.smAndUp}">
                                <v-text-field
                                    label="Kode Pos"
                                    v-model="address_postcode"
                                    placeholder=""
                                ></v-text-field>
                            </v-flex>

                            <v-flex xs12 sm8 md8 :class="{'pr-2':$vuetify.breakpoint.smAndUp}">
                                <v-text-field
                                    label="Nama PIC"
                                    v-model="address_pic_name"
                                    placeholder=""
                                ></v-text-field>
                            </v-flex>

                            <v-flex xs12>
                                <master-customer-new-address-phones></master-customer-new-address-phones>
                            </v-flex>

                        </v-layout>
                    </v-flex>
                    
                </v-layout>
                
            
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
        "master-customer-new-address-phones" : httpVueLoader("./master-customer-new-address-phones.vue?t=a1sd")
    },

    data () {
        return {
            
        }
    },

    computed : {
        URL () {
            return this.$store.state.address.URL
        },

        edit () {
            return this.$store.state.address.edit
        },

        dialog : {
            get () { return this.$store.state.address.dialog_new },
            set (v) { this.$store.commit('address/set_common', ['dialog_new', v]) }
        },

        search_city : {
            get () { return this.$store.state.address.search_city },
            set (v) { this.$store.commit('address/set_common', ["search_city", v]) }
        },

        selected_city : {
            get () { return this.$store.state.address.selected_city },
            set (v) { 
                this.$store.commit('address/set_selected_city', v) 
                this.$store.dispatch('address/search_district', {})
            }
        },

        cities () {
            return this.$store.state.address.cities
        },

        address_name : {
            get () { return this.$store.state.address.address_name },
            set (v) { this.$store.commit('address/set_common', ['address_name', v]) }
        },

        address_desc : {
            get () { return this.$store.state.address.address_desc },
            set (v) { this.$store.commit('address/set_common', ['address_desc', v]) }
        },

        address_phone : {
            get () { return this.$store.state.address.address_phone },
            set (v) { this.$store.commit('address/set_common', ['address_phone', v]) }
        },

        address_note : {
            get () { return this.$store.state.address.address_note },
            set (v) { this.$store.commit('address/set_common', ['address_note', v]) }
        },

        address_email : {
            get () { return this.$store.state.address.address_email },
            set (v) { this.$store.commit('address/set_common', ['address_email', v]) }
        },

        address_postcode : {
            get () { return this.$store.state.address.address_postcode },
            set (v) { this.$store.commit('address/set_common', ['address_postcode', v]) }
        },

        address_pic_name : {
            get () { return this.$store.state.address.address_pic_name },
            set (v) { this.$store.commit('address/set_common', ['address_pic_name', v]) }
        },

        address_pic_phone : {
            get () { return this.$store.state.address.address_pic_phone },
            set (v) { this.$store.commit('address/set_common', ['address_pic_phone', v]) }
        },

        provinces () {
            return this.$store.state.address.provinces
        },

        selected_province : {
            get () { return this.$store.state.address.selected_province },
            set (v) { 
                this.$store.commit('address/set_selected_province', v)
                this.$store.dispatch('address/search_city', {})
            }
        },

        districts () {
            return this.$store.state.address.districts
        },

        selected_district : {
            get () { return this.$store.state.address.selected_district },
            set (v) { 
                this.$store.commit('address/set_selected_district', v)
                this.$store.dispatch('address/search_village', {})
            }
        },

        villages () {
            return this.$store.state.address.villages
        },

        selected_village : {
            get () { return this.$store.state.address.selected_village },
            set (v) { 
                this.$store.commit('address/set_selected_village', v)
            }
        }
    },

    methods : {
        save () {
            this.$store.dispatch('address/save')
        }
    },

    mounted () {
        this.$store.dispatch('address/search_province', {})
    },

    watch : {
        search_city(val, old) { 
            
            if (this.$store.state.address.edit) return
            if (val == null || typeof val == 'undefined') val = ""
            if (val == old ) return
            if (this.$store.state.address.search_city_status == 1 ) return  
            
            this.$store.commit("address/set_common", ["search_city", val])
            this.thr_search()
        }
    }
}
</script>