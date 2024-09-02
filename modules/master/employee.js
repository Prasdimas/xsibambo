export default {
    namespaced: true,
    state: {
        edit: false,
        dialog: false,

        employeeCode: "",
        employeeName: "",
        employeeDOB: "",
        employeeAddress: "",
        employeeNote: "",
        employeeJoin: "",
        employeeId: 0,
        contactId: 0,

        selectedBank : null,
        banks:[],

        sales: [],
        image: "",
        filenames :[],
        sexes: [
            { id: "L", text: "Laki-laki" },
            { id: "P", text: "Perempuan" },
        ],

        employeeNik: "",
        employeeBPJSTK: "",
        employeeBPJS: "",
        selectedSex: null,
        employeeNoBank: "",
        employeePOB: "",
        employeeEducation: null,
        employeeEducationName: "",
        employeeEducationDepartment: "",
        employeeDepartemenHead: null,
        employeeDepartemenDetail: null,

        employeeSiblingPhone: "",
        employeeSiblingCorrelation: "",
        employeeSiblingName: "",
        employeeMother: "",
        employeeKk: "",
        employeeRT: "",
        employeeRW: "",

        userName: "",
        userPassword: "",
        userChange: "N",

        positions: [],
        selectedPosition: null,

        customers: [],
        selectedCustomer: null,

        divisions: [],
        selectedDivision: null,

        contacts: [],

        city: [],
        selectedCity: null,

        employees: [],
        selectedEmployee: null,

        edit: false,
        dialogDelete: false,

        total: 0,
        totalPage: 1,
        curPage: 1,
        search: "",
        searchDivision: null,
    },
    mutations: {
        SET_OBJECT(state, v) {
            let name = v[0];
            let val = v[1];
            state[name] = val;
        },
        SET_OBJECTS(state, v) {
            let name = v[0];
            let val = v[1];
            for (let i = 0; i < name.length; i++) state[name[i]] = val[i];
        },
    },
    actions: {
        async search(context) {
            let prm = {
                search: context.state.search,
                page: context.state.curPage,
            };
            if (!!context.state.searchDivision)
                prm.division = context.state.searchDivision;

            return context.dispatch(
                "postme",
                {
                    url: "master/employee/search",
                    prm: prm,
                    callback: function (d) {
                        context.commit("SET_OBJECTS", [
                            ["employees", "total", "totalPage"],
                            [d.records, d.total, d.total_page],
                        ]);
                        return d;
                    },
                },
                { root: true }
            );
        },

        async searchMisc(context) {
            try {
                let prm = {
                    search: context.state.search,
                    page: context.state.curPage,
                    province_id: 0,
                };
                let PositionResult = await context.dispatch(
                    "postme",
                    {
                        url: "master/position/search_dd",
                        prm: prm,
                        callback: function (d) {
                            context.commit("SET_OBJECTS", [
                                ["positions"],
                                [d.records],
                            ]);
                            return d;
                        },
                    },
                    { root: true }
                );

                let EmployeeResult = null;
                let DivisionResult = await context.dispatch(
                    "postme",
                    {
                        url: "master/Division/search_dd",
                        prm: prm,
                        callback: function (d) {
                            context.commit("SET_OBJECTS", [
                                ["divisions"],
                                [d.records],
                            ]);
                            return d;
                        },
                    },
                    { root: true }
                );
                let CityResult = await context.dispatch(
                    "postme",
                    {
                        url: "master/city/search_dd",
                        prm: prm,
                        callback: function (d) {
                            context.commit("SET_OBJECTS", [
                                ["city"],
                                [d.records],
                            ]);
                            return d;
                        },
                    },
                    { root: true }
                );
                let ContactResult = await context.dispatch(
                    "postme",
                    {
                        url: "master/ContactDetail/search_dd",
                        prm: prm,
                        callback: function (d) {
                            context.commit("SET_OBJECTS", [
                                ["contacts"],
                                [d.records],
                            ]);
                            return d;
                        },
                    },
                    { root: true }
                );
                return [
                    DivisionResult,
                    EmployeeResult,
                    PositionResult,
                    ContactResult,
                    CityResult,
                ];
            } catch (error) {
                console.error("Error:", error);
                throw error;
            }
        },

        async save({ state, commit, dispatch, rootState }) {
            let prm = {
                employee_id: state.posId,
                employee_name: state.employeeName,
                employee_address: state.employeeAddress,
                employee_dob: rootState.xdate.date02,
                employee_join: rootState.xdate.date01,
                employee_city: state.selectedCity ? state.selectedCity.city_id : 0,
                employee_pos: state.selectedPosition.position_id,
                employee_pob: state.employeePOB ? state.employeePOB.city_id : 0,
                employee_division: state.selectedDivision.division_id,
                employee_note: state.employeeNote,
                employee_contacts: rootState.misc.contacts,

                employee_sex: state.selectedSex,
                employee_code: state.employeeCode,
                employee_nik: state.employeeNik,
                employee_kk: state.employeeKk,
                employee_bpjs: state.employeeBPJS,
                employee_bpjstk: state.employeeBPJSTK,
                employee_mother: state.employeeMother,
                employee_sibling_name: state.employeeSiblingName,
                employee_sibling_phone: state.employeeSiblingPhone,
                employee_sibling_correlation: state.employeeSiblingCorrelation,
                employee_education: state.employeeEducation ? state.employeeEducation : 0,
                employee_education_name: state.employeeEducationName,
                employee_education_department:
                    state.employeeEducationDepartment,
                employee_image: state.image,

                employee_bank : state.selectedBank,
                employee_nobank : state.employeeNoBank,

                user_name: state.userName,
                user_password: state.userPassword,
                user_change: state.userChange,
            };

            return dispatch(
                "postme",
                {
                    url: "master/employee/save",
                    prm: prm,
                    callback: function (d) {
                        return d;
                    },
                },
                { root: true }
            );
        },

        // async data(context) {
        //   // Mengakses root state dengan menggunakan this.$store.state
        //   const myRootState = context.rootState.xdate;
        //   console.log("daro data xdate : ", myRootState);
        // },

        async delete(context) {
            let id = context.state.selectedEmployee.employee_id;
            return context.dispatch(
                "postme",
                {
                    url: "master/employee/del",
                    prm: { id: id },
                    callback: function (d) {
                        return d;
                    },
                },
                { root: true }
            );
        },

        async searchDd(context) {
            let prm = {
                search: context.state.search,
            };

            return context.dispatch(
                "postme",
                {
                    url: "master/employee/search_dd",
                    prm: prm,
                    callback: function (d) {
                        context.commit("SET_OBJECTS", [
                            ["sales", "totalEmployee", "totalEmployeePage"],
                            [d.records, d.total, d.total_page],
                        ]);
                        return d;
                    },
                },
                { root: true }
            );
        },
        async upload(context) {
            let prm = {
                search: context.state.search,
            };

            let formData = new FormData();
            formData.append("userfile", context.state.image);

            return context.dispatch(
                "postme",
                {
                    url: "master/employee/upload_file",
                    prm: prm,
                    body: context.state.image,
                    callback: function (d) {
                        return d;
                    },
                },
                { root: true }
            );
        },

        files(context) {
            let prm = {
                search: context.state.search,
            };
            return context.dispatch(
                "postme",
                {
                    url: "master/employee/search_files",
                    prm: prm,
                    callback: function (d) {
                        context.commit("SET_OBJECT", ["filenames", d.files]);
                        return d;
                    },
                },
                { root: true }
            );
        },
        searchbank(context) {
            let prm = {
                search: context.state.search,
            };
            return context.dispatch(
                "postme",
                {
                    url: "master/bank/search_dd",
                    prm: prm,
                    callback: function (d) {
                        context.commit("SET_OBJECT", ["banks", d.records]);
                        return d;
                    },
                },
                { root: true }
            );
        },
        uploadFile(context, formData) {
            return context.dispatch(
                "postme",
                {
                    url: "master/employee/upload_file",
                    prm: formData,
                    callback: function (d) {
                        return d;
                    },
                },
                { root: true }
            );
        },
    },
};
