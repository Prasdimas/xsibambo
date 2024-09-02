export default {
  namespaced: true,
  state: {
    terms: [],
    totalPos: 0,
    totalPosPage: 1,
    curPage: 1,
    selectedTerm: null,
    search: "",

    TermName: "",
    TermCode: "",
    TermDuration: null,

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
    async search(context) {
      let prm = {
        search: context.state.search,
        page: context.state.curPage,
      };

      return context.dispatch(
        "postme",
        {
          url: "master/term/search",
          prm: prm,
          callback: function (d) {
            context.commit("SET_OBJECTS", [
              ["terms", "totalPos", "totalPosPage"],
              [d.records, d.total, d.total_page],
            ]);
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
          url: "master/term/search_dd",
          prm: prm,
          callback: function (d) {
            return d;
          },
        },
        { root: true }
      );
    },

    async save(context) {
      let prm = {
        term_name: context.state.TermName,
        term_code: context.state.TermCode,
        term_duration: context.state.TermDuration,
        term_id: context.state.posId,
      };

      return context.dispatch(
        "postme",
        {
          url: "master/term/save",
          prm: prm,
          callback: function (d) {
            return d;
          },
        },
        { root: true }
      );
    },
    async delete(context) {
      let id = context.state.selectedTerm.term_id;
      return context.dispatch(
        "postme",
        {
          url: "master/term/del",
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
