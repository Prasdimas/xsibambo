<?php

class S_system extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = 's_system';
        $this->primary_key = 'S_SystemID';
    }

    function get_default()
    {
        $r = $this->db->where('S_SystemIsActive', 'Y')
                    ->limit(1)
                    ->get($this->table_name)
                    ->row();
        return $r;
    }

    function save($d)
    {
        $r = $this->db->set('S_SystemCompanyName', $d['company_name'])
                        ->set('S_SystemCompanyAddress', $d['company_address'])
                        ->set('S_SystemCompanyPhone', $d['company_phone'])
                        ->set('S_SystemCompanyM_ProvinceID', $d['province_id'])
                        ->set('S_SystemCompanyM_CityID', $d['city_id'])
                        ->set('S_SystemCompanyM_DistrictID', $d['district_id'])
                        ->set('S_SystemCompanyM_KelurahanID', $d['kelurahan_id'])
                        ->set('S_SystemTargetWeekly', $d['target_weekly'])
                        ->set('S_SystemPaymentExpired', $d['payment_expired'])
                        ->update($this->table_name);
        return $r;
    }
}
?>
