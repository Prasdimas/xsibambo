// 1 => LOADING
// 2 => DONE
// 3 => ERROR
import * as api from "./api_vendor.js"
import { URL, one_token, current_date } from "../../assets/js/global.js"

export default {
    namespaced: true,
    state: {
        URL: URL,
        edit: false,
        search_status: 0,
        search_error_message: '',
        search: '',
        
        selected_vendor: {},
        dialog_new: false,
        dialog_similar: false,
        
        search_city_status: 0,
        search_city: '',
        cities: [],
        selected_city: null,

        search_village_status: 0,
        search_village: '',
        villages: [],
        selected_village: null,

        search_district_status: 0,
        search_district: '',
        districts: [],
        selected_district: null,

        search_province_status: 0,
        search_province: '',
        provinces: [],
        selected_province: null,

        search_vendor_level_status: 0,
        vendor_levels: [],
        selected_vendor_level: null,

        vendor_name: "",
        vendor_address: "",
        vendor_phone: "",
        vendor_note: "",
        vendor_email: "",
        vendor_postcode: "",
        vendor_pic_name: "",
        vendor_pic_phone: "",
        vendor_npwp: "",
        vendor_auto: "N",
        vendor_mps: [],
        vendor_join_date: current_date(),
        vendor_prospect: 'N',
        current_date: current_date(),

        vendor_types: [{id:'N',text:'Personal'},{id:'Y',text:'Bisnis'}],
        selected_vendor_type: null,

        staffs: [],
        selected_staff: null,

        phones: [],
        selected_phone: null,
        template_phone: {no:"",wa:"N"},

        banks: [],
        selected_bank: null,

        cbanks: [],
        seleced_cbank: null,
        template_cbank: {bank:null,no:"",name:""},
        
        show_similar: false,
        similars: []
    },
    mutations: {
        set_common (state, v) {
            let name = v[0]
            let val = v[1]
            if (typeof(val) == "string")
                eval(`state.${name} = "${val}"`)
            else
                eval(`state.${name} = ${val}`)
        },

        update_search_error_message(state, msg) { state.search_error_message = msg },

        update_search(state, search) { state.search = search },

        set_selected_vendor(state, val) { state.selected_vendor = val },

        update_search_status(state, val) { state.search_status = val },

        set_dialog_new (state, v) { state.dialog_new = v },

        set_cities (state, v) { state.cities = v },
        set_selected_city (state, v) { state.selected_city = v },

        set_villages (state, v) { state.villages = v },
        set_selected_village (state, v) { state.selected_village = v },

        set_districts (state, v) {  state.districts = v },
        set_selected_district (state, v) { state.selected_district = v },

        set_provinces (state, v) { state.provinces = v },
        set_selected_province (state, v) { state.selected_province = v },

        set_vendor_levels (state, v) { state.vendor_levels = v },
        set_selected_vendor_level (state, v) { state.selected_vendor_level = v },

        set_phones (state, v) { state.phones = v },
        set_selected_phone (state, v) { state.selected_phone = v },
        set_vendor_address (state, v) { state.vendor_address = v },
        set_selected_vendor_type (state, v) { state.selected_vendor_type = v },

        set_staffs(state, val) { state.staffs = val },
        set_selected_staff(state, val) { state.selected_staff = val },

        set_banks(state, val) { state.banks = val },
        set_selected_bank(state, val) { state.selected_bank = val },

        set_cbanks(state, val) { state.cbanks = val },
        set_selected_cbank(state, val) { state.selected_cbank = val },

        set_similars(state, val) { state.similars = val }
    },
    actions: {
        async save(context) {
            if (!!context.rootState.vendor)
                context.commit('set_dialog_progress', true, {root:true})
                
            try {
                let phones = []
                let banks = []
                // let addresses = []
                for (let p of context.state.phones)
                    if (p.no != "") phones.push(p)

                for (let b of context.state.cbanks)
                    if (!!b.bank) banks.push({bank:b.bank.bank_id,number:b.no,name:b.name})

                // for (let ad of context.rootState.address.addresses)
                //     addresses.push({id:ad.address_id,name:ad.address_name,desc:ad.address_desc,
                //         city:ad.address_city.id,district:ad.address_district.id,village:ad.address_village.id,
                //         postcode:ad.address_postcode,pic_name:ad.address_pic_name,phones:ad.address_phones})
                    
                let prm = {token : one_token(), 
                            vendor_name: context.state.vendor_name,
                            vendor_address: context.state.vendor_address,
                            vendor_phone: context.state.vendor_phone,
                            vendor_phones: JSON.stringify(phones),
                            vendor_note: context.state.vendor_note,
                            vendor_email: context.state.vendor_email,
                            vendor_postcode: context.state.vendor_postcode,
                            vendor_pic_name: context.state.vendor_pic_name,
                            vendor_pic_phone: context.state.vendor_pic_phone,
                            vendor_npwp: context.state.vendor_npwp,
                            // vendor_type: context.state.selected_vendor_type.id,
                            vendor_prospect: context.state.vendor_prospect,
                            // vendor_auto: context.state.vendor_auto,
                            // vendor_level_id: context.state.selected_vendor_level.M_VendorLevelID,
                            vendor_city_id: context.state.selected_city.M_CityID,
                            vendor_district_id: context.state.selected_district?context.state.selected_district.M_DistrictID:0,
                            vendor_kelurahan_id: context.state.selected_village?context.state.selected_village.M_KelurahanID:0,
                            // vendor_staff: context.state.selected_staff?context.state.selected_staff.staff_id:0,

                            bdata: JSON.stringify(banks),
                            // addresses: JSON.stringify(addresses)
                            // vendor_join_date: context.state.vendor_join_date,
                        }
                if (context.state.edit)
                    prm.vendor_id = context.rootState.vendor.selected_vendor.vendor_id

                let resp = await api.save(prm)
                
                if (resp.status != "OK") {
                    context.commit("update_search_status", 3)
                    context.commit("update_search_error_message", resp.message)
                    context.commit('set_dialog_progress', false, {root:true})
                } else {
                    context.commit("set_common", ["search_status", 2])
                    context.commit("update_search_error_message", "")
                    
                    context.commit("set_common", ["dialog_new", false])
                    if (!!context.rootState.vendor) {
                        context.dispatch("vendor/search", {}, {root:true})
                        context.commit('set_dialog_progress', false, {root:true})
                    }
                        
                    if (!!context.rootState.sales_new) {
                        context.commit('sales_new/set_selected_vendor', {vendor_id:resp.data}, {root:true})
                        context.dispatch('sales_new/search_vendor', {}, {root:true})
                    }
                        // 
                        
                }
            } catch (e) {
                context.commit("set_common", ["search_city_status", 3])
                context.commit("update_search_error_message", e.message)
                context.commit('set_dialog_progress', false, {root:true})
                console.log(e)
            }
        },

        async search_province(context) {
            context.commit("set_common", ["search_province_status", 1])
            try {
                let prm = {token : one_token(), search:context.state.search_province}
                let resp = await api.search_province(prm)
                if (resp.status != "OK") {
                    context.commit("set_common", ['search_province_status', 3])
                    context.commit("update_search_error_message", resp.message)
                } else {
                    context.commit("set_common", ["search_province_status", 2])
                    context.commit("update_search_error_message", "")
                    
                    context.commit("set_provinces", resp.data.records)
                    if (context.state.edit) {
                        for (let pv of resp.data.records)
                            if (pv.M_ProvinceID == context.rootState.vendor.selected_vendor.province_id) {
                                context.commit('set_selected_province', pv)
                                context.dispatch('search_city')
                            }
                    }
                }
            } catch (e) {
                context.commit("set_common", ["search_province_status", 3])
                context.commit("update_search_error_message", e.message)
            }
        },

        async search_city(context) {
            context.commit("set_common", ["search_city_status", 1])
            try {
                let prm = { token : one_token(), search:context.state.search_city, province_id:context.state.selected_province.M_ProvinceID }
                let resp = await api.search_city(prm)
                if (resp.status != "OK") {
                    context.commit("set_common", ["search_city_status", 3])
                    context.commit("update_search_error_message", resp.message)
                } else {
                    context.commit("set_common", ["search_city_status", 2])
                    context.commit("update_search_error_message", "")
                    
                    context.commit("set_cities", resp.data.records)
                    if (context.state.edit) {
                        for (let pv of resp.data.records)
                            if (pv.M_CityID == context.rootState.vendor.selected_vendor.city_id) {
                                context.commit('set_selected_city', pv)
                                context.dispatch('search_district')
                            }
                    }
                }
            } catch (e) {
                context.commit("set_common", ["search_city_status", 3])
                context.commit("update_search_error_message", e.message)
            }
        },

        async search_district(context) {
            context.commit("set_common", ["search_district_status", 1])
            try {
                let prm = { token : one_token(), search:context.state.search_district, city_id:context.state.selected_city.M_CityID }
                let resp = await api.search_district(prm)
                if (resp.status != "OK") {
                    context.commit("set_common", ["search_district_status", 3])
                    context.commit("update_search_error_message", resp.message)
                } else {
                    context.commit("set_common", ["search_district_status", 2])
                    context.commit("update_search_error_message", "")
                    
                    context.commit("set_districts", resp.data.records)
                    if (context.state.edit) {
                        for (let pv of resp.data.records)
                            if (pv.M_DistrictID == context.rootState.vendor.selected_vendor.district_id) {
                                context.commit('set_selected_district', pv)
                                context.dispatch('search_village')
                            }
                    }
                }
            } catch (e) {
                context.commit("set_common", ["search_district_status", 3])
                context.commit("update_search_error_message", e.message)
            }
        },

        async search_village(context) {
            context.commit("set_common", ["search_village_status", 1])
            try {
                let prm = { token : one_token(), search:context.state.search_village, district_id:context.state.selected_district.M_DistrictID }
                let resp = await api.search_village(prm)
                if (resp.status != "OK") {
                    context.commit("set_common", ["search_village_status", 3])
                    context.commit("update_search_error_message", resp.message)
                } else {
                    context.commit("set_common", ["search_village_status", 2])
                    context.commit("update_search_error_message", "")
                    
                    context.commit("set_villages", resp.data.records)
                    if (context.state.edit) {
                        for (let pv of resp.data.records)
                            if (pv.M_KelurahanID == context.rootState.vendor.selected_vendor.village_id) {
                                context.commit('set_selected_village', pv)
                            }
                    }
                }
            } catch (e) {
                context.commit("set_common", ["search_village_status", 3])
                context.commit("update_search_error_message", e.message)
            }
        },

        async search_vendor_level(context) {
            context.commit("set_common", ["search_vendor_level_status", 1])
            try {
                let prm = { token : one_token() }
                let resp = await api.search_vendor_level(prm)
                if (resp.status != "OK") {
                    context.commit("set_common", ["search_vendor_level_status", 3])
                    context.commit("update_search_error_message", resp.message)
                } else {
                    context.commit("set_common", ["search_vendor_level_status", 2])
                    context.commit("update_search_error_message", "")
                    
                    context.commit("set_vendor_levels", resp.data.records)
                }
            } catch (e) {
                context.commit("set_common", ["search_vendor_level_status", 3])
                context.commit("update_search_error_message", e.message)
            }
        },

        async search_staff(context) {
            let prm = {
                search : '',
                position : 'POS.ADMIN',
                page : 1
            }

            context.dispatch("system/postme", {
                url:"systm/staff/search",
                prm:prm,
                callback:function(d) {
                    context.commit("set_staffs", d.records)
                }
            }, {root:true})
        },

        async search_similar(context) {
            let prm = {
                search : context.state.vendor_name
            }

            context.dispatch("system/postme", {
                url:"master/vendor/search_similar",
                prm:prm,
                callback:function(d) {
                    context.commit('set_common', ['show_similar', true])
                    context.commit('set_similars', d)
                }
            }, {root:true})
        },

        async search_bank(context) {
            let prm = {
                search : '',
                page : 1,
                limit : 1000
            }

            context.dispatch("system/postme", {
                url:"master/bank/search",
                prm:prm,
                callback:function(d) {
                    context.commit("set_banks", d.records)
                }
            }, {root:true})
        }
    }
}