import { app } from "../../app.js?t=ewr"

export default {
    namespaced: true,
    state : {
        profiles: [],
        total: 0,
        totalPage: 1,
        curPage: 1,
        customerId: 0,
        selectedProfile: null,

        profileTitles: [],
        profileDefault: {id:0, label:null, desc:'', editable:true},

        snackbar: false,
        snackbar_text: '',

        search: '',
        edit: false,
        dialog: false,
        dialogDelete: false,

        profileDivisions: [],
        currentUser: null
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
                customer_id: context.state.customerId,
                search: context.state.search,
                page: context.state.curPage
            }

            return context.dispatch("postme", {
                url: "master/customerprofile/search",
                prm: prm,
                callback: function(d) {
                    let profiles = [], n = 0
                    for (let p of d.records) 
                        profiles.push({id:p.profile_id,label:p.title_id,label_title:p.title_label,
                            desc:p.profile_desc,idx:n,division_id:p.division_id,
                            editable:(p.division_id==context.state.currentUser.division_id?true:false)}), n++
                    context.commit("SET_OBJECT", ["profiles", profiles])
                    return d
                }
            }, { root: true })
        },

        async searchTitle(context) {
            let prm = {
                search: context.state.search,
                page: context.state.curPage
            }

            return context.dispatch("postme", {
                url: "master/customerprofiletitle/search_dd",
                prm: prm,
                callback: function(d) {
                    context.commit("SET_OBJECT", ["profileTitles", d.records])
                    return d
                }
            }, { root: true })
        }
    }
}