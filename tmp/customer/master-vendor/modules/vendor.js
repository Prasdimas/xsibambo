// 1 => LOADING
// 2 => DONE
// 3 => ERROR
import * as api from "./api_vendor.js"
import { one_token, URL } from "../../assets/js/global.js"

export default {
    namespaced: true,
    state: {
        URL: URL,
        token: one_token(),
        search_status: 0,
        search_error_message: '',
        search: '',
        
        vendors: [],
        total_vendor: 0,
        total_vendor_page: 0,
        selected_vendor: {},

        search_province_status: 0,
        provinces: [],
        selected_province: null,

        search_city_status: 0,
        cities: [],
        selected_city: null,

        selected_level: null,
        selected_vendor_type: null,

        current_page: 1,
        report_url: '',

        snackbar: false,
        snackbar_text: ''
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

        update_search_error_message(state, msg) {
            state.search_error_message = msg
        },

        update_search(state, search) {
            state.search = search
        },

        update_vendors(state, data) {
            state.vendors = data
        },

        set_selected_vendor(state, val) {
            state.selected_vendor = val
        },

        update_search_status(state, val) {
            state.search_status = val
        },

        update_total_vendor(state, val) {
            state.total_vendor = val
        },

        update_total_vendor_page(state, val) {
            state.total_vendor_page = val
        },

        update_current_page(state, val) {
            state.current_page = val
        },

        set_selected_level(state, val) {
            state.selected_level = val
        },

        set_provinces (state, v) { state.provinces = v },
        set_selected_province (state, v) { state.selected_province = v },

        set_cities (state, v) { state.cities = v },
        set_selected_city (state, v) { state.selected_city = v },
        set_selected_vendor_type (state, v) { state.selected_vendor_type = v }
    },
    actions: {
        async search(context, prm) {
            context.commit("update_search_status", 1)
            try {
                prm.token = one_token()
                prm.page = context.state.current_page
                prm.search = context.state.search
                prm.city = context.state.selected_city ? context.state.selected_city.M_CityID : 0
                prm.province= context.state.selected_province ? context.state.selected_province.M_ProvinceID : 0
                prm.type = ''
                if (context.state.selected_vendor_type)
                    prm.type = context.state.selected_vendor_type.id
                let resp = await api.search(prm)
                console.log(resp)
                if (resp.status != "OK") {
                    context.commit("update_search_status", 3)
                    context.commit("update_search_error_message", resp.message)
                } else {
                    context.commit("update_search_status", 2)
                    context.commit("update_search_error_message", "")
                    let data = {
                        records: resp.data.records,
                        total: resp.data.total,
                        total_page: resp.data.total_page
                    }

                    context.commit("update_vendors", data.records)
                    context.commit("update_total_vendor", data.total)
                    context.commit("update_total_vendor_page", data.total_page)
                }
            } catch (e) {
                context.commit("update_search_status", 3)
                context.commit("update_search_error_message", e.message)
                console.log(e)
            }
        },

        async del(context) {
            context.commit("update_search_status", 1)
            try {
                let prm = {token:one_token(),vendor_id:context.state.selected_vendor.vendor_id}
                let resp = await api.del(prm)
                console.log(resp)
                if (resp.status != "OK") {
                    context.commit("update_search_status", 3)
                    context.commit("update_search_error_message", resp.message)

                    context.commit('set_common', ['snackbar', true])
                    context.commit('set_common', ['snackbar_text', resp.message])
                } else {
                    context.commit("update_search_status", 2)
                    context.commit("update_search_error_message", "")
                    
                    context.dispatch('search', {})
                }
            } catch (e) {
                context.commit("update_search_status", 3)
                context.commit("update_search_error_message", e.message)
                console.log(e)
            }
        },

        async search_province(context) {
            context.commit("set_common", ["search_province_status", 1])
            try {
                let prm = {token : one_token()}
                let resp = await api.search_province(prm)
                if (resp.status != "OK") {
                    context.commit("set_common", ['search_province_status', 3])
                    context.commit("update_search_error_message", resp.message)
                } else {
                    context.commit("set_common", ["search_province_status", 2])
                    context.commit("update_search_error_message", "")
                    
                    context.commit("set_provinces", resp.data.records)
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
                }
            } catch (e) {
                context.commit("set_common", ["search_city_status", 3])
                context.commit("update_search_error_message", e.message)
            }
        }
    }
}