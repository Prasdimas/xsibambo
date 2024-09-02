export default {
    namespaced: true,
    state : {
        vendors: [],
        totalVendor: 0,
        totalVendorPage: 1,
        curPage: 1,

        selectedVendor: {},
        vendorId: 0,
        vendorName: "",
        vendorAddress: "",

        provinces: [],
        selectedProvince: null,

        contacts: [],
        selectedContact: null,

        cities: [],
        selectedCity: null,

        snackbar: false,
        snackbar_text: '',

        search: '',
        edit: false,
        dialog: false,
        dialogDelete: false,
    },
    mutations: {
        SET_OBJECT(state, v) {
            let name = v[0]
            let val = v[1]
            state[name] = val
        },
        SET_OBJECTS(state, v) {
            let name = v[0]
            let val = v[1]
            for (let i = 0; i < name.length; i++)
                state[name[i]] = val[i]
        },
    },
    actions: {
        async search(context) {
            let prm = {
                search: context.state.search,
                page: context.state.curPage
            }

            return context.dispatch("postme", {
                url: "master/vendor/search",
                prm: prm,
                callback: function(d) {
                    context.commit("SET_OBJECTS", [
                        ["vendors", "totalPos", "totalPosPage"],
                        [d.records, d.totalVendor, d.totalVendorPage]
                    ])
                    return d
                }
            }, { root: true })
        },

        async provinces(context) {            
            return context.dispatch("postme", {
                url: "master/province/search",
                prm: "",
                calback: function(d) {
                    context.commit("SET_OBJECTS", [['provinces'],[d.records]])
                }
            },{root:true})
        },

        async searchDd(context) {
            let prm = {
                search: context.state.search
            }

            return context.dispatch("postme", {
                url: "master/vendor/search_dd",
                prm: prm,
                callback: function(d) {
                    return d
                }
            }, { root: true })
        },

        async save(context) {
            let prm = {
                vendor_id: context.state.vendorId,
                vendor_number: context.state.vendorNumber,
                vendor_name: context.state.vendorName,
                vendor_address: context.state.vendorAddress,
                vendor_city: context.state.vendorCity,
                vendor_contact: context.state.vendorContact,
            }

            return context.dispatch("postme", {
                url: "master/vendor/save",
                prm: prm,
                callback: function(d) {
                    return d
                }
            }, { root: true })
        }
    }
}