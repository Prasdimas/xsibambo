<template>
	<v-app-bar id="app-bar" absolute app color="transparent" flat height="75">
		<!-- Toggle Drawer Button -->
		<v-btn class="mr-3" elevation="1" fab small @click="setDrawer(!drawer)">
			<v-icon v-if="value">mdi-view-quilt</v-icon>
			<v-icon v-else>mdi-dots-vertical</v-icon>
		</v-btn>

		<!-- Breadcrumbs -->
		<v-toolbar-title class="hidden-sm-and-down font-weight-light">
			<v-breadcrumbs class="pl-0" :items="breadcrumbs" divider="/" />
		</v-toolbar-title>

		<v-spacer></v-spacer>

		<!-- Bell Icon with Notifications -->
		<v-menu bottom left offset-y origin="top right" transition="scale-transition">
			<template v-slot:activator="{ attrs, on }">
				<v-btn class="ml-2" min-width="0" text v-bind="attrs" v-on="on">
					<v-badge color="red" overlap>
						<template v-slot:badge>
							<span>{{ notifications.length }}</span>
						</template>
						<v-icon>mdi-bell</v-icon>
					</v-badge>
				</v-btn>
			</template>

			<v-list :tile="false" nav>
				<v-list-item v-for="(notification, index) in notifications" :key="index">
					<v-list-item-title>{{ notification.text }}</v-list-item-title>
				</v-list-item>
			</v-list>
		</v-menu>

		<!-- User Menu -->
		<v-menu bottom right offset-y origin="top right" transition="scale-transition">
			<template v-slot:activator="{ on }">
				<v-btn icon v-on="on">
					<v-avatar size="32">
						<!-- Replace with user avatar or default user icon -->
						<v-icon color="black">mdi-account</v-icon>
					</v-avatar>
				</v-btn>
			</template>

			<v-list>
				<v-list-item @click="Profile">
					<v-list-item-icon>
						<v-icon color="primary">mdi-account-circle</v-icon>
					</v-list-item-icon>
					<v-list-item-content>
						<v-list-item-title>Profile</v-list-item-title>
					</v-list-item-content>
				</v-list-item>
				<v-list-item @click="logout">
					<v-list-item-icon>
						<v-icon color="pink">mdi-logout</v-icon>
					</v-list-item-icon>
					<v-list-item-content>
						<v-list-item-title>Logout</v-list-item-title>
					</v-list-item-content>
				</v-list-item>
			</v-list>
		</v-menu>
	</v-app-bar>
</template>

<script>
module.exports = {
	name: "DashboardCoreAppBar",

	props: {
		breadcrumb: {
			type: Array,
			default: () => [],
		},
		value: {
			type: Boolean,
			default: false,
		},
	},

	data() {
		return {
			drawer: false,
			notifications: [
				{ text: "Mike John responded to your email" },
				{ text: "You have 5 new tasks" },
				{ text: "You're now friends with Andrew" },
				{ text: "Another Notification" },
				{ text: "Another one" },
			],
		};
	},

	computed: {
		breadcrumbs() {
			return this.breadcrumb.map((bc) =>
				typeof bc === "object" ? bc : { text: bc, disabled: true, href: "#" }
			);
		},
	},

	methods: {
		setDrawer(value) {
			this.drawer = value;
		},
		logout() {
			this.$store.dispatch('app/postme', {
				url: "systm/user/logout",
              	prm: {},
				callback: function(d) {
					localStorage.removeItem("siBamboToken")
					localStorage.removeItem("siBamboUser")
	
					location.reload()
					return true
				},
	
				failback: function(e) {
					console.log('ERROR LOGOUT')
				},
			})

			

			// axios.post("systm/user/logout", {})
			// 	.then(response => {
			// 		localStorage.removeItem("token")
			// 		localStorage.removeItem("user")
	
			// 		return true
			// 	})
			// 	.catch(error => callback(error));
		},
		Profile() {
			console.log("Profile clicked");
		},
	},
};
</script>
