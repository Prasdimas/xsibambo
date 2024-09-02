import { app } from "../../app.js?t=ewr";

export default {
	namespaced: true,
	state: {
		customers: [],
		total: 0,
		totalPage: 1,
		curPage: 1,
		selectedCustomer: null,

		provinces: [],
		selectedProvince: null,

		cities: [],
		selectedCity: null,

		// new
		customerId: 0,
		customerName: "",
		customerAddress: "",
		customerPhone: "",
		customerAge: "",
		customerNote: "",
		customerEmail: "",
		customerPostcode: "",
		customerPicName: "",
		customerPicPhone: "",
		customerNpwp: "",
		customerAuto: "N",
		customerMps: [],
		customerJoinDate: app.state.currentDate,
		customerProspect: "N",
		currentDate: app.state.currentDate,

		customerTypes: [
			{ id: "N", text: "Personal" },
			{ id: "Y", text: "Bisnis" },
		],
		selectedCustomerType: null,

		staffs: [],
		selectedStaff: null,

		phones: [],
		selectedPhone: null,
		templatePhone: { no: "", wa: "N" },

		banks: [],
		selectedBank: null,

		cbanks: [],
		selecedCbank: null,
		templateCbank: { bank: null, no: "", name: "" },

		snackbar: false,
		snackbar_text: "",

		profiles: [],
		selectedProfile: null,
		USER: JSON.parse(localStorage.getItem("siBamboUser")),
		profileDivisions: [],

		search: "",
		edit: false,
		dialog: false,
		dialogDelete: false,
	},
	mutations: {
		SET_OBJECT(state, v) {
			let name = v[0];
			let val = v[1];
			state[name] = val;
		},
		SET_OBJECTS(state, v) {
			let name = v[0];
			let val = v[1];
			for (let i = 0; i < name.length; i++) state[name[i]] = val[i];
		},
	},
	actions: {
		async search(context) {
			let prm = {
				search: context.state.search,
				page: context.state.curPage,
			};

			return context.dispatch(
				"postme",
				{
					url: "master/customer/search",
					prm: prm,
					callback: function (d) {
						context.commit("SET_OBJECTS", [
							["customers", "total", "totalPage"],
							[d.records, d.total, d.total_page],
						]);
						return d;
					},
				},
				{ root: true }
			);
		},

		async provinces(context) {
			return context.dispatch(
				"postme",
				{
					url: "master/province/search",
					prm: "",
					calback: function (d) {
						context.commit("SET_OBJECTS", [["provinces"], [d.records]]);
					},
				},
				{ root: true }
			);
		},

		async searchDd(context) {
			let prm = {
				search: context.state.search,
			};

			return context.dispatch(
				"postme",
				{
					url: "master/customer/search_dd",
					prm: prm,
					callback: function (d) {
						return d;
					},
				},
				{ root: true }
			);
		},

		async save(context) {
			let __s = context.state,
				__m = context.rootState.misc;

			// profiles
			let profiles = [];
			for (let p of context.rootState.masterProfile.profiles)
				if (!!p.label && !!p.desc) profiles.push(p);

			let prm = {
				customer_id: context.state.customerId,

				customer_name: context.state.customerName,
				customer_address: context.state.customerAddress,
				customer_city_id: __m.selectedCity.city_id,
				customer_district_id: __m.selectedDistrict
					? __m.selectedDistrict.district_id
					: 0,
				customer_kelurahan_id: __m.selectedVillage
					? __m.selectedVillage.village_id
					: 0,
				customer_postcode: __s.customerPostcode,
				customer_pic_name: __s.customerPicName,
				customer_pic_phone: __s.customerPicPhone,
				customer_npwp: __s.customerNpwp,
				customer_email: __s.customerEmail,
				customer_phone: context.state.customerPhone,
				customer_phones: JSON.stringify(__s.phones),
				customer_note: __s.customerNote,
				customer_type: __s.selectedCustomerType.id,

				customer_profiles: JSON.stringify(profiles),
			};
			if (!!__s.edit) prm.customer_id = __s.selectedCustomer.customer_id;

			return context.dispatch(
				"postme",
				{
					url: "master/customer/save",
					prm: prm,
					callback: function (d) {
						return d;
					},
				},
				{ root: true }
			);
		},

		async del(context) {
			let id = context.state.selectedCustomer.customer_id;
			return context.dispatch(
				"postme",
				{
					url: "master/customer/del",
					prm: { customer_id: id },
					callback: function (d) {
						return d;
					},
				},
				{ root: true }
			);
		},

		async searchOne(context) {
			let prm = { customer_id: context.state.customerId };

			return context.dispatch(
				"postme",
				{
					url: "master/customer/search_one",
					prm: prm,
					callback: function (d) {
						return d;
					},
				},
				{ root: true }
			);
		},
	},
};
