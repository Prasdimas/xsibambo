<template>
    <v-row class="mt-0">
        <v-col cols="12" class="px-5">
            
            <v-card class="rounded-xl" flat>
                <v-card-title primary-title class="py-2">
                    <v-row>
                        <v-col cols="8" class="align-center d-flex">
                            <h5 class="font-weight-bold text-h4 text-typo mb-0">
                                Client Data Table
                            </h5>

                        </v-col>
                        <v-col cols="2">
                            <!-- <v-autocomplete
                            v-model="filter"
                            :items="timelines"
                            item-value="timeline_name"
                            item-text="timeline_name"
                        hide-details
                        clearable
                        label="Filter"
                        prepend-icon="mdi-filter"
                    >
                </v-autocomplete> -->

                            <v-autocomplete v-model="filter" :items="flattenedItems" item-value="name" item-text="name"
                                hide-details clearable label="Filter" prepend-icon="mdi-filter">
                                <template v-slot:item="data">
                                    <v-list-item-content class="pa-0" dense>
                                        <!-- Tampilkan nama grup hanya sekali -->
                                        <v-list-item-title v-if="data.item.type === 'group'">
                                            <h5>{{ data.item.name }}</h5>
                                        </v-list-item-title>
                                        <!-- Tampilkan nama timeline di bawah grup -->
                                        <v-list-item v-if="data.item.type === 'timeline'" :key="data.item.name" dense>
                                            <v-list-item-content class="pa-0">
                                                <v-list-item-title>{{ data.item.name }}</v-list-item-title>
                                            </v-list-item-content>
                                        </v-list-item>
                                    </v-list-item-content>
                                </template>
                            </v-autocomplete>

                        </v-col>
                        <v-col cols="2">
                            <searchbar @search="search" @change="query" hide-add></searchbar>
                        </v-col>
                    </v-row>
                </v-card-title>
                <v-card-text>
                    <v-row>
                        <v-col cols="12" lg="12" class="">
                            <v-data-table :headers="headers2" :items="projects" :items-per-page="10" class="elevation-1"
                                hide-default-footer>
                                <template v-slot:item="{ item, index }">
                                    <tr class="border-bottom-0">
                                        <td>{{ item.project_date.split('-')[0] }}</td>
                                        <td class="text-center">{{ (curPage - 1) * 10 + index + 1 }}</td>
                                        <td class="text-left">
                                            <b>{{
                                    item.customer_name.toUpperCase()
                                }}</b>
                                        </td>
                                        <td class="py-1">
                                            
                                                <div class="text-left primary--text pb-1">
                                                    {{
                                    item.timeline_name
                                }}
                                                </div>
                                            
                                            <v-progress-linear height="10" background-opacity="0.5" :dark="true"
                                                :value="item.percentage" class="text-right rounded-2"> ({{
                                item.timeline_sort }}/{{
                                item.timeline_cnt
                            }})</v-progress-linear>
                                        </td>
                                        <td class="text-center"> <b class="font-weight-medium primary--text"
                                                v-if="item.project_delay > 0">
                                                Terlambat {{ item.project_delay }} hari</b>
                                            <b class="font-weight-medium primary--text"
                                                v-if="item.project_delay <= 0 && item.project_delay != null">
                                                On schedule <span v-show="item.project_delay < 0">&nbsp;({{
                                item.project_delay }}
                                                    hari)</span></b>
                                            <b class="font-weight-medium primary--text"
                                                v-if="item.project_delay == null">
                                                Belum ada Project </b>
                                        </td>
                                        <td class="text-center">
                                            {{ item.employee_name }}
                                        </td>
                                        <td class="text-left">
                                            {{ item.project_note }}
                                        </td>
                                        <td class="text-left">{{ formatDate(item.project_date) }}</td>
                                        <td class="text-center">
                                            <v-btn color="primary" dark icon>
                                                <v-icon>mdi-chevron-down</v-icon>
                                            </v-btn>
                                        </td>
                                    </tr>
                                </template>
                            </v-data-table>

                            <v-card-actions>
                                <v-pagination v-model="curPage" :length="totalPage" :total-visible="7"></v-pagination>
                            </v-card-actions>
                        </v-col>
                    </v-row>
                    <ddelete @todo="doDel"></ddelete>
                    <!-- <timeline></timeline> -->
                </v-card-text>
            </v-card>
        </v-col>
    </v-row>
</template>

<style scoped>
.row-progress-status {
    min-height: auto;
    height: auto !important;
}

tr.border-bottom-0>td {
    border-bottom: 0 !important;
}

h1,
h3,
h5,
.text-h4 {
	font-family: 'D-DIN' !important;
}
</style>

<script>
const t = "?t=" + Math.random();
const URL = window.location.protocol + "//" + window.location.host + (window.location.host.indexOf("sibambo") > -1 ? "/" : "/sibambo/");
module.exports = {
    components: {
        searchbar: httpVueLoader("../_common/search_bar.vue"),
        ddelete: httpVueLoader("../_common/delete_dialog.vue"),
        timeline: httpVueLoader("./project-timeline.vue" + t),
    },

    data() {
        return {
            info: { color: "", text: "" },
            notifications: false,
            selectedItem: 1,
            items: [
                { text: "Real-Time", icon: "mdi-clock" },
                { text: "Audience", icon: "mdi-account" },
                { text: "Conversions", icon: "mdi-flag" },
            ],
        };
    },

    computed: {
        flattenedItems() {
            let items = [];
            this.timeline_groups.forEach(group => {
                // Tambahkan nama grup
                items.push({ name: group.group_name, type: 'group' });
                // Tambahkan nama timeline
                group.timelines.forEach(timeline => {
                    items.push({ name: timeline.timeline_name, type: 'timeline' });
                });
            });
            return items;
        },
        __s() {
            return this.$store.state.project;
        },

        curPage: {
            get() {
                return this.__s.curPage;
            },
            set(v) {
                this.__c("curPage", v);
                this.__d("search");
            },
        },
        filter: {
            get() {
                return this.__s.search;
            },
            set(v) {
                this.__c("search", v);
                this.__d("search");
            },
        },

        ...Vuex.mapState({
            timeline_groups: (s) => s.project.timeline_groups,
            projects: (s) => s.project.projects,
            all_projects: (s) => s.project.all_projects,
            total: (s) => s.project.total,
            totalPage: (s) => s.project.totalPage,
            timelines: (s) => s.project.timelines,
        }),

        headers() {
            return (h = [
                {
                    text: "CUSTOMER",
                    align: "center",
                    sortable: false,
                    value: "",
                    class: "subtitle-1",
                    width: "100%",
                },
            ]);
        },

        headers2() {
            return (h = [
                {
                    text: "TAHUN",
                    align: "center",
                    sortable: false,
                    value: "",
                    class: "subtitle-1",
                    // width: "22%",
                },
                {
                    text: "NO",
                    align: "center",
                    sortable: false,
                    value: "",
                    class: "subtitle-1",
                    width: "5%",
                },
                {
                    text: "NAMA CLIENT",
                    align: "left",
                    sortable: false,
                    value: "",
                    class: "subtitle-1",
                    width: "15%",
                },
                {
                    text: "PROGRESS",
                    align: "left",
                    sortable: false,
                    value: "",
                    class: "subtitle-1",
                    width: "27%",
                },
                {
                    text: "STATUS",
                    align: "center",
                    sortable: false,
                    value: "",
                    class: "subtitle-1",
                    width: "12%",
                },
                {
                    text: "PIC",
                    align: "center",
                    sortable: false,
                    value: "",
                    class: "subtitle-1",
                    width: "12%",
                },
                {
                    text: "KETERANGAN",
                    align: "left",
                    sortable: false,
                    value: "",
                    class: "subtitle-1",
                    width: "15%",
                },
                {
                    text: "TIMESTAMP",
                    align: "left",
                    sortable: false,
                    value: "",
                    class: "subtitle-1",
                    width: "30%",
                },
                // {
                // 	text: "STATUS",
                // 	align: "center",
                // 	sortable: false,
                // 	value: "",
                // 	class: "subtitle-1",
                // 	width: "21%",
                // },
                {
                    text: "",
                    align: "center",
                    sortable: false,
                    value: "",
                    class: "subtitle-1",
                    width: "10%",
                },
            ]);
        },
        selectedProject: {
            get() {
                return this.__s.selectedProject;
            },
            set(v) {
                this.__c("selectedProject", v);
            },
        },
    },

    methods: {
        __c(a, b) {
            return this.$store.commit("project/SET_OBJECT", [a, b]);
        },
        __d(a) {
            return this.$store.dispatch("project/" + a);
        },
        del(x) {
            this.selected(x);
            this.$store.commit("misc/SET_OBJECT", ["dialogDelete", true]);
        },


        doDel() {
            this.$store.dispatch("project/delete").then((d) => {
                this.$store.commit("misc/SET_OBJECT", ["dialogDelete", false]);
                this.notifications = true;
                if (d.status === "ERR") {
                    this.info = {
                        text: "Projek Gagal dihapus",
                        color: "pink",
                    };
                } else {
                    this.info = {
                        text: "Projek Berhasil dihapus",
                        color: "primary",
                    };
                    if (this.projectNumber) {
                        var url = URL + "pages/project/main/";
                        window.location.assign(url);
                    }
                    this.__d("search");
                }
                this.search();
            });
            this.search();
        },

        search() {
            this.__d("search");
        },

        // query : {
        //     get () { return this.__s.search },
        //     set (v) { this.__c("search", v) }
        // },

        query(v) {
            this.__c("search", v);
            this.search();
        },

        refresh() {
            this.$store.dispatch("project/search");
        },
        getMonthName(monthIndex) {
            const months = [
                'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
            ];
            return months[monthIndex];
        },

        // Fungsi untuk format tanggal
        formatDate(dateString) {
            const [year, month, day] = dateString.split('-').map(Number);
            return `${day} ${this.getMonthName(month - 1)} ${year}`;
        }
    },

    updated() {
    },

};
</script>
