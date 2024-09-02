<?php

class M_workday extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_workday";
        $this->table_key = "M_WorkdayID";
    }

    function search( $d, $scalar = false )
    {
        $limit = 10;
        $offset = 0;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_WorkDayID workday_id, M_WorkDayM_DayID workday_day, M_WorkDayStartTime workday_starttime,	M_WorkDayEndTime workday_endtime
                FROM `{$this->table_name}`
                LEFT JOIN m_day ON M_WorkDayM_DayID = M_DayID
                WHERE `M_WorkDayIsActive` = 'Y'
                ORDER BY M_WorkDayM_DayID asc
                LIMIT {$limit} OFFSET {$offset}", []);
        if ($r)
        {
            $l['records'] = $r->result_array();
        }

        // count by type
        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) cnt
                FROM `{$this->table_name}`
                LEFT JOIN m_day ON M_WorkDayM_DayID = M_DayID
            WHERE M_WorkdayIsActive = 'Y'", []);

        // count all
        $l['total'] = $r->row()->cnt;
        $l['total_page'] = ceil($l['total'] / $limit);
            
        if ($scalar)
        {
            $workdays = [];
            foreach ($l['records'] as $k => $v) $workdays[] = $v['workday_day'];
            return $workdays;
        }

        return $l;
    }
}

?>