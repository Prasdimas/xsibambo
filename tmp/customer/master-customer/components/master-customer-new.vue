<template>
    <v-dialog
        v-model="dialog"
        scrollable
        :overlay="false"
        max-width="1000px"
        :fullscreen="$vuetify.breakpoint.smAndDown"
        transition="dialog-transition"
        content-class="dialog-new"
    >
        <v-card>
            <v-card-title primary-title class="py-2 blue">
                <v-btn flat color="primary" class="ma-0 btn-icon mr-2 hidden-md-and-up" @click="dialog=!dialog" style="float:left">
                    <v-icon class="white--text" medium>arrow_back</v-icon>
                </v-btn>

                <h3 class="headline white--text pt-1" v-show="!edit">{{customer_prospect=='Y'?'PROSPEK':'CUSTOMER'}} BARU</h3>
                <h3 class="headline white--text pt-1" v-show="edit">UBAH DATA {{customer_prospect=='Y'?'PROSPEK':'CUSTOMER'}}</h3>
            </v-card-title>
            <v-card-text>
                <v-layout row wrap>
                    <v-flex xs12 sm6 md6 :class="{'pr-4':$vuetify.breakpoint.mdAndUp,'pr-2':$vuetify.breakpoint.smOnly}">
                        <v-text-field
                            label="Nama Customer"
                            v-model="customer_name"
                            :error="customer_name==''"
                            :error-count="customer_name==''?1:0"
                            :error-messages="customer_name==''?['Wajib diisi']:[]"
                        >
                            <template slot="append-outer">
                                <v-btn color="primary" small class="btn-icon" v-show="show_similar" @click="show_me_similar"><v-icon>search</v-icon></v-btn>
                            </template>
                        </v-text-field>
                    </v-flex>
                    <v-flex xs12 sm6 md6 :class="{'pl-4':$vuetify.breakpoint.mdAndUp,'pl-2':$vuetify.breakpoint.smOnly}">
                        <v-layout row wrap>
                            <v-flex xs4>
                                <v-select
                                    :items="customer_types"
                                    v-model="selected_customer_type"
                                    label="Tipe Customer"
                                    return-object
                                    item-text="text"
                                    item-id="id"
                                ></v-select>
                            </v-flex>
                            <v-flex xs8 pl-3>
                                <v-text-field
                                    label="Nomor NPWP"
                                    v-model="customer_npwp"
                                ></v-text-field>
                            </v-flex>
                        </v-layout>
                    </v-flex>
                    <v-flex xs12>
                        <v-text-field
                            label="Alamat Customer"
                            v-model="customer_address"
                            prepend-inner-icon="place"
                            :error="customer_address.length<10"
                            :error-count="customer_address.length<10?1:0"
                            :error-messages="customer_address.length<10?['Wajib diisi, Minimal 10 karakter']:[]"
                        ></v-text-field>
                    </v-flex>
                </v-layout>
                <v-layout row wrap>
                    <v-flex xs12 sm6 md6 :class="{'pr-4':$vuetify.breakpoint.mdAndUp,'pr-2':$vuetify.breakpoint.smOnly}">
                        <v-layout row wrap>
                            <!-- <v-flex xs12>
                                <v-text-field
                                    label="Nama Customer"
                                    v-model="customer_name"
                                    :error="customer_name==''"
                                    :error-count="customer_name==''?1:0"
                                    :error-messages="customer_name==''?['Wajib diisi']:[]"
                                >
                                    <template slot="append-outer">
                                        <v-btn color="primary" small class="btn-icon" v-show="show_similar" @click="show_me_similar"><v-icon>search</v-icon></v-btn>
                                    </template>
                                </v-text-field>
                            </v-flex>                            

                            <v-flex xs12>
                                <v-text-field
                                    label="Alamat Customer"
                                    v-model="customer_address"
                                    prepend-inner-icon="place"
                                    :error="customer_address.length<10"
                                    :error-count="customer_address.length<10?1:0"
                                    :error-messages="customer_address.length<10?['Wajib diisi, Minimal 10 karakter']:[]"
                                ></v-text-field>
                            </v-flex> -->

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
                                    v-model="customer_postcode"
                                    placeholder=""
                                ></v-text-field>

                            </v-flex>

                            <!-- <v-flex xs12 sm6 md6>
                                <v-text-field
                                    label="Telepon"
                                    v-model="customer_phone"
                                    prepend-inner-icon="phonelink_ring"
                                    placeholder="08X-"
                                ></v-text-field>

                            </v-flex> -->

                            <v-flex xs12 sm8 md8>
                                <v-text-field
                                    label="Email"
                                    v-model="customer_email"
                                    prepend-inner-icon="email"
                                    placeholder="ex : someone@gmail.com"
                                    :error="!email_validate"
                                    :error-count="email_validate?0:1"
                                    :error-messages="['Email harus diisi, Format email harus benar']"
                                ></v-text-field>
                            </v-flex>

                            <v-flex xs12 sm12 md12>
                                <master-customer-new-addresses></master-customer-new-addresses>
                            </v-flex>

                            <v-flex xs12 sm12 md12>
                                <v-select
                                    label="Sales"
                                    v-model="selected_staff"
                                    :items="staffs"
                                    return-object
                                    clearable
                                    item-text="staff_name"
                                    item-value="staff_id"
                                    placeholder="Pilih Sales, atau kosongi saja"
                                    prepend-inner-icon="person"
                                    >
                                </v-select>
                            </v-flex>

                            <!-- <v-flex xs4>
                                <common-datepicker
                                    label="Tanggal Bergabung"
                                    :date="customer_join_date"
                                    data="0"
                                    @change="change_join_date"
                                    classs="ml-1"
                                    hints=""
                                    :details="true"
                                    v-if="dialog"
                                    :solo="false"
                                ></common-datepicker>
                            </v-flex> -->

                        </v-layout>
                    </v-flex>
                    <v-flex xs12 sm6 md6 :class="{'pl-4':$vuetify.breakpoint.mdAndUp,'pl-2':$vuetify.breakpoint.smOnly}">
                        <v-layout row wrap>
                            <!-- <v-flex xs4>
                                <v-select
                                    :items="customer_types"
                                    v-model="selected_customer_type"
                                    label="Tipe Customer"
                                    return-object
                                    item-text="text"
                                    item-id="id"
                                ></v-select>
                            </v-flex>
                            <v-flex xs8 pl-3>
                                <v-text-field
                                    label="Nomor NPWP"
                                    v-model="customer_npwp"
                                ></v-text-field>
                            </v-flex> -->
                            <v-flex xs8 pr-3>
                                <v-text-field
                                    v-show="selected_customer_type_id=='Y'"
                                    label="Nama PIC"
                                    v-model="customer_pic_name"
                                    :error="customer_pic_name==''"
                                    :error-count="customer_pic_name==''?1:0"
                                    :error-messages="customer_pic_name==''?['Wajib diisi']:[]"
                                ></v-text-field>
                                <v-text-field
                                    v-show="selected_customer_type_id=='N'"
                                    label="Nama PIC (hanya untuk bisnis)"
                                    v-model="customer_name"
                                    disabled
                                ></v-text-field>
                            </v-flex>
                            <v-flex xs4>
                                <v-text-field
                                    :disabled="selected_customer_type_id=='N'"
                                    label="No HP PIC"
                                    v-model="customer_pic_phone"
                                    prefix="+62"
                                ></v-text-field>
                            </v-flex>
                            <!-- <v-flex xs12 sm6 md6 :class="{'pr-2':$vuetify.breakpoint.smAndUp}">
                                <v-select
                                    :items="customer_levels"
                                    v-model="selected_customer_level"
                                    return-object
                                    item-text="M_CustomerLevelName"
                                    item-value="M_CustomerLevelID"
                                    label="Jenis Customer"
                                >
                                </v-select>
                            </v-flex> -->

                            <v-flex xs12>
                                <v-textarea
                                    label="Catatan"
                                    placeholder=" "
                                    rows="2"
                                    v-model="customer_note"
                                ></v-textarea>
                            </v-flex>

                        </v-layout>

                        <!-- PHONES SECTION -->
                        <master-customer-new-phones></master-customer-new-phones>
                        <div class="mb-2"></div>
                        <master-customer-new-banks></master-customer-new-banks>
                        <!-- END OF PHONES SECTION -->

                    </v-flex>
                </v-layout>
                
            </v-card-text>

            <v-card-actions>
                <v-btn color="primary" flat @click="dialog=!dialog">Batal</v-btn>                
                <v-spacer></v-spacer>
                <v-btn color="primary" @click="save" 
                    :disabled="customer_name == '' ||
                                customer_address.length<10">Simpan</v-btn>                
            </v-card-actions>
        </v-card>
        <customer-mp></customer-mp>
        <master-customer-similar></master-customer-similar>
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
let rnd = Math.round(Math.random() * 1e10)
module.exports = {
    components : {
        'customer-mp' : httpVueLoader('./master-customer-mp.vue'),
        'common-datepicker' : httpVueLoader('../../common/components/common-datepicker.vue'),
        "master-customer-similar" : httpVueLoader("./master-customer-similar.vue?t="+rnd),
        "master-customer-new-phones" : httpVueLoader("./master-customer-new-phones.vue?t="+rnd),
        "master-customer-new-banks" : httpVueLoader("./master-customer-new-banks.vue?t="+rnd),
        "master-customer-new-addresses" : httpVueLoader("./master-customer-new-addresses.vue?t="+rnd)
    },

    data () {
        return {
            
        }
    },

    computed : {
        URL () {
            return this.$store.state.customer_new.URL
        },

        edit () {
            return this.$store.state.customer_new.edit
        },

        dialog : {
            get () { return this.$store.state.customer_new.dialog_new },
            set (v) { this.$store.commit('customer_new/set_common', ['dialog_new', v]) }
        },

        search_city : {
            get () { return this.$store.state.customer_new.search_city },
            set (v) { this.$store.commit('customer_new/set_common', ["search_city", v]) }
        },

        selected_city : {
            get () { return this.$store.state.customer_new.selected_city },
            set (v) { 
                this.$store.commit('customer_new/set_selected_city', v) 
                this.$store.dispatch('customer_new/search_district', {})
            }
        },

        cities () {
            return this.$store.state.customer_new.cities
        },

        customer_name : {
            get () { return this.$store.state.customer_new.customer_name },
            set (v) { this.$store.commit('customer_new/set_common', ['customer_name', v]) }
        },

        customer_address : {
            get () { return this.$store.state.customer_new.customer_address },
            set (v) { this.$store.commit('customer_new/set_common', ['customer_address', v]) }
        },

        customer_phone : {
            get () { return this.$store.state.customer_new.customer_phone },
            set (v) { this.$store.commit('customer_new/set_common', ['customer_phone', v]) }
        },

        customer_note : {
            get () { return this.$store.state.customer_new.customer_note },
            set (v) { this.$store.commit('customer_new/set_common', ['customer_note', v]) }
        },

        customer_email : {
            get () { return this.$store.state.customer_new.customer_email },
            set (v) { this.$store.commit('customer_new/set_common', ['customer_email', v]) }
        },

        customer_postcode : {
            get () { return this.$store.state.customer_new.customer_postcode },
            set (v) { this.$store.commit('customer_new/set_common', ['customer_postcode', v]) }
        },

        customer_pic_name : {
            get () { return this.$store.state.customer_new.customer_pic_name },
            set (v) { this.$store.commit('customer_new/set_common', ['customer_pic_name', v]) }
        },

        customer_pic_phone : {
            get () { return this.$store.state.customer_new.customer_pic_phone },
            set (v) { this.$store.commit('customer_new/set_common', ['customer_pic_phone', v]) }
        },

        customer_npwp : {
            get () { return this.$store.state.customer_new.customer_npwp },
            set (v) { this.$store.commit('customer_new/set_common', ['customer_npwp', v]) }
        },

        customer_types () {
            return this.$store.state.customer_new.customer_types
        },

        selected_customer_type : {
            get () { return this.$store.state.customer_new.selected_customer_type },
            set (v) { this.$store.commit('customer_new/set_selected_customer_type', v) }
        },

        provinces () {
            return this.$store.state.customer_new.provinces
        },

        selected_province : {
            get () { return this.$store.state.customer_new.selected_province },
            set (v) { 
                this.$store.commit('customer_new/set_selected_province', v)
                this.$store.dispatch('customer_new/search_city', {})
            }
        },

        districts () {
            return this.$store.state.customer_new.districts
        },

        selected_district : {
            get () { return this.$store.state.customer_new.selected_district },
            set (v) { 
                this.$store.commit('customer_new/set_selected_district', v)
                this.$store.dispatch('customer_new/search_village', {})
            }
        },

        villages () {
            return this.$store.state.customer_new.villages
        },

        selected_village : {
            get () { return this.$store.state.customer_new.selected_village },
            set (v) { 
                this.$store.commit('customer_new/set_selected_village', v)
            }
        },

        email_validate (x) {
            return true
            const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            return re.test(String(this.customer_email).toLowerCase())
        },

        staffs () {
            return this.$store.state.customer_new.staffs
        },

        selected_staff : {
            get () { return this.$store.state.customer_new.selected_staff },
            set (v) { 
                this.$store.commit('customer_new/set_selected_staff', v)
            }
        },

        customer_prospect () {
            return this.$store.state.customer_new.customer_prospect
        },

        show_similar : {
            get () { 
                if (this.edit) return false
                if (this.customer_name.length < 5) return false
                if (this.$store.state.customer_new.similars.length<1) return false
                return this.$store.state.customer_new.show_similar 
            },
            set (v) { this.$store.commit('customer_new/set_common', ['show_similar', v]) }
        },

        selected_customer_type_id () {
            if (this.selected_customer_type)
                return this.selected_customer_type.id
            return ''
        }
    },

    methods : {
        thr_search: _.debounce( function () {            
            this.$store.commit("customer_new/set_common", ['search_city_status', 1]) // LOADING
            this.$store.dispatch("customer_new/search_city", [])
        }, 700),

        thr_search2: _.debounce( function () {            
            this.$store.dispatch("customer_new/search_similar")
        }, 700),

        save () {
            this.$store.dispatch('customer_new/save')
        },

        show_me_similar () {
            this.$store.commit('customer_new/set_common', ['dialog_similar', true])
        }
    },

    mounted () {
        this.$store.dispatch('customer_new/search_province', {})
        this.$store.dispatch('customer_new/search_staff', {})
        this.$store.dispatch('customer_new/search_bank', {})
        // this.$store.dispatch('customer_new/search_customer_level', {})
        // this.$store.dispatch('customer_new/search_mp')
    },

    watch : {
        search_city(val, old) { 
            
            if (this.$store.state.customer_new.edit) return
            if (val == null || typeof val == 'undefined') val = ""
            if (val == old ) return
            if (this.$store.state.customer_new.search_city_status == 1 ) return  
            
            this.$store.commit("customer_new/set_common", ["search_city", val])
            this.thr_search()
        },

        customer_name(val, old) {
            this.show_similar = false
            if (this.edit) return
            if (val == null || typeof val == 'undefined') val = ""
            if (val == old ) return
            if (this.$store.state.system.search_status == 1 ) return  
            if (val.length < 5) return

            this.thr_search2()
        }
    }
}
</script>