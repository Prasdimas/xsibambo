export default {
    namespaced: true,
    state: {
        timelines: [],
        totalPos: 0,
        totalPosPage: 1,
        curPage: 1,
        selectedTimeline: null,
        search: "",

        timelineName: '',
        timelineNote: '',
        timelineWeight: 0,

        employees: [],
        selectedEmployee: null,

        defaultTotalDuration: 100,
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
        },
    },

    actions: {
        async search(context) {
            let prm = {
                search: context.state.search,
                page: context.state.curPage,
                limit: 99
            }

            return context.dispatch("postme", {
                url: "master/timeline/search",
                prm: prm,
                callback: function(d) {
                    context.commit("SET_OBJECTS", [
                        ["timelines", "totalPos", "totalPosPage", "defaultTotalDuration"],
                        [d.records, d.total, d.total_page, d.duration_total_default]
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
                url: "master/timeline/search_dd",
                prm: prm,
                callback: function(d) {
                    return d
                }
            }, { root: true })
        },

        async save(context) {
            let __s = context.state, __st = __s.selectedTimeline
            let prm = {
                t_id: __st.timeline_id,
                t_name: __st.timeline_name,
                t_weight: __st.timeline_weight,
                t_dur: __st.timeline_duration,
                default_dur: __s.defaultTotalDuration,
                jdata: JSON.stringify(__st.assignee)
            }

            return context.dispatch("postme", {
                url: "master/timeline/save",
                prm: prm,
                callback: function(d) {
                    return d
                }
            }, { root: true })
        },
        async delete(context) {
            let id = context.state.selectedTimeline.timeline_id
            return context.dispatch("postme",{
                url: "master/timeline/del",
                prm: {id:id},
                callback: function(d) {
                    return d
                }
            }, { root: true })
        }
    }
}