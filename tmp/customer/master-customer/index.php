<!DOCTYPE html>
<html lang="en">

   <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="X-UA-Compatible" content="ie=edge">
      <title>One</title>
      <link rel="stylesheet" href="../../assets/css/google-fonts.css">
      <link rel="stylesheet" href="../../assets/css/vuetify.min.css">
      <link rel="stylesheet" href="../assets/css/global.min.css">
      <link rel="icon" type="image/x-icon" href="../assets/favicon/favicon.ico">
      <!-- <script src="../../../libs/one_global_clinic.js"></script> -->
   </head>

   <body>
      <div v-cloak id="app">
         <v-app id="oneApp"  v-if="one_token">
            <common-toolbar></common-toolbar>
            <v-content class="blue lighten-5 one" >
            <common-navbar></common-navbar>
               <v-container pt-1 pl-1 pr-1 fluid>
                  <v-layout row>
                     <v-flex xs12>
                        <master-customer-list-mobile v-show="$vuetify.breakpoint.smAndDown"></master-customer-list-mobile>
                        <master-customer-list v-show="$vuetify.breakpoint.mdAndUp"></master-customer-list>
                     </v-flex>
                  </v-layout>
               </v-container>
            </v-content>
            
            <v-footer class="mb-5 footer" app color="transparent">
                <v-spacer></v-spacer>
                
            </v-footer>
            
            <master-customer-new></master-customer-new>
            <master-customer-filter></master-customer-filter>
            <common-dialog-progress></common-dialog-progress>
            <common-dialog-print :report_url="report_url" v-if="dialog_print"></common-dialog-print>
         </v-app>
      </div>

      <!-- Vendor -->
      <script src="../../assets/js/moment.min.js"></script>
      <script src="../../assets/js/numeral.min.js"></script>
      <script src="../../assets/js/moment-locale-id.js"></script>
      <script src="../../assets/js/lodash.custom.min.js"></script>
      <script src="../../assets/js/axios.min.js"></script>
      <script src="../../assets/js/vue.min.js"></script>
      <script src="../../assets/js/vuex.min.js"></script>
      <script src="../../assets/js/vuetify.min.js"></script>
      <script src="../../assets/js/httpVueLoader.min.js"></script>
      <script src="../assets/js/window_functions.min.js?t=<?=date('YmdHis');?>"></script>
      
      <!-- App Script -->
<?php
$ts = "?ts=" . Date("ymdhis");
?>

<style scoped>
.footer {
    width: 100px;
    right: 0px;
    left: auto;
}

.v-content__wrap {
    /* padding-left: 80px; */
    padding-left: 0px
}
</style>

<script type="module">

import { store } from './store.js<?php echo $ts ?>';
//for testing
window.store = store;
new Vue({
store,
data : {
   
},
mounted: function() {
    if (!this.$store.state.system.one_token)
        window.location.replace('../system-login/')

    this.$store.dispatch('customer/search', {})
    this.$store.dispatch('system/search_menu_group')
},
computed : {
    one_token () {
        return this.$store.state.system.one_token
    },

    dialog_print () {
        return this.$store.state.dialog_print
    },

    report_url () {
        return this.$store.state.customer.report_url
    }
},

methods : {
    
},
   el: '#app',
   components: {
        "common-navbar" : httpVueLoader("../common/components/common-navbar.vue?t=123"),
        "common-toolbar" : httpVueLoader("../common/components/common-toolbar.vue"),
        "common-dialog-progress" : httpVueLoader("../common/components/common-dialog-progress.vue"),
        "common-dialog-print" : httpVueLoader("../common/components/common-dialog-print.vue"),
        "master-customer-list" : httpVueLoader("./components/master-customer-list.vue?t=<?=date('YmdHis');?>"),
        "master-customer-list-mobile" : httpVueLoader("./components/master-customer-list-mobile.vue?t=<?=date('YmdHis');?>"),
        "master-customer-new" : httpVueLoader("./components/master-customer-new.vue?t=<?=date('YmdHis');?>"),
        "master-customer-filter" : httpVueLoader("./components/master-customer-filter.vue?t=<?=date('YmdHis');?>")
      }
    })
    </script>
    <style>
[v-cloak] {
   display: none
}
    .v-content.one {
       /* padding:64px 0px 0px !important; */
    }
    </style>
   </body>

</html>
