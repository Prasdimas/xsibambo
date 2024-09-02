export default {
    namespaced: true,
    state: {
        holidays: [],
        totalHoliday: 0,
        totalHolidayPage: 1,
        curPage: 1,
        selectedHoliday: null,
        search: "",

        holidayDate: (new Date(Date.now() - (new Date()).getTimezoneOffset() * 60000)).toISOString().substr(0, 10),
        holidayName: '',
        holidayNote: '',
        holidayId: 0,
        holidayQuota: 0,
        edit: false,

        types: [],
        typesCnt: [],
        selectedType: null,

        dialog: false,
        curYear: (new Date(Date.now() - (new Date()).getTimezoneOffset() * 60000)).toISOString().substr(0, 4)
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
                page: context.state.curPage,
                year: context.state.curYear
            }

            return context.dispatch("postme", {
                url: "master/holiday/search",
                prm: prm,
                callback: function(d) {
                    context.commit("SET_OBJECTS", [
                        ["holidays", "totalHoliday", "totalHolidayPage", "holidayQuota", "typesCnt"],
                        [d.records, d.total, d.total_page, d.holiday_quota.misc_value, d.types]
                    ])
                    return d
                }
            }, { root: true })
        },

        async save(context) {
            let __s = context.state
            let prm = {
                holiday_name: __s.holidayName,
                holiday_date: __s.holidayDate,
                holiday_type: __s.selectedType,
                holiday_id: 0
            }

            if (!!__s.edit) prm.holiday_id = __s.holidayId

            return context.dispatch("postme", {
                url: "master/holiday/save",
                prm: prm,
                callback: function(d) {
                    return d
                }
            }, { root: true })
        },

        async saveQuota(context) {
            let prm = {
                misc_code: 'HOLIDAY.QUOTA',
                misc_key: context.state.curYear,
                misc_value: context.state.holidayQuota
            }

            return context.dispatch("postme", {
                url: "master/misc/save_by_key",
                prm: prm,
                callback: function(d) {
                    return d
                }
            }, { root: true })
        },

        async searchType(context) {
            let prm = {
                misc_code: 'HOLIDAY.TYPE'
            }

            return context.dispatch("postme", {
                url: "master/misc/search_dd",
                prm: prm,
                callback: function(d) {
                    context.commit("SET_OBJECTS", [
                        ["types"],
                        [d]
                    ])
                    return d
                }
            }, { root: true })
        },

        async del(context) {
            let prm = {
                id: context.state.selectedHoliday.holiday_id
            }

            return context.dispatch("postme", {
                url: "master/holiday/del",
                prm: prm,
                callback: function(d) {
                    context.dispatch("search")
                    return d
                }
            }, { root: true })
        }
    }
}