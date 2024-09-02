<template>
    <div class="search-bar">
        <!-- <v-text-field
            solo
            hide-details
            placeholder="Pencarian"
            @change="changeQ($event)"
        > -->
        <v-text-field
            :label="'Search'"
            color="secondary"
            hide-details
            @change="changeQ($event)"
            @keyup.enter="search"
        >
            <template
                v-if="$vuetify.breakpoint.mdAndUp"
                v-slot:append-outer
            >
                <v-btn
                    class="mt-n2"
                    elevation="1"
                    fab
                    small @click="search"
                >
                    <v-icon>mdi-magnify</v-icon>
                </v-btn>
                <v-btn
                    class="mt-n2 ml-2"
                    elevation="1"
                    fab
                    small @click="add" color="primary"
                    v-show="!hideAdd"
                >
                    <v-icon>mdi-plus</v-icon>
                </v-btn>
            </template>
            <!-- <template v-slot:append-outer>
                <v-btn color="primary" class="ma-0 ml-1 btn-icon" depressed @click="search">
                    <v-icon>mdi-magnify</v-icon>
                </v-btn>      
                <v-btn color="success" class="ma-0 ml-1 btn-icon" @click="add" depressed>
                    <v-icon>mdi-plus</v-icon>
                </v-btn>  
            </template> -->
        </v-text-field>
    </div>
</template>

<script>
module.exports = {
    // props: ['q', 'hide-add'],
    props: {
        q: { type: String },
        hideAdd: { type: Boolean, required: false }
    },

    components : {
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
        }
    },

    mounted () {
    }
}
</script>
