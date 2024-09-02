<template>
    <v-dialog
        ref="dialog"
        v-model="modal"
        :return-value.sync="date"
        persistent
        width="290px"
        :retain-focus="false"
    >
        <v-date-picker
            v-model="date"
            scrollable
            @input="$refs.dialog.save(date), $emit('change', date)"
        >
        <v-spacer></v-spacer>
        <v-btn
            text
            color="primary"
            @click="modal = false"
        >
            Cancel
        </v-btn>
        <!-- <v-btn
            text
            color="primary"
            @click="$refs.dialog.save(date)"
        >
            OK
        </v-btn> -->
        </v-date-picker>
    </v-dialog>
</template>

<script>
module.exports = {
    props: ['label', 'hide_details', 'solo', 'hide_icon'],
    data () {
        return {
            
        }
    },

    computed: {
        computedDateFormatted () {
            return this.formatDate(this.date)
        },

        date : {
            get () { return this.$store.state.xdate.dateX },
            set (v) { this.$store.commit("xdate/SET_OBJECT", ["dateX", v]) }
        },

        dateFormatted () {
            return this.formatDate(this.date)
        },

        modal : {
            get () { return this.$store.state.xdate.dateXDialog },
            set (v) { this.$store.commit("xdate/SET_OBJECT", ["dateXDialog", v]) }
        }
    },

    watch: {
    },

    methods: {
        formatDate (date) {
            if (!date) return null

            const [year, month, day] = date.split('-')
            return `${day}-${month}-${year}`
        },
      
        parseDate (date) {
            if (!date) return null

            const [day, month, year] = date.split('-')
            return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`
        }
    }
}