<template>
    <v-row>
        <v-col cols="12">
            <v-card class="pa-5">
                <v-row>
  <!-- Timeline Info -->
  <v-col lg="3" md="3" sm="6" cols="12">
    <!-- Gambar Card 1 -->
    <v-card class="pa-3" :height="$vuetify.breakpoint.smAndDown ? 200 : 150">
      <v-row  style="margin-top: -10px;">
        <v-col cols="4">
          <v-img
            src="../../../assets/img/pattern/project-icon.png"
            alt=""
            class="rounded-pill"
            max-width="60"
            max-height="60"
          />
        </v-col>
        <v-col cols="8">
          <h1 class="text-sm-h5 text-lg-h5 ">{{ totalProject }}</h1>
          <p class="text-sm-h6 subtitle-1">
            Project
          </p>
        </v-col>
      </v-row>
      <v-row style="margin-top: -35px;">
        <v-col cols="4">
          <v-img
            src="../../../assets/img/pattern/customer-icon.png"
            alt=""
            class="rounded-pill"
            max-width="60"
            max-height="60"
          />
        </v-col>
        <v-col cols="8">
  <h1 class="text-sm-h5 text-lg-h5">{{ totalCustomers }}</h1>
  <p class="text-sm-h6 subtitle-1">
    Customer
  </p>
</v-col>
      </v-row>
    </v-card>
  </v-col>
  <!-- Gambar Card 2 -->
  <v-col lg="3" md="3" sm="6" cols="12" v-for="item in timeline_groups" :key="item.M_TimelineGroupID">
    <v-card class="pa-3" height="150"> 
      <v-row class="mt-1">
        <v-col cols="4">
          <v-img
            src="../../../assets/img/pattern/project-icon.png"
            alt=""
            class="rounded-pill"
            max-width="150"
            max-height="150"
          />
        </v-col>
        <v-col cols="8" class="mt-3">
          <h1 class="text-sm-h5 text-lg-h4">{{ item.jumlah_project }}</h1>
          <p class="text-sm-subtitle-1 body-1">
            {{ item.timelinegroup_name }}
          </p>
        </v-col>
      </v-row>
    </v-card>
  </v-col>
</v-row>
  <v-row>
        <v-col lg="2" md="3" sm="6" cols="12" v-for="item in projects" :key="item.project_number"> 
      <v-card :height="330" :class="backgroundColor[Math.floor(Math.random() * 10)]"> 
        <v-card-title  :class="backgroundColor[Math.floor(Math.random() * 10)]" class="white--text pa-3">
          <v-row no-gutters>
            <v-col cols="12"  class="text-center">
                {{ item.customer_name }}
                <h3 class="body-2">
                    {{ item.project_number }}
                </h3>
            </v-col>
          </v-row>
        </v-card-title>
        <v-container :class="subColor[Math.floor(Math.random() * 5)]"  style="height: 150px;">
  <v-row class="pa-1">
    <v-col cols="12"  class="text-center">
        <v-progress-circular
            class="body-2"
                :rotate="360"
                :width="20"
                :size="75"
                :value="item.percentage"
                color="primary"
              >
                {{ item.percentage }}%
              </v-progress-circular>

    </v-col>
    <v-col cols="12" class="text-center body-1">
        <div>{{ item.timeline_name }}</div>
      </v-col>
  </v-row>
</v-container>
<v-card-title>
          <v-row no-gutters>
            <v-col cols="12"  class="body-2 white--text">
                <div>
                    Tanggal Mulai :
                    <strong>
                        {{ item.project_date }}
                    </strong>
                </div>
                <div>
                    Tanggal Target :
                    <strong>
                        {{ item.project_target_date }}
                    </strong>
                </div>
                <div>

                        <v-tooltip bottom>
                        <template v-slot:activator="{ on, attrs }">
                            <span v-bind="attrs" v-on="on" class="text-truncate" style="max-width: 150px;">
                                Nama PIC :   <strong>{{ item.employee_name.length > 15 ? item.employee_name.substr(0, 15) + '...' : item.employee_name }}</strong>
                            </span>
                        </template>
                        <span> Nama PIC :  <strong>{{ item.employee_name }}</strong></span>
                        </v-tooltip>
                    </div>
            </v-col>
          </v-row>
        </v-card-title>
      </v-card>
    </v-col>
             </v-row>    
            </v-card>
        </v-col>
    </v-row>
</template>
<style scoped>
.v-list-item {
    min-height: 0px;
    font-size:10px;
}

.timeline-info {
  padding-right: 120px;
}

.group-timeline-chart {
  display: flex;
  align-items: center;

}
</style>
<script>
module.exports = {
    data() {
    return {
      dialog: false,
            backgroundColor: [
            "light-blue darken-4",
            "cyan darken-1",
            "primary",
            "purple darken-2",
            "teal darken-3",
            "deep-orange darken-4",
            "light-blue darken-4",
            "primary",
            "light-blue darken-4",
            "teal darken-4"
          ],
          subColor:[
            "blue-grey lighten-4",
            "deep-orange lighten-4",
            "light-blue lighten-4",
            "cyan lighten-4",
            "teal lighten-4"
          ]
    };
  },
  computed: {
    __s() {
            return this.$store.state.project;
        },
    ...Vuex.mapState({
        timeline_groups: (s) => s.project.timeline_groups,
        projects: (s) => s.project.projects,
        totalProject: (s) => s.project.total_count,
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
  },
  methods: {
        __c(a, b) {
            return this.$store.commit("project/SET_OBJECT", [a, b]);
        },
        __d(a) {
            return this.$store.dispatch("project/" + a);
        },
    },
}