<?php

class M_Division extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_division";
        $this->table_key = "M_DivisionID";
    }

    function search( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_DivisionID division_id, IFNULL(M_DivisionCode, '') division_code, M_DivisionName division_name, M_DivisionNote division_note
                FROM `{$this->table_name}`
                WHERE `M_DivisionName` LIKE ?
                AND `M_DivisionIsActive` = 'Y'
                ORDER BY M_DivisionCode asc
                LIMIT {$limit} OFFSET {$offset}", [$d['search']]);
        if ($r)
        {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_DivisionName` LIKE ?
            AND `M_DivisionIsActive` = 'Y'", [$d['search']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }
            
        return $l;
    }

    function save ( $d, $id = 0)
    {
        $this->db->set('M_DivisionName', $d['division_name'])
                    ->set('M_DivisionNote', $d['division_note']);
    
        if ($id != 0) {
            $r = $this->db->where('M_DivisionID', $id)
                    ->update( $this->table_name );
        }
    
        else {
            $r = $this->db->insert( $this->table_name );
            $id = $this->db->insert_id();
        }

        if ($r)
            return (object) ["status"=>"OK", "data"=>['division_id'=>$id], "query"=>$this->db->last_query()];
        return (object) ["status"=>"ERR"];
    }
    function del ($id)
    {
        $this->db->set('M_DivisionIsActive', 'N')
            ->where('M_DivisionID', $this->sys_input['id'])
            ->update($this->table_name);
        return true;
    }
}

?>