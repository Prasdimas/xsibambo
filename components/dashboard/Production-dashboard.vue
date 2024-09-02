<template>
	<v-row>
		<v-col cols="12" class="px-5">
			<v-row>
				<v-col cols="10">
					<h1 class="pr-2 text-h4 font-weight-bold">Hello, {{ employee_name }}</h1>
				</v-col>
				<v-col cols="2">
					<v-row align="center">
						<!-- Avatar Column -->
						<v-col cols="auto" class="d-flex align-center">
							<v-avatar size="36">
								<img alt="Avatar" src="https://avatars0.githubusercontent.com/u/9064066?v=4&s=460">
							</v-avatar>
						</v-col>

						<!-- Name Column -->
						<v-col class="d-none d-sm-flex align-right">
							<h1 class="pr-2 text-h5 font-weight-light">{{ employee_name }}</h1>
						</v-col>
					</v-row>
				</v-col>
			</v-row>

			<v-row class="mt-0">
				<v-col cols="12" md="8" lg="8" class="pt-0">
					<v-row class="mt-1">
						<v-col cols="12">
							<v-sheet class="overflow-x-auto hide-scrollbar rounded-xl" style="max-height: 550px; background-color: transparent;">
								<v-expansion-panels >
									<v-expansion-panel v-for="(item, index) in timeline_groups" :key="index" class="rounded-xl" :class="['mt-2']" style="overflow-y:hidden">

										<!-- TIMELINE GROUPS -->
										<v-expansion-panel-header hide-actions color="white" class="pa-4">
											<v-row dense>
												<v-col cols="12" md="2" class="pr-4">
													<v-card flat
														class="align-center fill-height primary rounded-lg rounded-md"
														style="min-height:80px">
														<v-card-text class="fill-height pa-3 justify-center d-flex flex-column text-center">
															<h3 class="white--text headline">100<span class="title">%</span>
															</h3>
															<h5 class="white--text">Complete</h5>
														</v-card-text>
													</v-card>
												</v-col>
												<v-col cols="12" md="7">
													<span>
														<v-icon size="32" color="primary">{{ iconDefault[item.group_id -
						1] }}</v-icon>
													</span>
													<h3 class="font-weight-medium">Tahap</h3>
													<h3>{{ item.group_name }}</h3>
												</v-col>
												<v-col cols="12" md="3">
													<v-row no-gutters class="fill-height d-flex">
														<v-col cols="6" class="text-right align-content-end mr-2">
															<div class="font-weight-bold ">
																<span
																	class="display-3 font-weight-bold  primary--text">{{
						item.project_count }}</span>
															</div>
														</v-col>
														<v-col cols="4" class="align-content-end mb-0">
															<!-- <div class=""> -->
															<p class="grey--text font-weight-bold title mb-2"
																style="line-height: 120%;">dari<br>{{
						totalProject.toString().padStart(2,
							'0') }}</p>
															<!-- </div> -->
														</v-col>
													</v-row>
												</v-col>
											</v-row>
										</v-expansion-panel-header>

										<!-- TIMELINE ITEMS -->
										<v-expansion-panel-content style="font-size: .9375em;" class="pa-4 pt-0">
											<!-- <v-divider class="mb-2"></v-divider> -->
											<v-row v-for="(tmln, n) in item.timelines" dense>
												<v-col cols="12">
													<v-divider class="mx-2"></v-divider>
												</v-col>

												<v-col cols="12" md="2" class="pr-4">
													<v-card flat
														class="align-center fill-height rounded-lg rounded-md"
														style="min-height:80px">
														<v-card-text class="fill-height grey pa-3 flex-column justify-center d-flex text-center">
															<h3 class="white--text headline">100<span class="title">%</span>
															</h3>
															<h5 class="white--text">Complete</h5>
														</v-card-text>
														
													</v-card>
												</v-col>
												<v-col cols="12" md="7">
													<span>
														<v-icon size="32" color="primary">{{ iconDefault[item.group_id -
						1] }}</v-icon>
													</span>
													<h3 class="font-weight-medium">Tahap</h3>
													<h3 class="font-weight-medium">{{ tmln.timeline_name }}</h3>
												</v-col>
												<v-col cols="12" md="3">
													<v-row no-gutters class="fill-height d-flex">
														<v-col cols="6" class="text-right align-content-end mr-2">
															<div class="font-weight-bold ">
																<span
																	class="display-3 font-weight-bold  primary--text">{{
						tmln.project_count }}</span>
															</div>
														</v-col>
														<v-col cols="4" class="align-content-end mb-0">
															<!-- <div class=""> -->
															<p class="grey--text font-weight-bold title mb-2"
																style="line-height: 120%;">dari<br>{{
						totalProject.toString().padStart(2,
							'0') }}</p>
															<!-- </div> -->
														</v-col>
													</v-row>
												</v-col>

												
											</v-row>
										</v-expansion-panel-content>
									</v-expansion-panel>
								</v-expansion-panels>
							</v-sheet>
						</v-col>
					</v-row>
				</v-col>
				<v-col cols="12" md="4" lg="4" class="mt-7">
					<grouptimelinechart></grouptimelinechart>
				</v-col>
			</v-row>
		</v-col>
	</v-row>
</template>
<style scoped>
h1,
h3,
h5,
.text-h4 {
	font-family: 'D-DIN' !important;
}

.hide-scrollbar {
    overflow-y: scroll;
}

.hide-scrollbar::-webkit-scrollbar {
    width: 0; /* Remove scrollbar space */
    background: transparent; /* Optional: Just to ensure it's invisible */
}
.v-expansion-panel-header {
    line-height: 1.5;
}
.v-expansion-panel-content__wrap {
	padding: 0px;
	padding-right: 0px;
}
</style>
<script>
const t = "?t=" + Math.random();
module.exports = {
	components: {
		grouptimelinechart: httpVueLoader("../dashboard/grouptimelinechart.vue" + t),
	},
	data() {
		return {
			employee_name: "",
			dialog: false,
			iconDefault: [
				"mdi-home-city",
				"mdi-car",
				"mdi-file-document-edit"
			],
		};
	},
	computed: {
		__s() {
			return this.$store.state.project;
		},
		...Vuex.mapState({
			timeline_groups: (s) => s.project.timeline_groups,
			projects: (s) => s.project.projects,
			// totalProject: (s) => s.project.total_count,
			totalCustomers: (s) => s.project.totalCustomers,
			totalPage: (s) => s.project.totalPage,
		}),
		curPage: {
			get() {
				return this.__s.curPage;
			},
			set(v) {
				this.__c("curPage", v);
				this.__d("search");
			},
		},

		totalProject() {
			let sum = this.timeline_groups.reduce((accumulator, currentItem) => {
				return accumulator + parseInt(currentItem.project_count);
			}, 0);

			return sum
		}
	},
	methods: {
		__c(a, b) {
			return this.$store.commit("project/SET_OBJECT", [a, b]);
		},
		__d(a) {
			return this.$store.dispatch("project/" + a);
		},
		handleClick(item) {
			// console.log(item);
			if (!item.type_group) {
				this.__c("timelinegroup_id", item.M_TimelineGroupID)
				this.__d("TimelinebyGroup")
				return
			} else {
				this.__d("count")

			}

		}
	},
	mounted() {
		let userDataJSON = localStorage.getItem('siBamboUser');
		if (userDataJSON) {
			let userData = JSON.parse(userDataJSON);
			this.employee_name = userData.employee_name;
		}
	},
}