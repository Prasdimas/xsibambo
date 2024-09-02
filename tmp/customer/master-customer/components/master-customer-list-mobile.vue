<template>
    <v-card>
        <v-card-title primary-title class="pt-2 pb-0 px-2">
            <v-layout row wrap>
                <v-flex xs12 sm7 mb-2>
                    <h3 class="display-1 font-weight-light zalfa-text-title">Masterdata Customer</h3>
                </v-flex>

                <v-flex xs12 sm5 class="text-xs-right">
                    <v-text-field
                        solo
                        hide-details
                        placeholder="Pencarian" v-model="query"
                        @keyup="do_search"
                    >
                        <template v-slot:append-outer>
                            <v-btn color="primary" class="ma-0 btn-icon hidden-xs-only" @click="search">
                                <v-icon>search</v-icon>
                            </v-btn>      

                            <v-btn color="purple" class="ma-0 ml-2 btn-icon hidden-xs-only" @click="filter" dark>
                                <v-icon>filter_list</v-icon>
                            </v-btn>

                            <v-btn color="success" class="ma-0 ml-2 btn-icon hidden-xs-only" @click="add">
                                <v-icon>add</v-icon>
                            </v-btn>
                            
                        </template>

                        <template v-slot:prepend>
                            <v-btn color="success" class="ma-0 mr-1 btn-icon hidden-sm-and-up" @click="add">
                                <v-icon>add</v-icon>
                            </v-btn>
                            
                            <v-btn color="purple" class="ma-0 mr-1 btn-icon hidden-sm-and-up" @click="filter" dark>
                                <v-icon>filter_list</v-icon>
                            </v-btn>

                            <v-btn color="primary" class="ma-0 btn-icon hidden-sm-and-up" @click="search">
                                <v-icon>search</v-icon>
                            </v-btn>
                        </template>
                    </v-text-field>
                    
                </v-flex>

                <v-flex xs12 sm12 :class="{'text-xs-right':$vuetify.breakpoint.smOnly}" v-if="!!selected_city||!!selected_level||!!selected_province">
                    Filter : {{selected_province?selected_province.M_ProvinceName:''}},
                            {{selected_city?selected_city.M_CityName:''}},
                            {{selected_level?selected_level.M_CustomerLevelName:''}}
                    <span class="ml-2"><a href="#" @click="reset_filter">Reset</a></span>
                </v-flex>
            </v-layout>
        </v-card-title>
        <v-card-text class="pt-2 px-2">

            <v-card v-for="(customer, n) in customers" v-bind:key="n" class="mb-2" @click="edit(customer)">
                <v-card-title primary-title class="pa-2 grey lighten-2">
                    <v-layout row wrap>
                        <v-flex xs8>
                            <b>{{ customer.M_CustomerName }}</b>, {{ customer.M_CityName }}</v-flex>
                        <v-flex xs4 class="text-xs-right blue--text">
                            {{ customer.M_CustomerLevelName }}
                            </v-flex>
                    </v-layout>                        
                </v-card-title>
                <v-card-text class="pa-2">
                    <v-layout row wrap>
                        <v-flex xs6>
                            {{customer.M_CustomerAddress}}<br>
                            {{customer.M_CityName}}, {{customer.M_ProvinceName}}
                            <!-- <div class="caption">Total belanja :</div>
                            <v-layout row wrap>
                                <v-flex xs4 class="orange--text">Rp</v-flex>
                                <v-flex xs8 class="text-xs-right title orange--text">{{one_money(item.L_SoTotal)}}</v-flex>
                            </v-layout> -->
                        </v-flex>
                        <v-flex xs5 offset-xs1 class="text-xs-right">
                            <b>{{customer.M_CustomerCode}}</b><br>
                            {{customer.M_CustomerPhone}} <v-icon small>smartphone</v-icon>
                            <!-- <div class="caption">Status :</div>
                            <div v-for="(i, n) in status_render(item.M_OrderStatusSellerName)" v-bind:key="n" :class="status_color(item.M_OrderStatusCode)+'--text'">
                            {{ i }}
                            </div> -->
                        </v-flex>
                    </v-layout>
                </v-card-text>
            </v-card>

            <v-divider></v-divider>
            <v-pagination
                style="margin-top:10px;margin-bottom:10px"
                v-model="curr_page"
                :length="xtotal_page"
                @input="change_page"
            ></v-pagination>
        </v-card-text>
        
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
.v-text-field.v-text-field--solo .v-input__append-outer, .v-text-field.v-text-field--solo .v-input__prepend-outer {
    margin-top: 0px;
    margin-left: 0px;
}
.v-input__prepend-outer {
    margin-right: 0px;
}
</style>

<script>
module.exports = {
    components : {
        "common-dialog-delete" : httpVueLoader("../../common/components/common-dialog-delete.vue")
    },

    data () {
        return {
        }
    },

    computed : {
        customers () {
            return this.$store.state.customer.customers
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
        }
    },

    methods : {
        add () {
            this.$store.commit('customer_new/set_common', ['edit', false])
            this.$store.commit('customer_new/set_common', ['customer_name', ''])
            this.$store.commit('customer_new/set_common', ['customer_address', ''])
            this.$store.commit('customer_new/set_common', ['customer_phone', ''])
            this.$store.commit('customer_new/set_common', ['customer_email', ''])
            this.$store.commit('customer_new/set_common', ['customer_note', ''])
            this.$store.commit('customer_new/set_common', ['customer_postcode', ''])
            this.$store.commit('customer_new/set_common', ['customer_auto', 'N'])
            this.$store.commit('customer_new/set_common', ['user_customer', 'N'])
            this.$store.commit('customer_new/set_common', ['user_customer_username', ''])
            this.$store.commit('customer_new/set_common', ['user_customer_password', ''])
            this.$store.commit('customer_new/set_common', ['user_customer_password_confirm', ''])
            this.$store.commit('customer_new/set_selected_customer_level', null)
            this.$store.commit('customer_new/set_selected_province', null)
            this.$store.commit('customer_new/set_selected_city', null)
            this.$store.commit('customer_new/set_selected_district', null)
            this.$store.commit('customer_new/set_selected_village', null)
            this.$store.commit('customer_new/set_dialog_new', true)
        },

        edit (x) {
            this.select(x)
            let sc = x
            this.$store.commit('customer_new/set_common', ['edit', true])
            this.$store.commit('customer_new/set_common', ['customer_name', sc.M_CustomerName])
            this.$store.commit('customer_new/set_common', ['customer_address', sc.M_CustomerAddress])
            this.$store.commit('customer_new/set_common', ['customer_phone', sc.M_CustomerPhone])
            this.$store.commit('customer_new/set_common', ['customer_email', sc.M_CustomerEmail])
            this.$store.commit('customer_new/set_common', ['customer_note', sc.M_CustomerNote])
            this.$store.commit('customer_new/set_common', ['customer_postcode', sc.M_CustomerPostCode?sc.M_CustomerPostCode:''])
            this.$store.commit('customer_new/set_common', ['customer_auto', sc.M_CustomerAutoAccept?sc.M_CustomerAutoAccept:'N'])

            // USER
            this.$store.commit('customer_new/set_common', ['change_password', false])
            this.$store.commit('customer_new/set_common', ['user_customer', 'N'])
            this.$store.commit('customer_new/set_common', ['user_customer_id', 0])
            this.$store.commit('customer_new/set_common', ['user_customer_username', ''])
            this.$store.commit('customer_new/set_common', ['user_customer_password', ''])
            this.$store.commit('customer_new/set_common', ['user_customer_password_confirm', ''])
            if (sc.user_customer_id) {
                this.$store.commit('customer_new/set_common', ['user_customer', 'Y'])
                this.$store.commit('customer_new/set_common', ['user_customer_id', sc.user_customer_id])
                this.$store.commit('customer_new/set_common', ['user_customer_username', sc.user_customer_username])
            }

            // Customer Level
            for (let cl of this.$store.state.customer_new.customer_levels)
                if (cl.M_CustomerLevelID == x.M_CustomerM_CustomerLevelID)
                    this.$store.commit('customer_new/set_selected_customer_level', cl)

            // Province
            this.$store.dispatch('customer_new/search_province')

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

        search() {
            this.$store.dispatch('customer/search', {})
        },

        do_search(e) {
            if (e.which == 13)
                this.$store.dispatch('customer/search', {})
        },

        level_color (x) {
            if (x == 'CUST.DISTRIBUTOR')
                return 'pink lighten-4'
            if (x == 'CUST.AGENCY')
                return 'orange lighten-4'
            if (x == 'CUST.RESELLER')
                return 'yellow lighten-4'
            if (x == 'CUST.FAMILY')
                return 'green lighten-4'
            return 'cyan lighten-4'
        },

        filter () {
            this.$store.commit('customer_filter/set_common', ['dialog_filter', true])
        },

        reset_filter () {
            this.selected_province = null
            this.selected_city = null
            this.selected_level = null
            this.$store.dispatch('customer/search', {})
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