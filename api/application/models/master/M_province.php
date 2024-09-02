<?php

class M_Province extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_province";
        $this->table_key = "M_ProvinceID";
    }

    function search( $d )
    {
        $r = $this->db->query("
                SELECT 
                    M_ProvinceID as province_id,
                    M_ProvinceName as province_name,
                    M_ProvinceCode as province_code,
                    M_ProvinceIsDefault as province_is_default,
                    M_ProvinceROID as province_roid,
                    M_ProvinceIsActive as province_is_active
                FROM `{$this->table_name}`
                ORDER BY M_ProvinceName asc 
        ");
        if ($r)
        {
            $l['records'] = $r->result_array();
        }
        return $l;
    }

}

?>