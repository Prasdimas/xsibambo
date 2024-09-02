export default {
    namespaced: true,
    state: {
        groupId: null,
        reportPrivilege: [],
        groups: [],
        menus: [],
        selectedMenus: [],
        totalPos: 0,
        totalPosPage: 1,
        curPage: 1,
        search: "",
        posId: 0,
        edit: false,
        dialog: false,
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
        async save(context) {
            let prm = {
                group_id: context.state.groupId,
                privileges: context.state.selectedMenus,
                report_privileges: context.state.reportPrivilege,
            };

            return context.dispatch(
                "postme",
                {
                    url: "systm/usergroup/save",
                    prm: prm,
                    callback: function (d) {
                        return d;
                    },
                },
                { root: true }
            );
        },

        async search(context) {
            let prm = {
                search: context.state.search,
                page: context.state.curPage,
            };

            return context.dispatch(
                "postme",
                {
                    url: "systm/usergroup/search",
                    prm: prm,
                    callback: function (d) {
                        context.commit("SET_OBJECTS", [
                            ["groups", "totalPos"],
                            [d.records, d.total],
                        ]);
                        return d;
                    },
                },
                { root: true }
            );
        },
        async searchall(context) {
            let prm = {
                search: context.state.search,
                page: context.state.curPage,
            };

            return context.dispatch(
                "postme",
                {
                    url: "systm/menu/search_all",
                    prm: prm,
                    callback: function (d) {
                        context.commit("SET_OBJECTS", [
                            ["menus", "totalPos"],
                            [d, d.total],
                        ]);
                        return d;
                    },
                },
                { root: true }
            );
        },
    },
};
