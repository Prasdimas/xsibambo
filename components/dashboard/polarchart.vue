<template>
  <v-row>
    <v-col cols="12" class="pa-3">
      <canvas style="max-width: 800" id="polarChartCanvas"></canvas>
    </v-col>
  </v-row>
</template>

<script>
module.exports = {
  data() {
    return {
      title: "Dashboard",
    };
  },

  mounted() {
    this.createPolarChart();
  },

  methods: {
    createPolarChart() {
      var ctx = document.getElementById("polarChartCanvas").getContext("2d");

      var myChart = new Chart(ctx, {
        type: "polarArea",
        data: {
          labels: ["Account", "Service", "Restaurant", "Other"],
          datasets: [
            {
              backgroundColor: ["#496ecc", "#68e365", "#ffa755", "#c8c8c8"],
              data: [40, 35, 30, 20],
            },
          ],
        },
        options: {
          plugins: {
            legend: false,
          },
          maintainAspectRatio: false,
          scales: {
            r: {
              ticks: {
                display: false,
              },
              grid: {
                display: false,
              },
            },
          },
          tooltips: {
            enabled: false,
          },
        },
      });
    },
  },
};
</script>
