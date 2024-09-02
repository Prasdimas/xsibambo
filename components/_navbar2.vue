<template>

	<v-navigation-drawer app v-model="drawer" :mini-variant.sync="mini" :dark="true">
		<!-- <template v-slot:img="props">
      <v-img
        :gradient="`to bottom, ${barColor}`"
        v-bind="props"
      ></v-img>
    </template> -->
		<v-divider class="mb-0"></v-divider>
		<v-list dense nav>
			<v-list-item class="white rounded-3">
				<!-- <v-list-item-avatar
          class="align-self-center"
          color="white"
          contain
        >
          <v-img
            src="https://uploads-ssl.webflow.com/64d331c45cab998e118c8cc8/64d906180fd150d77f23abfe_logo%20sibambo%20studio-04.webp"
            max-height="30"></v-img>
        </v-list-item-avatar> -->

				<v-list-item-content>
					<img src="../../../assets/img/logo-sibambo-small.png"
						style="max-height: 35px; object-fit: contain;" />
					<!-- <v-img
            src="../../../assets/img/logo-sibambo.png"
            max-height="35"></v-img> -->
				</v-list-item-content>
			</v-list-item>
		</v-list>
		<v-divider class="mb-2"></v-divider>

		<v-list>
			<template v-for="(m, n) in menuItems">
				<v-list-item link v-if="!m.subItems" @click="goTo(m.url)">
					<v-list-item-icon>
						<v-icon>{{ m.icon }}</v-icon>
					</v-list-item-icon>
					<v-list-item-title v-text="m.title"></v-list-item-title>
				</v-list-item>

				<v-list-group :prepend-icon="m.icon" :value="false" no-action v-else>
					<template v-slot:activator>
						<v-list-item-title>{{ m.title }}</v-list-item-title>
					</template>

					<v-list-item link v-for="(mm, nn) in m.subItems" :key="'sub-' + nn" @click="goTo(mm.url)">
						<v-list-item-title v-text="mm.title"></v-list-item-title>
						<v-list-item-icon>
							<v-icon>{{ m.icon }}</v-icon>
						</v-list-item-icon>
					</v-list-item>

					<!-- <v-list-group sub-group no-action>
            <template v-slot:activator>
              <v-list-item-content>
                <v-list-item-title>Become a Branch</v-list-item-title>
              </v-list-item-content>
            </template>
            <v-list-item v-for="(becomeBranch, i) in becomeBranchs" :key="i" @click="">
              <v-list-item-title v-text="becomeBranch[0]"></v-list-item-title>
              <v-list-item-action>
                <v-icon v-text="becomeBranch[1]"></v-icon>
              </v-list-item-action>
            </v-list-item>
          </v-list-group> -->
				</v-list-group>
			</template>



		</v-list>

		<!-- <v-list>
      <v-list-group prepend-icon="account_circle" value="true">
        <template v-slot:activator>
          <v-list-item-title>Join UsX X</v-list-item-title>
        </template>

        <v-list-group no-action sub-group value="true" append-icon="add">

          <template v-slot:activator>

            <v-list-item-content>
              <v-icon class="custom-prepend-icon">mdi-magnify</v-icon>
              <v-list-item-title>Become a Loan Officer</v-list-item-title>
            </v-list-item-content>
          </template>

          <v-list-item v-for="(becomeLO, i) in becomeLOs" :key="i" link>
            <v-list-item-title v-text="becomeLO[0]"></v-list-item-title>
            <v-list-item-icon>
              <v-icon v-text="becomeLO[1]"></v-icon>
            </v-list-item-icon>
          </v-list-item>
        </v-list-group>

        <v-list-group sub-group no-action>
          <template v-slot:activator>
            <v-list-item-content>
              <v-list-item-title>Become a Branch</v-list-item-title>
            </v-list-item-content>
          </template>
          <v-list-item v-for="(becomeBranch, i) in becomeBranchs" :key="i" @click="">
            <v-list-item-title v-text="becomeBranch[0]"></v-list-item-title>
            <v-list-item-action>
              <v-icon v-text="becomeBranch[1]"></v-icon>
            </v-list-item-action>
          </v-list-item>
        </v-list-group>
      </v-list-group>

      <v-list-group sub-group no-action>
        <template v-slot:activator>
          <v-list-item-content>
            <v-list-item-title>Become a Partner</v-list-item-title>
          </v-list-item-content>
        </template>
        <v-list-item v-for="(becomePartner, i) in becomePartners" :key="i" @click="">
          <v-list-item-title v-text="becomePartner[0]"></v-list-item-title>
          <v-list-item-action>
            <v-icon v-text="becomePartner[1]"></v-icon>
          </v-list-item-action>
        </v-list-item>
      </v-list-group>
    </v-list> -->
	</v-navigation-drawer>
</template>

<script>
module.exports = {
	name: 'SalesForm',
	components: {

	},
	data: function () {
		return {
			drawer: true,
			mini: false,
			items: [
				{ text: 'Home' },
				{
					text: 'Nested Menu',
					children: [
						{ text: 'Item 1' },
						{ text: 'Item 2' }
					],
					showSubMenu: false
				},
				{ text: 'About' },
				{ text: 'Contact' }
			],
			becomeLOs: [
				['Benefits', 'people_outline'],
				['Get Started', 'settings'],
			],
			becomeBranchs: [
				['Benefits', 'people_outline'],
				['Get Started', 'settings'],
			],
			becomePartners: [
				['Benefits', 'people_outline'],
				['Get Started', 'settings'],
			],
			careers: [
				['Benefits', 'people_outline'],
				['Get Started', 'settings'],
			],
			barColor: 'rgba(0, 0, 0, .8), rgba(0, 0, 0, .8)',
			barImage: 'https://demos.creative-tim.com/material-dashboard/assets/img/sidebar-1.jpg'
		}
	},

	computed: {
		profile() {
			return {
				avatar: true,
				title: 'SIBAMBO'//this.$t('avatar'),
			}
		},

		menuItems: {
			get() { return this.$store.state.app.menus },
			set(v) { this.$store.commit("app/set_object", ["menus", v]) }
		}
	},

	methods: {
		toggleSubMenu(index) {
			this.$set(this.items, index, {
				...this.items[index],
				showSubMenu: !this.items[index].showSubMenu
			});
		},

		goTo(x) {
			window.location.href = x
		}
	},

	mounted() {
		if (!this.$store.state.app.USER_TOKEN)
			window.location = this.$store.state.app.URL + 'pages/user/login'

		this.$store.dispatch("app/searchMenuGroup").then(m => {
			if (m.status == "ERR") {
				localStorage.removeItem("siBamboToken")
				localStorage.removeItem("siBamboUser")

				// location.reload()
				window.location = this.$store.state.app.URL + 'pages/user/login'
				return false
			}

			this.menuItems = m
		})
	}
}