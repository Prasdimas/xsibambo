import { URL, ajaxPost } from "../../assets/js/global.js"

export async function search(prm) {
    return ajaxPost(URL + 'master/customer/search', prm)
}

export async function search_province(prm) {
    return ajaxPost(URL + 'master/province/search', prm)
}

export async function search_city(prm) {
    return ajaxPost(URL + 'master/city/search', prm)
}

export async function search_district(prm) {
    return ajaxPost(URL + 'master/district/search', prm)
}

export async function search_village(prm) {
    return ajaxPost(URL + 'master/kelurahan/search', prm)
}

export async function search_customer_level(prm) {
    return ajaxPost(URL + 'master/customerlevel/search', prm)
}

export async function save(prm) {
    return ajaxPost(URL + 'master/customer/save', prm)
}

export async function del(prm) {
    return ajaxPost(URL + 'master/customer/del', prm)
}

export async function revoke_user(prm) {
    return ajaxPost(URL + 'master/customer/revoke_user', prm)
}

export async function grant_user(prm) {
    return ajaxPost(URL + 'master/customer/grant_user', prm)
}

export async function search_mp(prm) {
    return ajaxPost(URL + 'master/mp/search', prm)
}