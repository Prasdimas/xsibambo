export default {
    namespaced: true,
    state : {
        search: "",
        curPage: 1,

        statuses: [],
        selectedStatus: null,
        total: 0,
        totalPage: 1
    },

    mutations : {
        set_statuses (state, value) {
            state.statuses = value
        },

        set_total (state, value) {
            state.total = value
        },

        set_curpage (state, value) {
            state.curPage = value
        },

        SET_OBJECT (state, v) {
            let name = v[0]
            let val = v[1]
            state[name] = val
        }
    },

    actions : {
        async search (context) {
            let prm = {
                search: context.state.search,
                page: context.state.curPage
            }

            context.dispatch("postme", {
                url: "sales/sales/search",
                prm: prm,
                callback: function(d) {

                }
            }, {root:true})
        }
    }
}