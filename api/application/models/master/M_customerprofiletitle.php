<?php

class M_Customerprofiletitle extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_customerprofiletitle";
        $this->table_key = "M_CustomerProfileTitleID";
    }

    function search( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_CustomerProfileTitleID title_id, 
                    M_CustomerProfileTitleLabel title_label
                FROM `{$this->table_name}`
                WHERE `M_CustomerProfileTitleLabel` LIKE ?
                AND `M_CustomerProfileTitleIsActive` = 'Y'
                ORDER BY M_CustomerProfileTitleLabel asc
                LIMIT {$limit} OFFSET {$offset}", [$d['search']]);
        if ($r)
        {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_CustomerProfileTitleLabel` LIKE ?
            AND `M_CustomerProfileTitleIsActive` = 'Y'", [$d['search']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }
            
        return $l;
    }

    // function save ( $d, $id = 0)
    // {
    //     $this->db->set('M_CustomerProfileTitleName', $d['title_name'])
    //                 ->set('M_CustomerProfileTitleNote', $d['title_note']);
    
    //     if ($id != 0) {
    //         $r = $this->db->where('M_CustomerProfileTitleID', $id)
    //                 ->update( $this->table_name );
    //     }
    
    //     else {
    //         $r = $this->db->insert( $this->table_name );
    //         $id = $this->db->insert_id();
    //     }

    //     if ($r)
    //         return (object) ["status"=>"OK", "data"=>['title_id'=>$id], "query"=>$this->db->last_query()];
    //     return (object) ["status"=>"ERR"];
    // }
    // function del ($id)
    // {
    //     $this->db->set('M_CustomerProfileTitleIsActive', 'N')
    //         ->where('M_CustomerProfileTitleID', $this->sys_input['id'])
    //         ->update($this->table_name);
    //     return true;
    // }
}

?>