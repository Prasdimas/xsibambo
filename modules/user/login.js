export default {
    namespaced: true,
    state : {
        userName: '',
        passWord: '',
        message: 'Tidak berhasil login',
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
      async login(context) {
          let prm = {
              username: context.state.userName,
              password: context.state.passWord
          }

          return context.dispatch("postme", {
              url: "systm/user/login",
              prm: prm,
              callback: function(d) {
                localStorage.setItem("siBamboToken", d.token)
                localStorage.setItem('siBamboUser', JSON.stringify(d.user))

                return d
              },

              failback: function(e) {
                context.commit("SET_OBJECT", ["message", e])
                context.commit("SET_OBJECT", ["err", true])
              }
          }, { root: true })
      }
  }
}