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

        search_address_level_status: 0,
        address_levels: [],
        selected_address_level: null,

        address_idx: 0,
        address_id: 0,
        address_name: "",
        address_desc: "",
        address_phone: "",
        address_postcode: "",
        address_pic_name: "",
        address_pic_phone: "",

        phones: [],
        selected_phone: null,
        template_phone: {no:"",wa:"N"},

        addresses: [],
        selected_address: null
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

        set_phones (state, v) { state.phones = v },
        set_selected_phone (state, v) { state.selected_phone = v },
        set_address_desc (state, v) { state.address_desc = v },

        set_addresses(state, val) { state.addresses = val },
        set_selected_address(state, val) { state.selected_address = val }
    },
    actions: {
        async save(context) {
            let addresses = JSON.parse(JSON.stringify(context.state.addresses))
            let phones = []
            let phone = []
            for (let p of context.state.phones)
                if (p.no != "") {
                    phones.push(p)
                    phone.push(phone_format(p.no))
                }

            let addr = {
                address_id: 0,
                address_name: context.state.address_name,
                address_desc: context.state.address_desc,
                address_phones: JSON.stringify(phones),
                address_phone: phone.join(', '),
                address_postcode: context.state.address_postcode,
                address_pic_name: context.state.address_pic_name,
                address_province: {id:context.state.selected_province.M_ProvinceID,name:context.state.selected_province.M_ProvinceName},
                address_city: {id:context.state.selected_city.M_CityID,name:context.state.selected_city.M_CityName},
                address_district: context.state.selected_district?
                    {id:context.state.selected_district.M_DistrictID,name:context.state.selected_district.M_DistrictName}:null,
                address_village: context.state.selected_village?
                    {id:context.state.selected_village.M_KelurahanID,name:context.state.selected_village.M_KelurahanName}:null
            }

            if (context.state.edit) {
                addr.address_id = context.state.address_id
                addresses[context.state.address_idx] = addr
            }
            else {
                addresses.push(addr)
            }

            context.commit('set_addresses', addresses)
            context.commit('set_common', ['dialog_new', false])
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
                            if (pv.M_ProvinceID == context.state.selected_address.address_province.id) {
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
                            if (pv.M_CityID == context.state.selected_address.address_city.id) {
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
                            if (pv.M_DistrictID == context.state.selected_address.address_district.id) {
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
                            if (pv.M_KelurahanID == context.state.selected_address.address_village.id) {
                                context.commit('set_selected_village', pv)
                            }
                    }
                }
            } catch (e) {
                context.commit("set_common", ["search_village_status", 3])
                context.commit("update_search_error_message", e.message)
            }
        }
    }
}