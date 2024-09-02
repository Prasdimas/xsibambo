<template>
    <v-row justify="center">
      <v-dialog
        v-model="dialog"
        persistent
        max-width="350"
      >
        <v-card>
          <v-card-title class="text-h5 primary white--text">
            Konfirmasi Hapus Data
          </v-card-title>
          <v-card-text class="py-3">Halo! 🌟 Sepertinya kamu akan menghapus sesuatu. 💫 <b>Jika kamu yakin</b>, silakan tekan tombol hapus</v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn
              color="green darken-1"
              text
              @click="dialog = false"
            >
              Batal
            </v-btn>
            <v-btn
              color="primary darken-1"
              dark
              @click="doDel"
            >
              Ya, Hapus
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-row>
  </template>

<script>
module.exports = {
    data () {
      return {
      }
    },
    computed : {
      dialog : {
        get () { return this.$store.state.misc.dialogDelete },
        set (v) { this.$store.commit('misc/SET_OBJECT', ['dialogDelete', v]) }
      }
    },

    methods : {
      doDel () {
        this.$emit('todo')
      }
    }
}
</script>