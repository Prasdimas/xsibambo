// import userModule from './_modules/test.js';
import { ajaxPost, URL, app, APP_NAME } from "../../../app.js?t=ewr";
import masterGroup from "../../../modules/user/group.js?t=12re3s";
import misc from "../../../modules/misc/misc.js?t=12re3";
import project from "../../../modules/project/project.js?t=asd";

Vue.use(Vuex);
Vue.use(Vuetify);
Vue.use(VueRouter);
Vue.config.productionTip = false;

// const vuetify = new Vuetify({
//     theme: customTheme,
//   });
// const userModule = () => import('./_modules/test.js')
// const masterDashboard = () => import(URL + './_modules/master/pos.js')

export const store = new Vuex.Store({
    dark: true,
    state: {
        APP_NAME: APP_NAME,
        search_status: 0,
        search_error_message: "",
    },

    mutations: {
        set_object(state, v) {
            let name = v[0];
            let val = v[1];
            state[name] = val;
        },
    },

    actions: {
        async postme(context, d) {
            return context.dispatch("app/postme", d);
        },
    },

    modules: {
        masterGroup: masterGroup,
        misc: misc,
        app: app,
        project: project,
    },
});
