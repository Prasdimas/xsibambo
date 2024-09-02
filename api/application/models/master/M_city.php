<?php

class M_city extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_city";
        $this->table_key = "M_CityID";
    }

    function search( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_CityID city_id, M_CityName city_name, 
                    M_ProvinceID province_id, M_ProvinceName province_name
                FROM `{$this->table_name}`
                JOIN m_province ON M_CityM_ProvinceID = M_ProvinceID
                WHERE (`M_CityName` LIKE ? OR M_ProvinceName LIKE ?)
                AND `M_CityIsActive` = 'Y' 
                AND ((M_CityM_ProvinceID = ? AND ? <> 0) OR ? = 0)
                ORDER BY M_CityName asc
                LIMIT {$limit} OFFSET {$offset}", [$d['search'], $d['search'], $d['province_id'], $d['province_id'], $d['province_id']]);
        if ($r)
        {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            JOIN m_province ON M_CityM_ProvinceID = M_ProvinceID
            WHERE (`M_CityName` LIKE ? OR M_ProvinceName LIKE ?)
            AND ((M_CityM_ProvinceID = ? AND ? <> 0) OR ? = 0)
            AND `M_CityIsActive` = 'Y'", [$d['search'], $d['search'], $d['province_id'], $d['province_id'], $d['province_id']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }
            
        return $l;
    }

    // function save ( $d, $id = 0)
    // {
    //     $this->db->set('M_CityName', $d['city_name'])
    //                 ->set('M_CityNote', $d['city_note']);
    
    //     if ($id != 0) {
    //         $r = $this->db->where('M_CityID', $id)
    //                 ->update( $this->table_name );
    //     }
    
    //     else {
    //         $r = $this->db->insert( $this->table_name );
    //         $id = $this->db->insert_id();
    //     }

    //     if ($r)
    //         return (object) ["status"=>"OK", "data"=>$id, "query"=>$this->db->last_query()];
    //     return (object) ["status"=>"ERR"];
    // }
}

?>