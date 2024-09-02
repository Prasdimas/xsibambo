<template>
    
    <v-dialog
        v-model="dialog"
        max-width="300px"
        transition="dialog-transition"
    >
        <v-card>
            <v-card-title primary-title class="py-2 px-3">
                <h3>TAMBAH AKUN MARKETPLACE</h3>
            </v-card-title>
            <v-card-text>
                <v-select
                    :items="mps"
                    v-model="selected_mp"
                    label="Marketplace"
                    item-text="M_MpName"
                    item-value="M_MpID"
                    return-object
                >
                    <template slot="item" slot-scope="data">
                        <v-img :src="'../assets/img/'+data.item.M_MpLogoUrl" width="20" height="20" max-width="20" contain class="mr-2"></v-img>
                        {{data.item.M_MpName}}
                    </template>

                    <template slot="selection" slot-scope="data">
                        <v-img :src="'../assets/img/'+data.item.M_MpLogoUrl" width="20" height="20" max-width="20" contain class="mr-2"></v-img>
                        {{data.item.M_MpName}}
                    </template>
                </v-select>

                <v-text-field
                    label="Nama Akun"
                    v-model="mp_account_name"
                ></v-text-field>

                <v-textarea
                    label="URL Akun"
                    v-model="mp_account_url"
                    rows="2">
                </v-textarea>
            </v-card-text>

            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="red" flat @click="dialog=!dialog">Tutup</v-btn>
                <v-btn color="primary" @click="save">Simpan</v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script>
module.exports = {
    computed : {
        dialog : {
            get () { return this.$store.state.customer_new.dialog_mp },
            set (v) { this.$store.commit('customer_new/set_common', ['dialog_mp', v]) }
        },

        mps () {
            return this.$store.state.customer_new.mps
        },

        selected_mp : {
            get () { return this.$store.state.customer_new.selected_mp },
            set (v) { this.$store.commit('customer_new/set_selected_mp', v) }
        },

        mp_account_name : {
            get () { return this.$store.state.customer_new.mp_account_name },
            set (v) { this.$store.commit('customer_new/set_common', ['mp_account_name', v]) }
        },

        mp_account_url : {
            get () { return this.$store.state.customer_new.mp_account_url },
            set (v) { this.$store.commit('customer_new/set_common', ['mp_account_url', v]) }
        }
    },

    methods : {
        save () {
            let x = this.$store.state.customer_new.customer_mps
            x.push({
                mp_id: this.selected_mp.M_MpID, 
                mp_name: this.selected_mp.M_MpName, 
                mp_account_name: this.mp_account_name,
                mp_account_url: this.mp_account_url,
                mp_logo: this.selected_mp.M_MpLogoUrl})

            this.$store.commit('customer_new/set_customer_mps', x)
            this.dialog = false
        }
    }
}
</script>