<template>
	<v-row>
		<v-col cols="12">
			<v-card>
				<v-card-title primary-title class="py-2">
					<v-row>
						<v-col cols="9">
							<h5 class="font-weight-bold text-h5 text-typo mb-0">
								DATA POSISI / JABATAN
							</h5>
							<p class="text-sm text-body font-weight-light mb-0">
								Features include sorting, searching, pagination,
								content-editing, and row selection.
							</p>
						</v-col>
						<v-col cols="3">
							<searchbar @add="add" @search="search" @change="query"></searchbar>
						</v-col>
					</v-row>
				</v-card-title>
				<v-card-text class="py-2 px-3">
					<v-data-table :headers="headers" :items="positions" :items-per-page="10" class="elevation-1"
						hide-default-footer>
						<template v-slot:item="{ item }">
							<tr @click="select(item)" :class="[isSelected(item) ? 'blue lighten-5' : '']">
								<td>
									<span v-if="item.position_code.length > 2" class="grey--text">{{
								"&nbsp".repeat((item.position_code.length - 4) * 2) }} ▌
									</span>
									{{ item.position_name }}
								</td>
								<td>{{ item.position_note }}</td>
								<td class="text-center">
									<!-- <v-btn color="primary" class="" icon depressed @click="edit(item)" small>
                                    <v-icon>mdi-pencil</v-icon>
                                </v-btn>
                                <v-btn color="red red-lighten-5--text" icon depressed @click="del(item)" small>
                                    <v-icon>mdi-delete</v-icon>
                                </v-btn> -->

									<v-menu bottom left>
										<template v-slot:activator="{ on, attrs }">
											<v-btn color="primary" dark icon v-bind="attrs" v-on="on">
												<v-icon>mdi-dots-horizontal</v-icon>
											</v-btn>
										</template>

										<v-list>
											<v-list-item>
												<v-list-item-title><a href="javascript:;" @click="edit(item)"><v-icon
															small class="mr-2">mdi-pencil</v-icon>
														Ubah</a></v-list-item-title>
											</v-list-item>
											<v-list-item>
												<v-list-item-title><a href="javascript:;" @click="del(item)"><v-icon
															small class="mr-2">mdi-delete</v-icon>
														Hapus</a></v-list-item-title>
											</v-list-item>
										</v-list>
									</v-menu>
								</td>
							</tr>
						</template>
					</v-data-table>
				</v-card-text>
				<v-card-actions>
					<v-pagination v-model="curPage" :length="totalPage" :total-visible="7"></v-pagination>
				</v-card-actions>
			</v-card>
			<ddelete @todo="doDel" v-if="dialogDelete"></ddelete>
		</v-col>
	</v-row>
</template>

<script>
const t = "?t=" + Math.random();
module.exports = {
	components: {
		searchbar: httpVueLoader("../_common/search_bar.vue" + t),
		ddelete: httpVueLoader("../_common/delete_dialog.vue" + t),
	},

	data: function () {
		return {
			title: "Masterdata Posisi",
		};
	},

	computed: {
		...Vuex.mapState({
			dialogDelete: (s) => s.misc.dialogDelete,
		}),

		__s() {
			return this.$store.state.masterPosition;
		},
		THEME() {
			return this.$store.state.app.THEME;
		},

		headers() {
			let h = [
				["NAMA", "position_name"],
				["CATATAN", "position_note", 0, "start"],
				["TODO", null, "10%", "center"],
			];
			let hdrs = [];
			for (let x of h) {
				hdrs.push({
					text: x[0],
					align: x[3] ? x[3] : "start",
					sortable: false,
					value: x[1] ? x[1] : "",
					class: "subtitle-1",
					width: x[2] ? x[2] : 0,
				});
			}

			return hdrs;
		},

		positions() {
			return this.__s.positions;
		},

		selectedPosition: {
			get() {
				return this.__s.selectedPosition;
			},
			set(v) {
				this.__c("selectedPosition", v);
			},
		},

		total() {
			return this.__s.totalPos;
		},

		totalPage() {
			return this.__s.totalPosPage;
		},

		curPage: {
			get() {
				return this.__s.curPage; },
			set(v) {
				this.__c("curPage", v), this.search() },
		},
	},

	methods: {
		__c(a, b) {
			return this.$store.commit("masterPosition/SET_OBJECT", [a, b]);
		},

		search() {
			this.$store.dispatch("masterPosition/search");
		},

		query(v) {
			this.__c("search", v);
			this.search();
		},

		add() {
			this.__c("positionName", "");
			this.__c("positionNote");
			this.__c("posId", 0);
			this.__c("edit", false);
			this.__c("dialog", true);
		},

		edit(x) {
			this.select(x);
			this.__c("positionName", x.position_name);
			this.__c("positionNote", x.position_note);
			this.__c("posId", x.position_id);
			this.__c("edit", true);
			this.__c("dialog", true);
		},

		del(x) {
			this.select(x);
			this.$store.commit("misc/SET_OBJECT", ["dialogDelete", true]);
		},

		doDel() {
			this.$store.dispatch("masterPosition/delete").then((d) => {
				this.$store.commit("misc/SET_OBJECT", ["dialogDelete", false]);
				this.search();
			});
		},

		select(x) {
			this.selectedPosition = x;
		},

		isSelected(x) {
			if (!x || !this.selectedPosition) return false;
			if (x.position_id == this.selectedPosition.position_id) return true;
			return false;
		},
	},

	mounted() { },
};
</script>
