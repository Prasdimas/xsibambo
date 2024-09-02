<?php

class S_usergroup extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "s_usergroup";
        $this->table_key = "S_UserGroupID";
    }

    function search($d)
    {
        $l = ['records' => [], 'total' => 0];
        if (!isset($d['uid']))
            $d['uid'] = 0;

        $r = $this->db->query(
            "SELECT S_UserGroupID group_id, S_UserGroupCode group_code, 
                    S_UserGroupName group_name, S_UserGroupDashboard group_dashboard,
                    IF (S_UserGroupCode = 'Z.GROUP.01', false, true) editable
                FROM `{$this->table_name}`
                WHERE (`S_UserGroupName` LIKE ?)
                AND `S_UserGroupIsActive` = 'Y'
                ORDER BY S_UserGroupCode",
            [$d['search']]
        );
        if ($r) {
            $r = $r->result_array();
            foreach ($r as $k => $v) {
                $x = $this->db->query("SELECT fn_system_privilege(?) x", [$v['group_id']])->row();
                $x = json_decode($x->x);
                $r[$k]['privilege'] = $x->menus;
                $r[$k]['report_privilege'] = $x->reports;
            }
            $l['records'] = $r;
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
                WHERE (`S_UserGroupName` LIKE ?)
                AND `S_UserGroupIsActive` = 'Y'",
            [$d['search']]
        );
        if ($r) {
            $l['total'] = $r->row()->n;
        }

        return $l;
    }

    function get_by_code($code)
    {
        $r = $this->db->where('S_UserGroupCode', $code)
            ->where('S_UserGroupIsACtive', 'Y')
            ->get($this->table_name)
            ->row();
        return $r;
    }
    function save($d)
    {
        $r = $this->db->query("CALL sp_system_privilege_save(?, ?, ?)", [$d['group_id'], json_encode($d['privileges']), json_encode($d['report_privileges'])])
            ->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        return $r;
    }
}
