export default {
    namespaced: true,
    state: {
        positions: [],
        totalPos: 0,
        totalPosPage: 1,
        curPage: 1,
        selectedPosition: null,
        search: "",

        cityName: '',
        cityCode: '',
        cityProvince: '',
        cityIsDefault: 'N',
        cityROID: '',
        posId: 0,
        edit: false,

        dialog: false
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
        }
    },
    actions: {
        async search(context) {
            let prm = {
                search: context.state.search,
                page: context.state.curPage
            }

            return context.dispatch("postme", {
                url: "master/city/search",
                prm: prm,
                callback: function(d) {
                    context.commit("SET_OBJECTS", [
                        ["positions", "totalPos", "totalPosPage"],
                        [d.records, d.total, d.total_page]
                    ])
                    return d
                }
            }, { root: true })
        },

        async searchDd(context) {
            let prm = {
                search: context.state.search
            }

            return context.dispatch("postme", {
                url: "master/city/search_dd",
                prm: prm,
                callback: function(d) {
                    return d
                }
            }, { root: true })
        },

        async save(context) {
            let prm = {
                position_name: context.state.positionName,
                position_note: context.state.positionNote,
                position_id: context.state.posId
            }

            return context.dispatch("postme", {
                url: "master/city/save",
                prm: prm,
                callback: function(d) {
                    return d
                }
            }, { root: true })
        }
    }
}