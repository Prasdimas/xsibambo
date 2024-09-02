<template>
  <v-navigation-drawer
    id="core-navigation-drawer"
    v-model="drawer"
    :dark="barColor !== 'rgba(228, 226, 226, 1), rgba(255, 255, 255, 0.7)'"
    :expand-on-hover="expandOnHover"
    :right="$vuetify.rtl"
    :src="barImage"
    mobile-breakpoint="960"
    app
    width="260"
    v-bind="$attrs"
  >
    <!-- <template v-slot:img="props">
      <v-img
        :gradient="`to bottom, ${barColor}`"
        v-bind="props"
      />
    </template> -->
    <v-divider class="mb-1"></v-divider>
    <v-list
      dense
      nav
    >
      <v-list-item>
        <v-list-item-avatar
          class="align-self-center"
          color="white"
          contain
        >
          <v-img
            src="https://demos.creative-tim.com/vuetify-material-dashboard/favicon.ico"
            max-height="30"></v-img>
        </v-list-item-avatar>

        <v-list-item-content>
          <v-list-item-title
            class="display-1"
            v-text="profile.title"></v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-list>

    <v-divider class="mb-2"></v-divider>
    <v-list
      expand
      nav
    >
      <!-- Style cascading bug  -->
      <!-- https://github.com/vuetifyjs/vuetify/pull/8574 -->
      <!-- <div /> -->

      <template v-for="(item, i) in computedItems">
        <base-item-group
          v-if="item.children"
          :key="`group-${i}`"
          :item="item"
        >{{ item.title }}</base-item-group>
          <!--  -->

        <base-item v-else
          :key="`item-${i}`"
          :item="item"></base-item>
      </template>

      <!-- Style cascading bug  -->
      <!-- https://github.com/vuetifyjs/vuetify/pull/8574 -->
      <!-- <div /> -->
    </v-list>

    <template v-slot:append>
      <base-item
        :item="{
          title: '',//$t('upgrade'),
          icon: 'mdi-package-up',
          to: '/upgrade',
        }"
      ></base-item>
    </template>
  </v-navigation-drawer>
</template>

<style>
#core-navigation-drawer .v-list-group__header.v-list-item--active:before{opacity:.24}#core-navigation-drawer .v-list-item__icon--text,#core-navigation-drawer .v-list-item__icon:first-child{justify-content:center;text-align:center;width:20px;width-margin-right:24px;width-margin-left:12px !important}#core-navigation-drawer .v-list--dense .v-list-item__icon--text,#core-navigation-drawer .v-list--dense .v-list-item__icon:first-child{margin-top:10px}#core-navigation-drawer .v-list-group--sub-group .v-list-item{padding-left:8px}#core-navigation-drawer .v-list-group--sub-group .v-list-group__header{padding-right:0}#core-navigation-drawer .v-list-group--sub-group .v-list-item__icon--text{margin-top:19px;order:0}#core-navigation-drawer .v-list-group--sub-group .v-list-group__header__prepend-icon{order:2;order-margin-right:8px}
</style>

<script>

// Utilities

module.exports = {
    name: 'drawer',

    props: {
      expandOnHover: {
        type: Boolean,
        default: false,
      },
    },

    components : {
      'base-item': httpVueLoader('./Item.vue'),
      'base-item-group': httpVueLoader('./ItemGroup.vue'),
    },

    data: () => ({
      items: [
        {
          icon: 'mdi-view-dashboard',
          title: 'dashboard',
          to: '/',
        },
        {
          icon: 'mdi-account',
          title: 'user',
          to: '/pages/user',
        },
        {
          title: 'rtables',
          icon: 'mdi-clipboard-outline',
          to: '/tables/regular-tables',
        },
        {
          title: 'typography',
          icon: 'mdi-format-font',
          to: '/components/typography',
        },
        {
          title: 'icons',
          icon: 'mdi-chart-bubble',
          to: '/components/icons',
        },
        {
          title: 'google',
          icon: 'mdi-map-marker',
          to: '/maps/google-maps',
        },
        {
          title: 'notifications',
          icon: 'mdi-bell',
          to: '/components/notifications',
        },
      ],
      barColor: 'rgba(0, 0, 0, .8), rgba(0, 0, 0, .8)',
      barImage: 'https://demos.creative-tim.com/material-dashboard/assets/img/sidebar-1.jpg'
    }),

    computed: {
      // ...mapState(['barColor', 'barImage']),
      drawer: {
        get () {
          return this.$store.state.app.drawer
        },
        set (val) {
          this.$store.commit('app/SET_DRAWER', val)
        },
      },
      computedItems () {
        return this.items.map(this.mapItem)
      },
      profile () {
        return {
          avatar: true,
          title: 'SIKONS'//this.$t('avatar'),
        }
      },
    },

    methods: {
      mapItem (item) {
        return {
          ...item,
          children: item.children ? item.children.map(this.mapItem) : undefined,
          title: item.title,
        }
      },
    },

    mounted () {
      console.log(this.computedItems)
    }
  }
</script>


