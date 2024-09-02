// State
//  data ...
// Mutations
//
//
// Actions
import vendor from "./modules/vendor.js?t=ad21abc";
import vendor_new from "./modules/vendor_new.js?t=alkj2bs1dasc";
import vendor_filter from "./modules/vendor_filter.js?t=aa12sbc";
import address from "./modules/vendor_address.js?t=alkjbsda12sc";
import system from "../assets/js/system.js?t=2ds134";

export const store = new Vuex.Store({
    state : {
        dialog_delete: false,
        dialog_progress: false,
        dialog_print: false
    },

    mutations : {
        set_dialog_delete (state, v) {
            state.dialog_delete = v
        },

        set_dialog_progress (state, v) {
            state.dialog_progress = v
        },

        set_dialog_print (state, v) {
            state.dialog_print = v
        }
    },

    modules : {
        vendor: vendor,
        vendor_new: vendor_new,
        vendor_filter: vendor_filter,
        address: address,
        system: system
    }
});
