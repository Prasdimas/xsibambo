<template>
    <div class="search-bar">
        <v-row>
            <v-col cols="3"><sdate label="Tanggal Awal" solo :hide_details="true" :hide_icon="true" @change="changeSdate"></sdate></v-col>
            <v-col cols="3"><edate label="Tanggal Akhir" solo :hide_details="true" :hide_icon="true" @change="changeEdate"></edate></v-col>
            <v-col cols="6">
                <v-text-field
                    solo
                    hide-details
                    placeholder="Pencarian"
                    @change="changeQ($event)"
                >
                    <template v-slot:append-outer>
                        <v-btn color="primary" class="ma-0 ml-1 btn-icon" depressed @click="search">
                            <v-icon>mdi-magnify</v-icon>
                        </v-btn>      
                        <v-btn color="success" class="ma-0 ml-1 btn-icon" @click="add" depressed v-show="!hide_add">
                            <v-icon>mdi-plus</v-icon>
                        </v-btn>
                    </template>
                </v-text-field>
            </v-col>
        </v-row>
        
    </div>
</template>

<script>
module.exports = {
    props: ['q','hide_add'],
    components : {
        sdate: httpVueLoader('./date_dialog_01.vue'),
        edate: httpVueLoader('./date_dialog_02.vue'),
    },
    data: function() {
        return {
        }
    },

    computed : {
         
    },

    methods : {
        add () {
            this.$emit('add');
        },

        search () {
            this.$emit('search')
        },

        changeQ (x) {
            this.$emit('change', x)
        },

        changeSdate (x) {
            this.search()
        },

        changeEdate (x) {
            this.search()
        }
    },

    mounted () {
    }
}
</script>
