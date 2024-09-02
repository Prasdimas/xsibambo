<template>
    <v-dialog
        v-model="dialog"
        max-width="1000px"
        :height="height"
        transition="dialog-transition"
        content-class="zalfa-dialog-print"
    >
        <v-card class="fill-height" :height="height" style="display:flex;flex-direction:column">
            <v-card-title class="cyan white--text pb-2 pt-2" style="flex:0">
                <h3 class="ml-2" :title="init_report_url">
                    Laporan
                </h3>
                <v-spacer></v-spacer>
                <v-btn color="red" dark @click="dialog=!dialog" class="ma-0" small style="min-width:0px">
                    <v-icon>clear</v-icon>
                </v-btn>
            </v-card-title>

            <v-card-text class="grow pa-1" grow style="flex:1">
                <!-- <object  style="overflow: hidden;" width="100%" :height="xheight" :data="xurl"></object> -->
                <object :data="init_report_url" type="application/pdf" width="100%" height="100%" v-if="$vuetify.breakpoint.lgAndUp"></object>
                <iframe :src="'https://docs.google.com/gview?embedded=true&url='+encodeURIComponent(init_report_url)" frameborder="0" v-if="$vuetify.breakpoint.mdAndDown" width="100%" height="100%"></iframe>
                <!-- <object :data="'report-content.php?url=https://www.africau.edu/images/default/sample.pdf'" width="100%" height="100%" v-if="$vuetify.breakpoint.lgAndUp"></object> -->
            </v-card-text>

            <!-- <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="red" dark @click="dialog=!dialog">Tutup</v-btn>
            </v-card-actions> -->
        </v-card>
    </v-dialog>
</template>

<style>
.zalfa-dialog-print {
    margin: 12px !important;
    max-height: 95% !important;
}
</style>

<script>
module.exports = {
    props : ['data', 'report_url'],
    data () {
        return {
            init_report_url: this.report_url ? this.report_url : ''
        }
    },

    computed : {
        dialog : {
            get () { return this.$store.state.misc.dialogPrint },
            set (v) { this.$store.commit('misc/SET_OBJECT', ['dialogPrint', v]) }
        },

        height () {
            return window.innerHeight * 0.95
        }
    },

    methods : {
    },

    mounted () {
        // let url = this.init_report_url
        // if (url.indexOf('excel')>-1) {
        //     let e = url.split('?')
        //     let p = e[1].split('&')
        //     let prm = {url:e[0]}
        //     for (let px of p) {
        //         let x = px.split('=')
        //         prm[x[0]] = x[1]
        //     }
    
        //     this.$store.dispatch("system/report_excel", prm)
        // }
    }
}
</script>