<template>
    <v-dialog
        ref="dialog"
        v-model="modal"
        :return-value.sync="date"
        persistent
        width="290px"
    >
        <template v-slot:activator="{ on, attrs }">
            <!-- <v-text-field
                v-model="dateRangeText"
                label="Date range"
                prepend-icon="mdi-calendar"
                readonly
            ></v-text-field> -->
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
            scrollable range
            
        >
        <v-spacer></v-spacer>
        <v-btn
            text
            color="primary"
            @click="modal = false"
        >
            Cancel
        </v-btn>
        <v-btn
            text
            color="primary"
            @click="$refs.dialog.save(date)"
        >
            OK
        </v-btn>
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
            get () { return this.$store.state.xdate.dateRange },
            set (v) { this.$store.commit("xdate/SET_OBJECT", ["dateRange", v]) }
        },

        dateFormatted () {
            return this.formatDate(this.date).join("  s/d  ")
        } 
    },

    watch: {
    },

    methods: {
        formatDate (date) {
            if (!date) return null

            const [year1, month1, day1] = date[0].split('-')
            let dates = [`${day1}-${month1}-${year1}`]

            if (date[1]) {
                const [year2, month2, day2] = date[1].split('-')
                dates.push(`${day2}-${month2}-${year2}`)
            }
            

            // return `${day1}-${month1}-${year1}`
            return dates
        },
      
        parseDate (date) {
            if (!date) return null
            console.log(date)
            const [day1, month1, year1] = date[0].split('-')
            let dates = [`${year1}-${month1.padStart(2, '0')}-${day1.padStart(2, '0')}`]
        
            if (date[1]) {
                const [day2, month2, year2] = date[1].split('-')
                dates.push(`${year2}-${month2.padStart(2, '0')}-${day2.padStart(2, '0')}`)
            }
            return dates
        }
    }
}