<?php

class M_district extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_district";
        $this->table_key = "M_DistrictID";
    }

    function search( $d )
    {
        $l = ['records'=>[], 'total'=>0];

        $r = $this->db->query(
                "SELECT M_DistrictID district_id, M_DistrictName district_name
                FROM `{$this->table_name}`
                WHERE `M_DistrictName` LIKE ? ANd M_DistrictM_CityID = ?
                AND `M_DistrictIsActive` = 'Y'", [$d['district_name'], $d['city_id']]);
        if ($r)
        {
            $r = $r->result_array();
            $l['records'] = $r;
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_DistrictName` LIKE ? ANd M_DistrictM_CityID = ?
            AND `M_DistrictIsActive` = 'Y'", [$d['district_name'], $d['city_id']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
        }
            
        return $l;
    }
}

?>