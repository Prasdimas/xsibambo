<template>
  <v-row>
    <v-col cols="12" class="pa-5">
      <v-card>
        <!-- Header: Selamat Datang -->
        <v-row>
          <v-col cols="12" class="pt-0">
            <!-- <v-card-title>Selamat Datang</v-card-title> -->
            <v-card>
              <v-img
                class="white--text"
                height="300px"
                src="https://assets-global.website-files.com/63d0f93b8842ec945ab130c6/6513c0307c7d701e57f62433_Bayt%20A%27elat.webp"
                gradient="to top right, rgba(0,0,0,.5), rgba(0,0,0,.5)"
              >
                <v-container fill-height fluid>
                  <v-layout fill-height>
                    <v-flex xs12 align-start flexbox>
                      <h5 class="text-h5 font-weight-semibold mb-1">
                        Welcome to SiBambo Construction Studio 👋🏻
                      </h5>
                    </v-flex>
                  </v-layout>
                </v-container>
              </v-img>
            </v-card>
          </v-col>
        </v-row>

        <!-- Grafik -->
        <v-row>
          <v-col lg="2" sm="2" md="2">
            <v-card max-width="300" class="pa-1">
              <canvas id="myChart" width="10" height="10"></canvas>
            </v-card>
          </v-col>
          <v-col lg="10" sm="10" md="10">
            <!-- <project></project> -->

            <!-- <v-card class="pa-5"> -->
            <v-card-title> <h4>Timeline Project</h4> </v-card-title>
            <v-list>
              <v-list-item
                v-for="(item, index) in totalproject"
                :key="item.timeline_id"
              >
                <v-list-item-action>
                  <v-checkbox :input-value="active"></v-checkbox>
                </v-list-item-action>
                <v-list-item-title>
                  {{ index + 1 }}. Timeline :
                  {{ item.timeline_name }}</v-list-item-title
                >
                <v-list-item-title>
                  {{ item.total_timeline_count }}</v-list-item-title
                >
              </v-list-item>
            </v-list>
            <v-list>
              <v-list-item>
                <v-list-item-title> Total Project :</v-list-item-title>
                <v-list-item-title> {{ totaltimeline }}</v-list-item-title>
              </v-list-item>
            </v-list>
            <!-- <v-card-title>
              <h5>Total Project : {{ totaltimeline }}</h5>
            </v-card-title> -->
            <!-- </v-card> -->
          </v-col>
        </v-row>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
const t = "?t=" + Math.random();
module.exports = {
  components: {
    // project: httpVueLoader("../project/project.vue" + t),
    searchbar: httpVueLoader("../_common/search_bar.vue" + t),
    ddelete: httpVueLoader("../_common/delete_dialog.vue" + t),
  },

  data: function () {
    return {
      title: "Dashboard",
      arr2: [
        { P_ProjectM_TimelineID: 1, total_timeline_count: 10 },
        { P_ProjectM_TimelineID: 3, total_timeline_count: 5 },
      ],
    };
  },

  computed: {
    __s() {
      return this.$store.state.masterDashboard;
    },
    THEME() {
      return this.$store.state.app.THEME;
    },
    totalproject() {
      return this.__s.totalproject;
    },
    timeline() {
      return this.__s.timeline;
    },
    totaltimeline() {
      return this.__s.totaltimeline;
    },

    total() {
      return this.__s.totalPos;
    },

    totalPage() {
      return this.__s.totalPosPage;
    },

    curPage: {
      get() {
        return this.__s.curPage;
      },
      set(v) {
        this.__c("curPage", v);
      },
    },
  },

  methods: {},

  mounted() {
    this.$store.dispatch("masterDashboard/search").then(() => {
      console.log(this.$store.state);

      function gabungTimeline(arr1, arr2) {
        return arr1
          .map((item1) => {
            const matchingItem = arr2.find(
              (item2) => item2.P_ProjectM_TimelineID === item1.timeline_id
            );
            if (matchingItem) {
              return {
                ...item1,
                total_timeline_count: matchingItem.total_timeline_count,
              };
            }
          })
          .filter(Boolean); // Filter untuk menghapus nilai yang tidak didefinisikan (null atau undefined)
      }

      // function gabungTimeline(arr1, arr2) {
      //   return arr1.map((item1) => {
      //     const matchingItem = arr2.find(
      //       (item2) => item2.P_ProjectM_TimelineID === item1.timeline_id
      //     );
      //     if (matchingItem) {
      //       return {
      //         ...item1,
      //         total_timeline_count: matchingItem.total_timeline_count,
      //       };
      //     } else {
      //       return { ...item1, total_timeline_count: 0 };
      //     }
      //   });
      // }

      const arr1 = this.$store.state.masterDashboard.timelines;

      const timelineNames = this.$store.state.masterDashboard.timelines.map(
        (timeline) => timeline.timeline_name
      );

      const arr2 = this.$store.state.masterDashboard.timeline;

      const hasilGabungan = gabungTimeline(arr1, arr2);
      this.$store.commit("masterDashboard/SET_OBJECT", [
        "totalproject",
        hasilGabungan,
      ]);
      console.log(hasilGabungan);
      const hasiltimeline = hasilGabungan.map(
        (hasil) => hasil.total_timeline_count
      );
      const data = {
        labels: timelineNames,
        datasets: [
          {
            label: "Timeline",
            data: hasiltimeline,
            backgroundColor: [
              "red",
              "blue",
              "yellow",
              "green",
              "purple",
              "orange",
              "cyan",
              "magenta",
              "lime",
              "pink",
              "teal",
              "lavender",
              "brown",
              "maroon",
              "olive",
              "navy",
              "aquamarine",
              "turquoise",
              "gold",
              "crimson",
              "coral",
              "indigo",
              "violet",
            ],
            hoverOffset: 4,
          },
        ],
      };
      // Options untuk chart
      const options = {
        responsive: true,
        plugins: {
          legend: {
            position: "left",
            display: false,
          },
          title: {
            display: false,
            text: "Timeline",
          },
        },
      };

      const ctx = document.getElementById("myChart").getContext("2d");
      const myChart = new Chart(ctx, {
        type: "pie",
        data: data,
        options: options,
      });
    });
  },
};
</script>
