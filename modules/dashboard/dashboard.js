export default {
  namespaced: true,
  state: {
    projects: null,
    totalPos: 0,
    totalPosPage: 1,
    curPage: 1,

    totaltimeline: 0,

    totalproject: [],

    timelines: [],

    search: "",
    posId: 0,
    edit: false,
    dialog: false,

    timeline: [],
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
      try {
        let prm = {
          search: context.state.search,
          page: context.state.curPage,
        };
        let TimelineResult = await context.dispatch(
          "postme",
          {
            url: "master/timeline/search_dd",
            prm: prm,
            callback: function (d) {
              context.commit("SET_OBJECTS", [
                ["timelines", "totalPos", "totalPosPage"],
                [d.records, d.total, d.total_page],
              ]);
              return d;
            },
          },
          { root: true }
        );
        let ProjectsResult = await context.dispatch(
          "postme",
          {
            url: "project/project/count",
            prm: prm,
            callback: function (d) {
              context.commit("SET_OBJECTS", [
                ["projects", "timeline", "totaltimeline", "totalPosPage"],
                [d.records, d.timeline_counts, d.total_count, d.total_page],
              ]);
              return d;
            },
          },
          { root: true }
        );
        return [TimelineResult, ProjectsResult];
      } catch (error) {
        console.error("Error:", error);
        throw error;
      }
    },

    // async search(context) {
    //   let prm = {
    //     search: context.state.search,
    //     page: context.state.curPage,
    //   };

    //   return context.dispatch(
    //     "postme",
    //     {
    //       url: "project/project/search",
    //       prm: prm,
    //       callback: function (d) {
    //         context.commit("SET_OBJECTS", [
    //           ["projects", "totalPos", "totalPosPage"],
    //           [d.records, d.total, d.total_page],
    //         ]);
    //         return d;
    //       },
    //     },
    //     { root: true }
    //   );
    // },

    async searchDd(context) {
      let prm = {
        search: context.state.search,
      };

      return context.dispatch(
        "postme",
        {
          url: "master/position/search_dd",
          prm: prm,
          callback: function (d) {
            return d;
          },
        },
        { root: true }
      );
    },
  },
};
