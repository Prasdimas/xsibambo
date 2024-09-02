<?php

class M_Timeline extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_timeline";
        $this->table_key = "M_TimelineID";
    }

    function search( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_TimelineID timeline_id, IFNULL(M_TimelineCode, '') timeline_code, M_TimelineName timeline_name, 
                '' timeline_note, M_TimelineWeight timeline_weight, M_TimelineDuration timeline_duration,
                IFNULL( CONCAT('[', GROUP_CONCAT(M_TimelineAssignM_EmployeeID), ']'), '[]') as assignee
                FROM `{$this->table_name}`
                LEFT JOIN m_timelineassign ON M_TimelineAssignM_TimelineID = M_TimelineID AND M_TimelineAssignIsActive = 'Y'
                WHERE `M_TimelineName` LIKE ?
                AND `M_TimelineIsActive` = 'Y'
                GROUP BY M_TimelineID
                ORDER BY M_TimelineCode asc
                LIMIT {$limit} OFFSET {$offset}", [$d['search']]);
        if ($r)
        {
            $r = $r->result_array();
            foreach ($r as $k => $v)
            {
                $assignee = json_decode($v['assignee']);
                $r[$k]['assignee'] = array_map('strval', $assignee);
            }
            
            $l['records'] = $r;

            // get default total duration
            $this->load->model('app/app_conf');
            $x = $this->app_conf->get("TIMELINE.DURATION.TOTAL");
            $l['duration_total_default'] = $x->conf_value;
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_TimelineName` LIKE ?
            AND `M_TimelineIsActive` = 'Y'", [$d['search']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }
            
        return $l;
    }

    function search_assignee( $id = 0 )
    {
        $r = $this->db->query(
                "SELECT M_TimelineAssignID assign_id, M_TimelineAssignM_TimelineID timeline_id,
                    M_EmployeeID employee_id, M_EmployeeName employee_name
                FROM `m_timelineassign`
                JOIN m_employee ON M_TimelineAssignM_EmployeeID = M_EmployeeID
                    AND M_EmployeeIsActive = 'Y'
                WHERE `M_TimelineAssignM_TimelineID` = ?
                AND `M_TimelineAssignIsActive` = 'Y'", [$id])
                ->result_array();

        return $r;
    }

    function save($d, $id = 0)
    {
        $uid = $d['user_id'];
        $hdata = $d;
        unset($hdata['jdata']);

        $r = $this->db->query("CALL sp_master_timeline_save(?, ?, ?, ?)",[
                $id, json_encode($hdata), $d['jdata'], $uid])->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        return $r;
    }

    function savex ( $d, $id = 0)
    {
        $this->db->set('M_TimelineName', $d['timeline_name'])
                    ->set('M_TimelineNote', $d['timeline_note']);
    
        if ($id != 0) {
            $r = $this->db->where('M_TimelineID', $id)
                    ->update( $this->table_name );
        }
    
        else {
            $r = $this->db->insert( $this->table_name );
            $id = $this->db->insert_id();
        }

        if ($r)
            return (object) ["status"=>"OK", "data"=>$id, "query"=>$this->db->last_query()];
        return (object) ["status"=>"ERR"];
    }
    function del ($id)
    {
        $this->db->set('M_TimelineIsActive', 'N')
            ->where('M_TimelineID', $this->sys_input['id'])
            ->update($this->table_name);
        return true;
    }
}

?>