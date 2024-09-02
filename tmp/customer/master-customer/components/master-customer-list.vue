<template>
    <v-card>
        <v-card-title primary-title class="pt-2 pb-0">
            <v-layout row wrap>
                <v-flex xs4>
                    <h3 class="display-1 font-weight-light zalfa-text-title">DATA CUSTOMER</h3>
                </v-flex>

                <v-flex xs2 pr-2>
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
                            hide-details
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

                <v-flex xs2 pr-2>
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
                            hide-details
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

                <v-flex xs2>
                    <v-select
                        :items="customer_types"
                        v-model="selected_customer_type"
                        item-text="text"
                        item-value="id"
                        return-object
                        solo
                        placeholder="Tipe Customer"
                        hide-details
                        clearable
                    ></v-select>    
                </v-flex>

                <v-flex xs2 class="text-xs-right" pl-3>
                    
                    <v-text-field
                        solo
                        hide-details
                        placeholder="Pencarian" 
                        v-model="query"
                        @keyup="do_search($event)"
                    >
                        <template v-slot:append-outer>
                            <v-btn color="primary" class="ma-0 btn-icon" @click="do_search">
                                <v-icon>search</v-icon>
                            </v-btn>      

                            <v-btn color="success" class="ma-0 ml-2 btn-icon" @click="add">
                                <v-icon>add</v-icon>
                            </v-btn>  
                        </template>
                    </v-text-field>
                    
                
                    <!-- <v-btn color="success" class="ma-0 btn-icon" @click="add">
                        <v-icon>add</v-icon>
                    </v-btn> -->
                </v-flex>
            </v-layout>
        </v-card-title>
        <v-card-text class="pt-2">
            <v-data-table 
                :headers="headers"
                :items="customers"
                :loading="false"
                hide-actions
                class="elevation-1">
                <template slot="items" slot-scope="props">
                    <td class="text-xs-left pa-2" v-bind:class="level_color(props.item.customer_type)" @click="select(props.item)"><b>{{ props.item.customer_code }}</b></td>
                    <td class="text-xs-left pa-2" v-bind:class="level_color(props.item.customer_type)" @click="select(props.item)"><b>{{ props.item.customer_name }}</b><br>
                    <div v-show="props.item.customer_prospect=='Y'" class="blue--text"><i>( Prospek )</i></div>
                    <!-- <v-icon small>smartphone</v-icon>{{props.item.M_CustomerPhone}} -->
                    </td>
                    <td class="text-xs-left pa-2" v-bind:class="level_color(props.item.customer_type)" @click="select(props.item)">{{ props.item.customer_address }}, {{ props.item.address_kelurahan }}</td>
                    <td class="text-xs-left pa-2" v-bind:class="level_color(props.item.customer_type)" @click="select(props.item)">{{ props.item.city_name }}</td>
                    <td class="text-xs-left pa-2" v-bind:class="level_color(props.item.customer_type)" @click="select(props.item)">{{ props.item.province_name }}</td>
                    <td class="text-xs-left pa-2" v-bind:class="level_color(props.item.customer_type)" @click="select(props.item)">{{ props.item.customer_type == 'Y' ? 'BISNIS' : 'PERSONAL' }}</td>
                    <td class="text-xs-center pa-0" v-bind:class="level_color(props.item.customer_type)" @click="select(props.item)">
                        <v-btn color="primary" class="btn-icon ma-0" small @click="edit(props.item)"><v-icon>create</v-icon></v-btn>
                        <v-btn color="red" dark class="btn-icon ma-0" small @click="del(props.item)"><v-icon>delete</v-icon></v-btn>
                    </td>
                    <!-- <td class="text-xs-center pa-2" v-bind:class="{'amber lighten-4':isSelected(props.item)}" @click="selectMe(props.item)">{{ props.item.M_DoctorHP}}</td>
                    <td class="text-xs-left pa-2" v-bind:class="{'amber lighten-4':isSelected(props.item)}" @click="selectMe(props.item)">{{ props.item.status}}</td> -->
                </template>
            </v-data-table>
            <v-divider></v-divider>
            <v-pagination
                style="margin-top:10px;margin-bottom:10px"
                v-model="curr_page"
                :length="xtotal_page"
                @input="change_page"
            ></v-pagination>
        </v-card-text>
        
        <v-snackbar
            v-model="snackbar"
            multi-line
            :timeout="3000"
            top
            vertical
            >
            {{ snackbar_text }}
            <v-btn
                color="pink"
                flat
                @click="snackbar = false"
            >
                Tutup
            </v-btn>
        </v-snackbar>
        
        <common-dialog-delete :data="customer_id" @confirm_del="confirm_del" v-if="dialog_delete"></common-dialog-delete>
    </v-card>
</template>

<style scoped>
.v-text-field.v-text-field--solo .v-input__control {
    min-height: 36px;
}
.v-text-field.v-text-field--solo .v-input__append-outer {
    margin-top: 0px;
    margin-left: 0px;
}
</style>

<script>
module.exports = {
    components : {
        "common-dialog-delete" : httpVueLoader("../../common/components/common-dialog-delete.vue")
    },

    data () {
        return {
            headers: [
                {
                    text: "NOMOR",
                    align: "left",
                    sortable: false,
                    width: "8%",
                    class: "pa-2 zalfa-bg-purple lighten-3 white--text"
                },
                {
                    text: "NAMA",
                    align: "left",
                    sortable: false,
                    width: "15%",
                    class: "pa-2 zalfa-bg-purple lighten-3 white--text"
                },
                {
                    text: "ALAMAT",
                    align: "left",
                    sortable: false,
                    width: "37%",
                    class: "pa-2 zalfa-bg-purple lighten-3 white--text"
                },
                {
                    text: "KOTA",
                    align: "left",
                    sortable: false,
                    width: "10%",
                    class: "pa-2 zalfa-bg-purple lighten-3 white--text"
                },
                {
                    text: "PROPINSI",
                    align: "left",
                    sortable: false,
                    width: "10%",
                    class: "pa-2 zalfa-bg-purple lighten-3 white--text"
                },
                {
                    text: "TIPE",
                    align: "left",
                    sortable: false,
                    width: "10%",
                    class: "pa-2 zalfa-bg-purple lighten-3 white--text"
                },
                {
                    text: "ACTION",
                    align: "center",
                    sortable: false,
                    width: "10%",
                    class: "pa-2 zalfa-bg-purple lighten-3 white--text"
                }
            ]
        }
    },

    computed : {
        customers () {
            return this.$store.state.customer.customers
        },

        customer_types () {
            return this.$store.state.customer.customer_types
        },

        dialog_delete () {
            return this.$store.state.dialog_delete
        },

        customer_id () {
            return this.$store.state.customer.selected_customer.M_CustomerID
        },

        curr_page : {
            get () { return this.$store.state.customer.current_page },
            set (v) { this.$store.commit('customer/update_current_page', v) }
        },

        xtotal_page () {
            return this.$store.state.customer.total_customer_page
        },

        levels () {
            return this.$store.state.customer_new.customer_levels
        },

        selected_level : {
            get () { return this.$store.state.customer.selected_level },
            set (v) { 
                this.$store.commit('customer/set_selected_level', v) 
                this.$store.dispatch('customer/search', {})
            }
        },

        query : {
            get () { return this.$store.state.customer.search },
            set (v) { this.$store.commit('customer/update_search', v) }
        },

        provinces () {
            return this.$store.state.customer.provinces
        },

        selected_province : {
            get () { return this.$store.state.customer.selected_province },
            set (v) { 
                this.$store.commit('customer/set_selected_province', v)
                this.$store.dispatch('customer/search_city', {})
                // this.$store.dispatch('customer/search', {})
            }
        },

        selected_city : {
            get () { return this.$store.state.customer.selected_city },
            set (v) { 
                this.$store.commit('customer/set_selected_city', v)
                // this.$store.dispatch('customer/search', {})
            }
        },

        cities () {
            return this.$store.state.customer.cities
        },

        customer_types () {
            return this.$store.state.customer_new.customer_types
        },

        selected_customer_type : {
            get () { return this.$store.state.customer.selected_customer_type },
            set (v) { 
                this.$store.commit('customer/set_selected_customer_type', v) 
                this.$store.dispatch('customer/search', {})
            }
        },

        snackbar : {
            get () { return this.$store.state.customer.snackbar },
            set (v) { this.$store.commit('customer/set_common', ['snackbar', v]) }
        },

        snackbar_text () {
            return this.$store.state.customer.snackbar_text
        }
    },

    methods : {
        add () {
            this.$store.commit('customer_new/set_common', ['edit', false])
            this.$store.commit('customer_new/set_common', ['customer_name', ''])
            this.$store.commit('customer_new/set_common', ['customer_address', ''])
            this.$store.commit('customer_new/set_common', ['customer_phone', ''])
            this.$store.commit('customer_new/set_common', ['customer_note', ''])
            this.$store.commit('customer_new/set_common', ['customer_email', ''])
            this.$store.commit('customer_new/set_common', ['customer_postcode', ''])
            this.$store.commit('customer_new/set_common', ['customer_pic_name', ''])
            this.$store.commit('customer_new/set_common', ['customer_pic_phone', ''])
            this.$store.commit('customer_new/set_common', ['customer_npwp', ''])
            this.$store.commit('customer_new/set_common', ['customer_prospect', 'N'])
            this.$store.commit('customer_new/set_phones', [])
            this.$store.commit('customer_new/set_cbanks', [])
            this.$store.commit('address/set_addresses', [])
            this.$store.commit('address/set_selected_address', null)
            
            this.$store.commit('customer_new/set_selected_province', null)
            this.$store.commit('customer_new/set_selected_city', null)
            this.$store.commit('customer_new/set_selected_district', null)
            this.$store.commit('customer_new/set_selected_village', null)
            this.$store.commit('customer_new/set_selected_staff', null)
            this.$store.commit('customer_new/set_selected_customer_type', 
                this.customer_types[0])
            this.$store.commit('customer_new/set_dialog_new', true)
        },

        edit (x) {
            this.select(x)
            let sc = x
            this.$store.commit('customer_new/set_common', ['edit', true])
            this.$store.commit('customer_new/set_common', ['customer_name', sc.customer_name])
            this.$store.commit('customer_new/set_customer_address', sc.customer_address)
            this.$store.commit('customer_new/set_common', ['customer_phone', sc.customer_phone])
            this.$store.commit('customer_new/set_common', ['customer_note', sc.customer_note])
            this.$store.commit('customer_new/set_common', ['customer_email', sc.customer_email])
            this.$store.commit('customer_new/set_common', ['customer_postcode', sc.customer_postcode?sc.customer_postcode:''])
            this.$store.commit('customer_new/set_common', ['customer_pic_name', sc.customer_pic_name?sc.customer_pic_name:''])
            this.$store.commit('customer_new/set_common', ['customer_pic_phone', sc.customer_pic_phone?sc.customer_pic_phone:''])
            this.$store.commit('customer_new/set_common', ['customer_npwp', sc.customer_npwp?sc.customer_npwp:''])
            this.$store.commit('customer_new/set_common', ['customer_prospect', sc.customer_prospect?sc.customer_prospect:'N'])
            this.$store.commit('customer_new/set_phones', sc.customer_phones)
            this.$store.commit('customer_new/set_cbanks', sc.banks)
            this.$store.commit('address/set_addresses', sc.addresses)
            this.$store.commit('address/set_selected_address', null)

            this.$store.commit('customer_new/set_selected_province', null)
            this.$store.commit('customer_new/set_selected_city', null)
            this.$store.commit('customer_new/set_selected_district', null)
            this.$store.commit('customer_new/set_selected_village', null)
            this.$store.commit('customer_new/set_selected_staff', null)
            
            // Province
            this.$store.dispatch('customer_new/search_province')

            this.$store.commit('customer_new/set_selected_customer_type', 
                this.customer_types[0])
            for (let t of this.customer_types)
                if (t.id == sc.customer_type) 
                    this.$store.commit('customer_new/set_selected_customer_type', t)

            for (let s of this.$store.state.customer_new.staffs)
                if (s.staff_id == sc.customer_staff) 
                    this.$store.commit('customer_new/set_selected_staff', s)

            // this.$store.commit('customer_new/set_common', ['search_city', sc.full_address])
            // this.$store.commit('customer_new/set_selected_city', {kelurahan_id:sc.kelurahan_id,full_address:sc.full_address})
            this.$store.commit('customer_new/set_dialog_new', true)
        },

        del (x) {
            this.select(x)
            this.$store.commit('set_dialog_delete', true)
        },

        confirm_del (x) {
            this.$store.dispatch('customer/del', {id:x.data})
        },

        select (x) {
            this.$store.commit('customer/set_selected_customer', x)
        },

        change_page(x) {
            this.curr_page = x
            this.$store.dispatch('customer/search', {})
        },

        do_search(e) {
            if (e.which == 13)
                this.$store.dispatch('customer/search', {})
        },

        level_color (x) {
            if (x == 'Y')
                return 'cyan lighten-4'
            return 'white'
            // if (x == 'CUST.DISTRIBUTOR')
            //     return 'pink lighten-4'
            // if (x == 'CUST.AGENCY')
            //     return 'orange lighten-4'
            // if (x == 'CUST.RESELLER')
            //     return 'yellow lighten-4'
            // if (x == 'CUST.FAMILY')
            //     return 'green lighten-4'
            // return 'cyan lighten-4'
        },
        
        report () {
            let params = ['province_id='+(this.selected_province?this.selected_province.M_ProvinceID:0), 
                    'city_id='+(this.selected_city?this.selected_city.M_CityID:0),
                    'level_id='+(this.selected_level?this.selected_level.M_CustomerLevelID:0),
                    'token='+this.$store.state.customer.token].join('&')
            let urls = this.$store.state.customer.URL+'report/one_master_001'+
                        '?'+params
            this.$store.commit('customer/set_common', ['report_url', urls])
            this.$store.commit('set_dialog_print', true)
        },

        duration(x) {
            let d1 = window.moment(x)
            let d2 = window.moment(window.moment().format("YYYY-MM-DD"))

            let y = d2.diff(d1, "years")
            let m = d2.diff(d1, "months")
            let md = d2.diff(d1, "months", true)
            let d = d2.diff(d1, "days")
            if (y < 1) {
                if (m > 0 && d > 14)
                    return m + ",5 bulan"
                else if (m > 0)
                    return m + " bulan"
                else
                    return d + " hari"
            } else if (y < 5 && m > 5) {
                return y + ",5 tahun"
            } else {
                return y + " tahun"
            }
        }
    },

    mounted () {
        this.$store.dispatch('customer/search_province', {})
    },

    watch : {
        selected_city (v, o) {
            if (v != o)
                this.$store.dispatch('customer/search', {})
        },

        selected_province (v, o) {
            if (v != o)
                if (this.$store.state.customer.selected_city != null)
                    this.$store.commit('customer/set_selected_city', null)
                else
                    this.$store.dispatch('customer/search', {})
        }
    }
}
</script>