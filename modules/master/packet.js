export default {
    namespaced: true,
    state: {
        packets: [],
        totalPos: 0,
        totalPosPage: 1,
        curPage: 1,
        // selectedPosition: null,
        search: "",
        packet_id: null,

        posId: 0,
        edit: false,
        dialog: false,

        timelines: [],
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
        ADD_ITEM(state, newItem) {
            state.packets.unshift(newItem);
          },
      
        REMOVE_ITEM(state, index) {
            state.packets.splice(index, 1);
        },
        ADD_TIMELINE(state, payload) {
            const { index, item } = payload;
            const timeline = state.packets[index].timeline;
        
            const itemIndex = timeline.indexOf(item);
        
            if (itemIndex > -1) {
                timeline.splice(itemIndex, 1);
            } else {
                timeline.push(item);
            }
        }
        
      
    },
    actions: {
        async search(context) {
            let prm = {
                search: context.state.search,
                page: context.state.curPage,
            };

            return context.dispatch(
                "postme",
                {
                    url: "master/packet/search",
                    prm: prm,
                    callback: function (d) {
                        context.commit("SET_OBJECTS", [
                            ["packets", "totalPos", "totalPosPage"],
                            [d.records, d.total, d.total_page],
                        ]);
                        return d;
                    },
                },
                { root: true }
            );
        },


        async save(context) {
            let prm = {
                packets: context.state.packets
            };

            return context.dispatch(
                "postme",
                {
                    url: "master/packet/save",
                    prm: prm,
                    callback: function (d) {
                        return d;
                    },
                },
                { root: true }
            );
        },
        async delete(context) {
            let id = context.state.packet_id;
            return context.dispatch(
                "postme",
                {
                    url: "master/packet/del",
                    prm: { id: id },
                    callback: function (d) {
                        return d;
                    },
                },
                { root: true }
            );
        },
    },
};
