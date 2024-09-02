export default {
    namespaced: true,
    state : {
        search: "",
        curPage: 1,

        items: [],
        selectedItem: null,
        total: 0,
        totalPage: 1
    },

    mutations : {
        set_items (state, value) {
            state.items = value
        },

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

    actions : {
        async search (context) {
            let prm = {
                search: context.state.search,
                page: context.state.curPage
            }

            context.dispatch("postme", {
                url: "item/items/search",
                prm: prm,
                callback: function(d) {

                }
            }, {root:true})
        }
    }
}