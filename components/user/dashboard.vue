<template>
    <v-row>
        <v-col cols="12">
            <v-card>
                <v-card-title primary-title class="py-2">
                    <v-row>
                        <h5 class="font-weight-bold text-h5 text-typo mb-0">DASHBOARD</h5>
                    </v-row>                
                </v-card-title>
                <v-card-text class="py-2 px-3">
                    OK      
                </v-card-text>
            </v-card>
        </v-col>
    </v-row>
</template>

<script>
const t = "?t="+Math.random()
module.exports = {
    components : {
    },

    data: function() {
        return {
            title: 'Dashboard' 
        }
    },

    computed : {
        __s () { return this.$store.state.masterPosition },
        THEME () { return this.$store.state.app.THEME }
    },

    methods : {
        __c (a,b) { return this.$store.commit("masterPosition/SET_OBJECT", [a, b]) },
    },

    mounted () {
        
    }
}
</script>