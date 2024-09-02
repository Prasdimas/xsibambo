export default {
    namespaced: true,
    state : {
        USER: JSON.parse(localStorage.getItem('siBamboUser')),
        userName: '',
        userId: 0,
        err: false
    },
    mutations : {
        SET_OBJECT(state, v) {
            let name = v[0]
            let val = v[1]
            state[name] = val
        },

        SET_OBJECTS(state, v) {
            let name = v[0]
            let val = v[1]
            for (let i=0; i<name.length; i++)
                state[name[i]] = val[i]
        }
    },
    actions : {
      async searchProfile(context) {
          let prm = {
              user_id: context.state.USER.user_id
          }

          return context.dispatch("postme", {
              url: "systm/user/get_profile",
              prm: prm,
              callback: function(d) {
                return d
              }
          }, { root: true })
      }
  }
}