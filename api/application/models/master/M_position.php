<?php

class M_Position extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_position";
        $this->table_key = "M_PositionID";
    }

    function search( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_PositionID position_id, IFNULL(M_PositionCode, '') position_code, M_PositionName position_name, M_PositionNote position_note
                FROM `{$this->table_name}`
                WHERE `M_PositionName` LIKE ?
                AND `M_PositionIsActive` = 'Y'
                ORDER BY M_PositionCode asc
                LIMIT {$limit} OFFSET {$offset}", [$d['search']]);
        if ($r)
        {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_PositionName` LIKE ?
            AND `M_PositionIsActive` = 'Y'", [$d['search']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }
            
        return $l;
    }

    function save ( $d, $id = 0)
    {
        $this->db->set('M_PositionName', $d['position_name'])
                    ->set('M_PositionNote', $d['position_note']);
    
        if ($id != 0) {
            $r = $this->db->where('M_PositionID', $id)
                    ->update( $this->table_name );
        }
    
        else {
            $r = $this->db->insert( $this->table_name );
            $id = $this->db->insert_id();
        }

        if ($r)
            return (object) ["status"=>"OK", "data"=>['position_id'=>$id], "query"=>$this->db->last_query()];
        return (object) ["status"=>"ERR"];
    }
    function del ($id)
    {
        $this->db->set('M_PositionIsActive', 'N')
            ->where('M_PositionID', $this->sys_input['id'])
            ->update($this->table_name);
        return true;
    }
}

?>