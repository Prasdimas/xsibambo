<?php

class M_week extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_week";
        $this->table_key = "M_WeekID";
    }

    function search( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_WeekID week_id, M_WeekStartDate week_sdate, M_WeekEndDate week_edate, M_WeekName week_name,
                    SELECT DATE_FORMAT(M_WeekStartDate, '%M') AS month_name;

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
}