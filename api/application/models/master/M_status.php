<?php

class M_status extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_status";
        $this->table_key = "M_StatusID";
    }

    function search( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_StatusID status_id, M_StatusCode status_code, M_StatusName status_name, M_StatusText status_text,
                    IFNULL(M_StatusColor, '') status_color, IFNULL(M_StatusIcon, '') status_icon
                FROM `{$this->table_name}`
                WHERE `M_StatusName` LIKE ? AND M_StatusCode LIKE ?
                AND `M_StatusIsActive` = 'Y'
                ORDER BY M_StatusSort asc, M_StatusName asc
                LIMIT {$limit} OFFSET {$offset}", [$d['search'], $d['prefix']]);
        if ($r)
        {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_StatusName` LIKE ? AND M_StatusCode LIKE ?
            AND `M_StatusIsActive` = 'Y'", [$d['search'], $d['prefix']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }
            
        return $l;
    }
}

?>