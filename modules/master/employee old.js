export default {
    namespaced: true,
    state: {
        employees: [],
        totalEmployee: 0,
        totalEmployeePage: 1,
        curPage: 1,
        selectedEmployee: null,
        search: "",

        employeeName: '',
        employeeDOB: '',
        employeeAddress: '',
        employeeNote: '',
        employeeJoin: '',
        employeeId: 0,
        contactId: 0,

        userName: '',
        userPassword: '',
        userChange: 'N',

        employeePicture: null,

        edit: false,
        me: false,

        positions: [],
        selectedPosition: null,

        divisions: [],
        selectedDivision: null,

        scores: [],

        selectedCity: null,

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
                url: "master/employee/search",
                prm: prm,
                callback: function(d) {
                    context.commit("SET_OBJECTS", [
                        ["employees", "totalEmployee", "totalEmployeePage"],
                        [d.records, d.total, d.total_page]
                    ])
                    return d
                }
            }, { root: true })
        },

        async searchDd(context) {
            let prm = {
                search: context.state.search,
            }

            return context.dispatch("postme", {
                url: "master/employee/search_dd",
                prm: prm,
                callback: function(d) {
                    // context.commit("SET_OBJECTS", [
                    //     ["employees", "totalEmployee", "totalEmployeePage"],
                    //     [d.records, d.total, d.total_page]
                    // ])
                    return d
                }
            }, { root: true })
        },

        async searchMe(context) {
            let prm = {}

            return context.dispatch("postme", {
                url: "master/employee/search_me",
                prm: prm,
                callback: function(d) {
                    // context.commit("SET_OBJECTS", [
                    //     ["employees", "totalEmployee", "totalEmployeePage"],
                    //     [d.records, d.total, d.total_page]
                    // ])
                    return d
                }
            }, { root: true })
        },

        async save(context) {
            let __s = context.state, __r = context.rootState, contacts = []
            let prm = {
                employee_name: __s.employeeName,
                employee_dob: __r.xdate.date02,
                employee_address: __s.employeeAddress,
                employee_city: __s.selectedCity.city_id,
                employee_pos: __s.selectedPosition.position_id,
                employee_division: __s.selectedDivision.division_id,
                employee_join: __r.xdate.date01,
                employee_note: __s.employeeNote,
                user_name: __s.userName,
                user_change: __s.userChange,
                user_password: __s.userPassword
            }
            
            for (let c of __r.misc.contacts) if (c.desc != "") contacts.push(c)
            prm.employee_contacts = contacts

            if (!!context.state.edit)
                prm.employee_id = context.state.employeeId

            return context.dispatch("postme", {
                url: "master/employee/save",
                prm: prm,
                callback: function(d) {
                    return d
                }
            }, { root: true })
        },

        async del(context) {
            let prm = {
                id: context.state.selectedEmployee.employee_id
            }

            return context.dispatch("postme", {
                url: "master/employee/del",
                prm: prm,
                callback: function(d) {
                    context.dispatch("search")
                    return d
                }
            }, { root: true })
        }
    }
}