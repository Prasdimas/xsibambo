<template>
    <v-container fluid>
        <v-row>
            <v-snackbar
                v-model="notifications"
                :timeout="4000"
                top
                :color="info.color"
            >
                <h4>{{ info.text }}</h4>
                <template v-slot:action="{ attrs }">
                    <v-btn
                        text
                        dark
                        v-bind="attrs"
                        @click="notifications = false"
                    >
                        Close
                    </v-btn>
                </template>
            </v-snackbar>

            <v-col cols="12">
                <v-card class="pa-3">
                    <v-card-title class="py-2">
                        User Group Administrator
                        <v-spacer></v-spacer>
                        <v-btn class="primary rounded-3" @click="save">
                            Simpan
                        </v-btn>
                    </v-card-title>
                    <v-card class="ma-2 pa-2">
                        <v-row style="border: 1px solid black">
                            <v-col cols="12" md="3" lg="2">
                                <v-tabs v-model="tab" vertical>
                                    <v-tab
                                        v-for="(item, index) in groups"
                                        :key="index"
                                        outlined
                                        style="
                                            border: 0.5px solid black;
                                            justify-content: left;
                                        "
                                        v-model="tab"
                                        class="text-capitalize"
                                    >
                                        {{ item.group_name }}
                                    </v-tab>
                                </v-tabs>

                                <v-btn
                                    outlined
                                    block
                                    color="primary"
                                    class="mt-2 text-capitalize"
                                >
                                    Tambah Grup Baru
                                </v-btn>
                            </v-col>

                            <v-col cols="12" md="9" lg="9">
                                <!-- <v-tabs-items v-model="tab">
                <v-tab-item v-for="(item, index) in items" :key="index">
                  <v-card flat>
                    <v-card-text>
                      <h3>{{ item.title }}</h3>
                      <p>{{ item.content }}</p>
                    </v-card-text>
                  </v-card>
                </v-tab-item>
              </v-tabs-items>     -->
                                <v-row dense>
                                    <v-col cols="12" md="6" lg="6">
                                        <v-list flat subheader>
                                            <v-subheader>
                                                <span
                                                    class="black--text title"
                                                    v-if="menus.length > 1"
                                                    >{{ menus[1].title }}</span
                                                >
                                            </v-subheader>

                                            <v-list-item-group multiple>
                                                <v-list-item
                                                    v-for="item in menus[1]
                                                        ?.subItems || []"
                                                    :key="item.id"
                                                    style="margin-top: -20px"
                                                >
                                                    <template>
                                                        <v-list-item-action>
                                                            <v-checkbox
                                                                v-model="
                                                                    selectedMenus
                                                                "
                                                                :value="item.id"
                                                            ></v-checkbox>
                                                        </v-list-item-action>
                                                        <v-list-item-content>
                                                            <v-list-item-title
                                                                >{{
                                                                    item.title
                                                                }}</v-list-item-title
                                                            >
                                                        </v-list-item-content>
                                                    </template>
                                                </v-list-item>
                                            </v-list-item-group>
                                        </v-list>

                                        <v-list flat subheader>
                                            <v-subheader>
                                                <span
                                                    class="black--text title"
                                                    v-if="menus.length > 1"
                                                    >{{ menus[3].title }}</span
                                                >
                                            </v-subheader>

                                            <v-list-item-group multiple>
                                                <v-list-item
                                                    v-for="item in menus[3]
                                                        ?.subItems || []"
                                                    :key="item.id"
                                                    style="margin-top: -20px"
                                                >
                                                    <template>
                                                        <v-list-item-action>
                                                            <v-checkbox
                                                                v-model="
                                                                    selectedMenus
                                                                "
                                                                :value="item.id"
                                                            ></v-checkbox>
                                                        </v-list-item-action>
                                                        <v-list-item-content>
                                                            <v-list-item-title
                                                                >{{
                                                                    item.title
                                                                }}</v-list-item-title
                                                            >
                                                        </v-list-item-content>
                                                    </template>
                                                </v-list-item>
                                            </v-list-item-group>
                                        </v-list>
                                    </v-col>
                                    <v-col cols="12" md="6" lg="6">
                                        <v-list flat subheader>
                                            <v-subheader>
                                                <span
                                                    class="black--text title"
                                                    v-if="menus.length > 1"
                                                    >{{ menus[2].title }}</span
                                                >
                                            </v-subheader>

                                            <v-list-item-group multiple>
                                                <v-list-item
                                                    v-for="item in menus[2]
                                                        ?.subItems || []"
                                                    :key="item.id"
                                                    style="margin-top: -20px"
                                                >
                                                    <template>
                                                        <v-list-item-action>
                                                            <v-checkbox
                                                                v-model="
                                                                    selectedMenus
                                                                "
                                                                :value="item.id"
                                                            ></v-checkbox>
                                                        </v-list-item-action>
                                                        <v-list-item-content>
                                                            <v-list-item-title
                                                                >{{
                                                                    item.title
                                                                }}</v-list-item-title
                                                            >
                                                        </v-list-item-content>
                                                    </template>
                                                </v-list-item>
                                            </v-list-item-group>
                                        </v-list>
                                    </v-col>
                                </v-row>
                            </v-col>
                        </v-row>
                    </v-card>
                </v-card>
            </v-col>
        </v-row>
    </v-container>
</template>

<script>
module.exports = {
    data() {
        return {
            notifications: false,
            info: { text: "", color: "" },
            menu1: [],
            menu2: [],
            menu3: [],
            selectedItems: [],
            tab: 0,
            items: [
                { title: "Admin", content: "Content for Tab 1" },
                { title: "Manajer", content: "Content for Tab 2" },
                { title: "Staff", content: "Content for Tab 3" },
            ],
            items1: [
                { id: 1, text: "Menu 1.1" },
                { id: 2, text: "Menu 1.2" },
                { id: 3, text: "Menu 1.3" },
                { id: 4, text: "Menu 1.4" },
            ],
            items2: [
                { id: 1, text: "Menu 2.1" },
                { id: 2, text: "Menu 2.2" },
                { id: 3, text: "Menu 2.3" },
                { id: 4, text: "Menu 2.4" },
            ],
            items3: [
                { id: 1, text: "Menu 3.1" },
                { id: 2, text: "Menu 3.2" },
                { id: 3, text: "Menu 3.3" },
                { id: 4, text: "Menu 3.4" },
            ],
        };
    },
    computed: {
        menus() {
            return this.$store.state.masterGroup.menus;
        },
        groups() {
            return this.$store.state.masterGroup.groups;
        },
        selectedMenus: {
            get() {
                return this.$store.state.masterGroup.selectedMenus;
            },
            set(v) {
                this.__c("selectedMenus", v);
            },
        },
        reportPrivilege: {
            get() {
                return this.$store.state.masterGroup.reportPrivilege;
            },
            set(v) {
                this.__c("reportPrivilege", v);
            },
        },
    },
    methods: {
        __c(a, b) {
            return this.$store.commit("masterGroup/SET_OBJECT", [a, b]);
        },
        __d(a) {
            return this.$store.dispatch("masterGroup/" + a);
        },

        save() {
            this.__d("save").then((x) => {
                this.notifications = true;
                if (x.status === "ERR") {
                    this.info = {
                        text: "Menu Gagal ditambahkan",
                        color: "pink",
                    };
                } else {
                    this.info = {
                        text: "Menu Berhasil ditambahkan",
                        color: "cyan",
                    };
                    // this.__d("searchall");
                    this.$store
                        .dispatch("masterGroup/search")
                        .then(() => {
                            this.handleTabChange();
                        })
                        .catch((error) => {
                            console.error("Error while searching:", error);
                        });
                }
            });
        },
        handleTabChange() {
            this.__c("selectedMenus", [1, ...this.groups[this.tab].privilege]);
            this.__c("groupId", this.groups[this.tab].group_id);
            this.__c("reportPrivilege", this.groups[this.tab].report_privilege);
        },
    },
    watch: {
        tab() {
            this.handleTabChange();
        },
    },
    mounted() {
        this.$store
            .dispatch("masterGroup/search")
            .then(() => {
                this.handleTabChange();
            })
            .catch((error) => {
                console.error("Error while searching:", error);
            });
    },
};
</script>

<style scoped>
/* CSS styling for active tab */
.v-tabs--vertical .v-tabs__item.v-tabs__item--active {
    background-color: #f0f0f0;
}
</style>
