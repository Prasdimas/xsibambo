<template>
  <v-card class="pa-5 rounded-3" min-height="325">
    <v-row>
      <v-col cols="6" md="6" xl="6">
        <h4 class="font-weight-regular text-capitalize">activity</h4>
        <h2 class="font-weight-regular pt-1">$78120</h2>
      </v-col>
      <v-col cols="6" md="6" xl="6">
        <v-list class="text-right">
          <v-list-item
            class="pr-3"
            v-for="(item, index) in info"
            :key="item.id"
          >
            <v-list-item-title>{{ item.name }}</v-list-item-title>
            <v-list-item-title class="body-2">
              <v-icon :color="item.color">mdi-checkbox-blank-circle</v-icon>
            </v-list-item-title>
          </v-list-item>
        </v-list>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" md="12" xl="12">
        <canvas style="min-height: 700" id="barChart"></canvas>
      </v-col>
    </v-row>
  </v-card>
</template>

<script>
module.exports = {
  data() {
    return {
      title: "Dashboard",
      info: [
        { id: 1, name: "Income", color: "#80ec67" },
        { id: 2, name: "Outcome", color: "#fe7d65" },
      ],
    };
  },

  mounted() {
    this.barChart();
  },

  methods: {
    barChart() {
      var ctx = document.getElementById("barChart").getContext("2d");

      var options = {
        type: "bar",
        data: {
          labels: ["Sun", "Mon", "Tue", "Wed"],
          datasets: [
            {
              label: "Income",
              data: [50, 18, 70, 40],
              backgroundColor: "#80ec67",
            },
            {
              label: "Outcome",
              data: [80, 40, 55, 20],
              backgroundColor: "#fe7d65",
            },
          ],
        },
        options: {
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: "top",
              labels: {
                font: {
                  size: 12,
                },
              },
            },
          },
          scales: {
            x: {
              ticks: {
                color: "#3e4954",
                font: {
                  family: "poppins",
                  size: 13,
                },
              },
            },
            y: {
              ticks: {
                color: "#3e4954",
                font: {
                  family: "poppins",
                  size: 13,
                },
                callback: function (value) {
                  return value;
                },
              },
            },
          },
        },
      };

      var chartBar1 = new Chart(ctx, options);
    },
  },
};
</script>
