<template>
    <v-dialog
        ref="dialog"
        v-model="modal"
        :return-value.sync="date"
        persistent
        width="290px"
    >
        <template v-slot:activator="{ on, attrs }">
            <v-text-field
              :value="dateFormatted"
              :label="!!label?label:'Tanggal'"
              hint="DD-MM-YYYY format"
              persistent-hint
              :prepend-icon="hide_icon?null:'mdi-calendar'"
              v-bind="attrs"
              @blur="date = parseDate(dateFormatted)"
              v-on="on"
              :solo="solo"
              :hide-details="hide_details?hide_details:false"
            ></v-text-field>
        </template>
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
            modal: false
        }
    },

    computed: {
        computedDateFormatted () {
            return this.formatDate(this.date)
        },

        date : {
            get () { return this.$store.state.xdate.date02 },
            set (v) { this.$store.commit("xdate/SET_OBJECT", ["date02", v]) }
        },

        dateFormatted () {
            return this.formatDate(this.date)
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