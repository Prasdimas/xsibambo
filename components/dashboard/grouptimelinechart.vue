<template>
	<v-card class="rounded-xl mt-2" flat>
		<v-card-text class="pa-0">
			<v-row class="mb-0">
			<v-col cols="12">
				<v-row>
					<v-col cols="12" class="d-flex justify-center mt-2">
						<v-sheet height="220" width="220">
							<canvas id="timelinegroupChartCanvas"></canvas>
						</v-sheet>
					</v-col>
				</v-row>
				<v-col cols="12">
					<v-list>
						<v-list-item-group>
							<template v-for="(item, index) in statusProject">
								<v-list-item class="px-0">
									<v-list-item-icon class="my-1">
										<v-icon :color="item.status_color">mdi-checkbox-blank-circle</v-icon>
									</v-list-item-icon>
									<template>
										<v-list-item-content class="py-1">
											<v-list-item-title class="text-md-body-2 font-weight-bold subtitle-1"
												v-text="item.status_name"></v-list-item-title>
										</v-list-item-content>

										<v-list-item-action class="my-1">
											<v-list-item-action-text class="subtitle-1"
												v-text="item.jumlah_status"></v-list-item-action-text>
										</v-list-item-action>
									</template>
								</v-list-item>

								<v-divider v-if="index < statusProject.length - 1"
									:key="index"></v-divider>
							</template>
						</v-list-item-group>
					</v-list>
				</v-col>
			</v-col>
		</v-row>
		</v-card-text>
		
	</v-card>
</template>

<style scoped>
.v-list-item {
    min-height: auto;
}
</style>
<script>
module.exports = {
	data() {
		return {
			title: "Dashboard",
			backgroundColor: [
				'rgb(255, 99, 132)',
				'rgb(54, 162, 235)',
				'rgb(255, 205, 86)'
			],
		};
	},
	computed: {
		...Vuex.mapState({
			timeline: (s) => s.project.timeline_groups,
			totalProject: (s) => s.project.total_count,
			statusProject: (s) => s.project.projectStatus,
		}),
	},
	mounted() {
		this.__d("statustimeline").then((d) => {

			this.timelineGroupChart();
		})
	},

	methods: {
		__d(a) {
			return this.$store.dispatch("project/" + a);
		},
		timelineGroupChart() {
			const color = this.statusProject.map(item => item.status_color);
			const labels = this.statusProject.map(item => item.status_name);
			const dataValues = this.statusProject.map(item => parseInt(item.jumlah_status));

			const data = {
				labels: labels,
				datasets: [{
					data: dataValues,
					backgroundColor: color
				}]
			};

			const options = {
				plugins: {
					legend: {
						display: false
					}
				}
			};

			// Register plugin before creating the chart instance
			Chart.register({
				id: 'textInside',
				afterDatasetsDraw: function (chart) {
					const ctx = chart.ctx;
					const width = chart.width;
					const height = chart.height;
					const fontSize = 18;
					const label1 = "Total";
					const label2 = "Project";
					const value = this.totalProject; // Get the total project count

					// Calculate text positions
					const textX = Math.round(width / 2);
					const textY = Math.round(height / 2);
					const lineHeight = fontSize * 1.5; // Adjust line height as needed
					const verticalOffset = 25; // Adjust this offset as needed

					// Draw label in bold
					ctx.font = `${fontSize}px 'D-DIN'`;
					ctx.fillStyle = 'black';
					ctx.textAlign = 'center';
					ctx.textBaseline = 'middle';
					// ctx.fillText(label1, textX, textY - lineHeight - 5);
					ctx.fillText(label1, textX, (height - (18+18+26))/2 + 9);

					ctx.font = `${fontSize}px  'D-DIN'`;
					ctx.fillStyle = 'black';
					ctx.textAlign = 'center';
					ctx.textBaseline = 'middle';
					// ctx.fillText(label2, textX, textY - verticalOffset);
					ctx.fillText(label2, textX, (height - (18+18+26))/2 + 27 + 5);

					// Draw value in regular font
					ctx.font = `bold 26px  'D-DIN'`;
					ctx.fillText(value, textX, (height - (18+18+26))/2 + 18 + 18 + 13 + 10);
				}.bind(this) // Bind 'this' context to access 'this.totalProject'
			});


			new Chart(document.getElementById('timelinegroupChartCanvas'), {
				type: 'doughnut',
				data: data,
				options: options,
				responsive: true
			});
		}


	},
}
</script>