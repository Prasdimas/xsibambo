<template>
  <v-container fluid>
    <!-- Header -->
    <v-row>
      <v-col cols="12" class="pa-0">
        <v-img
          class="white--text"
          height="300px"
          position="center center"
          src="https://assets-global.website-files.com/63d0f93b8842ec945ab130c6/6513c0307c7d701e57f62433_Bayt%20A%27elat.webp"
          gradient="to top right, rgba(0,0,0,.5), rgba(0,0,0,.5)"
        >
          <v-container fill-height fluid>
            <v-layout fill-height>
              <v-flex xs12 align-start flexbox>
                <h5 class="text-h5 font-weight-semibold mb-1">
                  Welcome to SiBambo Studio 👋🏻
                </h5>
              </v-flex>
            </v-layout>
          </v-container>
        </v-img>
      </v-col>
    </v-row>

    <!-- Cards Section -->
    <v-row>
      <!-- Total Invoices Card -->
      <v-col cols="12" md="6" xl="3" sm="6">
        <v-card
          color="orange accent-4"
          class="pa-1 rounded-lg"
          style="
            opacity: 0.6;
            background-image: url(../../../assets/img/pattern/pattern8.png);
            background-position: bottom top;
          "
        >
          <v-card-text>
            <div class="d-flex align-items-center">
              <v-icon
                class="pa-4 rounded-circle"
                style="
                  background-color: rgba(255, 255, 255, 0.4);
                  height: 76px;
                  margin-top: 15px;
                "
                color="white"
                size="45"
              >
                mdi-monitor-multiple
              </v-icon>
              <div class="flex-grow-1 pa-2">
                <div class="fw-bold display-2 text-white pa-1">1200</div>
                <div class="text-white pa-1 subheading font-weight-medium">
                  Total Invoices
                </div>
              </div>
            </div>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- Paid Invoices Card -->
      <v-col cols="12" md="6" xl="3" sm="6">
        <v-card
          color="green accent-4"
          class="pa-1 rounded-lg"
          style="
            opacity: 0.6;
            background-image: url(../../../assets/img/pattern/pattern9.png);
            background-size: cover;
            background-position: top center;
          "
        >
          <v-card-text>
            <div class="d-flex align-items-center">
              <v-icon
                class="pa-4 rounded-circle"
                style="
                  background-color: rgba(255, 255, 255, 0.4);
                  height: 76px;
                  margin-top: 15px;
                "
                color="white"
                size="45"
              >
                mdi-checkbox-marked-circle-outline
              </v-icon>
              <div class="flex-grow-1 pa-2">
                <div class="fw-bold display-2 text-white pa-1">900</div>
                <div class="text-white pa-1 subheading font-weight-medium">
                  Paid Invoices
                </div>
              </div>
            </div>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- Unpaid Invoices Card -->
      <v-col cols="12" md="6" xl="3" sm="6">
        <v-card
          color="deep-purple accent-3"
          class="pa-1 rounded-lg"
          style="
            opacity: 0.6;
            background-image: url(../../../assets/img/pattern/pattern10.png);
            background-position: center left;
          "
        >
          <v-card-text>
            <div class="d-flex align-items-center">
              <v-icon
                class="pa-4 rounded-circle"
                style="
                  background-color: rgba(255, 255, 255, 0.4);
                  height: 76px;
                  margin-top: 15px;
                "
                color="white"
                size="45"
              >
                mdi-close-circle-outline
              </v-icon>
              <div class="flex-grow-1 pa-2">
                <div class="fw-bold display-2 text-white pa-1">234</div>
                <div class="text-white pa-1 subheading">Unpaid Invoices</div>
              </div>
            </div>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- Total Invoices Sent Card -->
      <v-col cols="12" md="6" xl="3" sm="6">
        <v-card
          color="teal darken-4"
          class="pa-1 rounded-lg"
          style="
            opacity: 0.6;
            background-image: url(../../../assets/img/pattern/pattern9.png);
            background-position: center left;
          "
        >
          <v-card-text>
            <div class="d-flex align-items-center">
              <v-icon
                class="pa-4 rounded-circle"
                style="
                  background-color: rgba(255, 255, 255, 0.4);
                  height: 76px;
                  margin-top: 15px;
                "
                color="white"
                size="45"
              >
                mdi-book-open
              </v-icon>
              <div class="flex-grow-1 pa-2">
                <div class="fw-bold display-2 text-white pa-1">834</div>
                <div class="text-white pa-1 subheading">
                  Total Invoices Sent
                </div>
              </div>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- Balance and Overview Section -->
    <v-row>
      <!-- Balance Card -->
      <v-col cols="12" md="12" xl="9">
        <v-card class="pa-3">
          <v-row>
            <v-col cols="12" md="6" xl="6">
              <v-card
                class="blue darken-4 rounded-lg pa-7 mt-2 card-bx"
                style="
                  opacity: 0.9;
                  background-image: url(../../../assets/img/pattern/pattern7.png);
                  background-position: center center;
                "
              >
                <div class="card-info text-white">
                  <img
                    src="../../../assets/img/pattern/circle.png"
                    alt=""
                    class="mb-4"
                  />
                  <h2 class="text-white card-balance">$824,571.93</h2>
                  <p class="fs-16">Wallet Balance</p>
                  <span>+0.8% than last week</span>
                </div>
                <a
                  class="change-btn rounded-lg"
                  href="#"
                  style="text-decoration: none"
                  >Change
                  <v-icon class="reload-icon">mdi-account-convert</v-icon></a
                >
              </v-card>
            </v-col>
            <v-col cols="12" md="6">
              <v-row class="pr-1">
                <!-- Card Overview Section -->
                <v-col cols="12" md="6">
                  <h3 class="text-capitalize pt-2">Card's Overview</h3>
                  <p class="caption text-weight-light">
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit psu
                    olor
                  </p>
                  <v-list>
                    <v-list-item
                      class="pa-1"
                      v-for="(item, index) in polar"
                      :key="index"
                    >
                      <v-icon class="mr-2" :color="item.color"
                        >mdi-checkbox-blank-circle</v-icon
                      >

                      <v-list-item-title>{{ item.name }}</v-list-item-title>
                      <v-list-item-title class="mr-5"
                        >{{ item.value }} %</v-list-item-title
                      >
                    </v-list-item>
                  </v-list>
                </v-col>

                <!-- PolarChart Section -->
                <v-col cols="12" md="6" >
                  <PolarChart></PolarChart>
                </v-col>
              </v-row>
            </v-col>
          </v-row>
        </v-card>
      </v-col>

      <!-- Activity Section -->
      <v-col cols="12" md="12" xl="3">
        <activity></activity>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
const t = "?t=" + Math.random();
module.exports = {
  components: {
    polarchart: httpVueLoader("../dashboard/polarchart.vue" + t),
    activity: httpVueLoader("../dashboard/activity.vue" + t),
  },
  data() {
    return {
      dialog: false,
      dark: false,
      value: [13, 26, 35, 40, 70, 80, 116, 123, 145, 155, 160, 165],
      polar: [
        { name: "Account", color: "#496ecc", value: 40 },
        { name: "Services", color: "#68e365", value: 35 },
        { name: "Restaurant", color: "#ffa755", value: 30 },
        { name: "Other", color: "#c8c8c8", value: 20 },
      ],
    };
  },
  computed: {},
  methods: {
    __c(a, b) {
      return this.$store.commit("masterwork/SET_OBJECT", [a, b]);
    },
  },
};
</script>
