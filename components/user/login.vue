<template>
  <!-- eslint-disable vue/no-v-html -->
  <!-- <div class="auth-wrapper d-flex align-center justify-center pa-4"> -->
    <v-row><v-col>
    <v-card
      class="auth-card pa-4 pt-7 mx-auto"
      max-width="448" flat style="background-color: transparent !important;"
    >
      <!-- <v-card-title class="justify-center"> -->
        <!-- <template #prepend>
          <div class="d-flex"> -->
            <!-- <div v-html="logo" /> -->
          <!-- </div>
        </template> -->

        <v-card-title class="font-weight-semibold text-2xl text-uppercase primary--text text-h3 justify-center d-flex">
          <img :src="logo" style="height:70px" class="ml-2 d-md-none"/>
          <div class="d-none d-md-block text-left" style="width:100%;font-family:Roboto !important">Sibambo STUDIO</div>
        </v-card-title>
      <!-- </v-card-title> -->

      <v-card-text class="pt-2" :class="[$vuetify.breakpoint.smAndDown?'text-center':'text-left']">
        <h5 class="text-h5 font-weight-semibold mb-1">
          Welcome to SiBambo Studio 👋🏻 
        </h5>
        <v-alert
      close-text="Close Alert"
      color="error"
      dark
      dense
      v-model="err"
      dismissible
    > <span class="caption text-start font-weight-bold" >
      {{ message }}
    </span>
  </v-alert>
        <p class="mb-0">
          Please sign-in to your account and start the adventure
        </p>
      </v-card-text>

      <v-card-text>
        <v-form @submit.prevent="() => {}">
          <v-row>
            <!-- email -->
            <v-col cols="12">
              <v-text-field
                label="Email"
                type="email" outlined
                v-model="userName"
                :error-messages="userNameErrorMessages"
                :error-count="userNameErrorCount"
                :error="userNameError"
                autocomplete="off"
              ></v-text-field>
            </v-col>

            <!-- password -->
            <v-col cols="12">
              <!-- <v-text-field
                label="Password"
                placeholder="············"
                :type="isPasswordVisible ? 'text' : 'password'"
                :append-inner-icon="isPasswordVisible ? 'mdi-eye-off-line' : 'mdi-eye-line'"
                @click:append-inner="isPasswordVisible = !isPasswordVisible" outlined aria-autocomplete="off" autocomplete="off"
                v-on:keyup.enter="onEnter"
                v-model="passWord"
                :error-messages="userPassErrorMessages"
                :error-count="userPassErrorCount"
                :error="userPassError"
              ></v-text-field> -->


              <v-text-field
              v-model="passWord"
              outlined
              :type="isPasswordVisible ? 'text' : 'password'"
              label="Password"
              placeholder="············"
              :error-messages="userPassErrorMessages"
              :error-count="userPassErrorCount"
              :error="userPassError"
            >
              <template v-slot:append>
                <v-icon
                  class="mt-n1"
                  @click="isPasswordVisible = !isPasswordVisible"
                >
                  {{ isPasswordVisible ? 'mdi-eye' : 'mdi-eye-off' }}
                </v-icon>
              </template>
            </v-text-field>
              <!-- remember me checkbox -->
              <div class="d-flex align-center justify-space-between flex-wrap mt-1 mb-4">
                <v-checkbox
                  label="Remember me"
                />

                <a
                  class="ms-2 mb-1"
                  href="javascript:void(0)"
                >
                  Forgot Password?
                </a>
              </div>

              <!-- login button -->
              <v-btn
                block
                type="button" color="primary" @click="login"
              >
                Login
              </v-btn>
            </v-col>

            <!-- create account -->
            <v-col
              cols="12"
              class="text-center text-base"
            >
              <span>Lupa password?</span>
            </v-col>

            <v-col
              cols="12"
              class="d-flex align-center"
            >
              <v-divider />
              <span class="mx-4">or</span>
              <v-divider />
            </v-col>

            <!-- auth providers -->
            <v-col
              cols="12"
              class="text-center"
            >
              
            </v-col>
          </v-row>
        </v-form>
      </v-card-text>
    </v-card>

    <v-img
      class="auth-footer-start-tree d-none d-md-block"
      :width="250"
    />

    <v-img
      class="auth-footer-end-tree d-none d-md-block"
      :width="350"
    />

    <!-- bg img -->
    <v-img
      class="auth-footer-mask d-none d-md-block"
    />
    </v-col></v-row>
  <!-- </div> -->
</template>

<style scoped>
.v-text-field--full-width > .v-input__control > .v-input__slot,
.v-text-field--outlined > .v-input__control > .v-input__slot {
    min-height: 48px
}
</style>

<script>
const t = "?t="+Math.random(), BASE_URL = "../../../"

module.exports = {
    components : {
    },

    data: function() {
        return {
            title: 'Masterdata Posisi' ,
            isPasswordVisible: false,
            // error
            userNameError: false,
            userNameErrorCount: 0,
            userNameErrorMessages: '',
            userNameErrorMessage: 'Invalid email or password',
            userPassError: false,
            userPassErrorCount: 0,
            userPassErrorMessages: '',
            userPassErrorMessage: 'This field is required',
            // MessageError : ''
        }
    },

    computed : {
      __s () { return this.$store.state.login },

      userName : {
        get () { return this.__s.userName },
        set (v) { this.__c("userName", v) }
      },

      passWord : {
        get () { return this.__s.passWord },
        set (v) { this.__c("passWord", v) }
      },

      message : {
        get () { return this.__s.message },
        set (v) { this.__c("message", v) }
      },
      err : {
        get () { return this.__s.err },
        set (v) { this.__c("err", v) }
      },

      // err () {
      //   return this.__s.err
      // },

      logo () {
        return BASE_URL + 'assets/img/logo-sibambo-small.png'
      }
    },

    methods : {
      __c (a,b) { return this.$store.commit("login/SET_OBJECT", [a, b]) },

      login () {
        this.err = false;
        setTimeout(() => {
        this.check();
        }, 200); 
      },
      check(){
        this.$store.dispatch( "login/login" ).then((x) => {
          if (x.status && x.status == "ERR") {
            this.err = true;
            return
          }
          window.location = "../../dashboard/d/";
          // window.location = "../dashboard";
        })
      },

      onEnter () {
        if (['xs', 'sm', 'md'].indexOf(this.$vuetify.breakpoint.name != 'xs') < 0)
          return this.login()

          return false
      }
    }
}