<?php

class M_kelurahan extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_kelurahan";
        $this->table_key = "M_KelurahanID";
    }

    function search( $d )
    {
        $l = ['records'=>[], 'total'=>0];

        $r = $this->db->query(
                "SELECT M_KelurahanID village_id, M_KelurahanName village_name
                FROM `{$this->table_name}`
                WHERE `M_KelurahanName` LIKE ? ANd M_KelurahanM_DistrictID = ?
                AND `M_KelurahanIsActive` = 'Y'", [$d['kelurahan_name'], $d['district_id']]);
        if ($r)
        {
            $r = $r->result_array();
            $l['records'] = $r;
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_KelurahanName` LIKE ? ANd M_KelurahanM_DistrictID = ?
            AND `M_KelurahanIsActive` = 'Y'", [$d['kelurahan_name'], $d['district_id']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
        }
            
        return $l;
    }
}

?>