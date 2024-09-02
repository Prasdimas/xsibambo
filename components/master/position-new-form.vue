<template>
  <v-row justify="center" dense>
    <v-col cols="12">
      <v-card class="rounded-3">
        <v-card-title class="py-2">
          {{ !edit ? "INPUT" : "UBAH" }} DATA POSISI / JABATAN
          <v-spacer></v-spacer>
          <v-btn icon :dark="dark" @click="dialog = false" class="mr-3">
            <v-icon>mdi-arrow-left</v-icon>
          </v-btn>
          <v-btn :dark="dark" class="primary rounded-3" @click="save">
            Simpan
          </v-btn>
        </v-card-title>
        <v-card-text class="py-2 px-3">
          <v-row>
            <v-col cols="12" md="6" lg="4" class="pa-5">
              <v-text-field
                label="Nama Posisi"
                v-model="positionName"
                placeholder="Nama"
              ></v-text-field>

              <v-textarea
                label="Catatan"
                v-model="positionNote"
                outlined
              ></v-textarea>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
module.exports = {
  components: {},

  data: function () {
    return {
      notifications: false,
      sound: true,
      widgets: false,
      dark: false,
    };
  },

  computed: {
    __s() {
      return this.$store.state.masterPosition;
    },

    edit() {
      return this.__s.edit;
    },

    dialog: {
      get() {
        return this.__s.dialog;
      },
      set(v) {
        this.__c("dialog", v);
      },
    },

    positionName: {
      get() {
        return this.__s.positionName;
      },
      set(v) {
        this.__c("positionName", v);
      },
    },

    positionNote: {
      get() {
        return this.__s.positionNote;
      },
      set(v) {
        this.__c("positionNote", v);
      },
    },
  },

  methods: {
    __c(a, b) {
      return this.$store.commit("masterPosition/SET_OBJECT", [a, b]);
    },
    __d(a) {
      return this.$store.dispatch("masterPosition/" + a);
    },

    save() {
      this.__d("save").then((x) => {
        this.__c("dialog", false);
        this.__d("search");

        try {
          // Emit custom event with data
          this.$emit("callback", x);
        } catch (error) {
          console.error("Error:", error.message);
          // Optionally, emit an error event or handle the error in some other way
        }
      });
    },
  },

  mounted() {
    console.log(this.$store.state);
  },
};
</script>
