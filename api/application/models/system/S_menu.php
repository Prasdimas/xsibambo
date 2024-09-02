<?php

class S_menu extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = 's_menu';
        $this->primary_key = 'S_MenuID';
    }

    // function get_all()
    // {
    //     $r = $this->GetMultipleQueryResult("CALL `s_menu_all`()", 2);
    //     $r[0] = $this->rearrange($r[0]);
    //     $r[1] = $this->reicon($r[1]);

    //     return $r;
    // }

    function search_group($gid)
    {
        $r = $this->db->query("CALL `sp_system_menu_group_2`(?)", [$gid])->result_array();
        $this->clean_mysqli_connection($this->db->conn_id);

        foreach ($r as $k => $v) {
            $r[$k]['subItems'] = json_decode($v['subItems']);
        }

        return $r;
    }

    function search_group_old($gid)
    {
        $r = $this->GetMultipleQueryResult("CALL `sp_system_menu_group_2`('{$gid}')", 2);
        if (!isset($r[0]))
            return false;

        $r[0] = $this->rearrange($r[0]);
        $r[1] = $this->reicon($r[1]);

        return $r;
    }

    function search_all($gid)
    {
        $r = $this->db->query("CALL `sp_system_menu_group_2`(?)", [$gid])->result_array();
        $this->clean_mysqli_connection($this->db->conn_id);

        foreach ($r as $k => $v) {
            $r[$k]['subItems'] = json_decode($v['subItems']);
        }

        return $r;
    }

    function search_all_id()
    {
        $r = $this->GetMultipleQueryResult("CALL `sp_system_menu_all_id`()", 2);
        if (!isset($r[0]))
            return false;

        $r[0] = $this->rearrange($r[0]);
        $r[1] = $this->reicon($r[1]);

        return $r;
    }

    function rearrange($menu)
    {
        if (!$menu)
            return false;

        if (!is_array($menu))
            return false;

        $tmp = array();
        foreach ($menu as $k => $v) {
            if ($v['parent'] == '')
                $tmp[$v['label']] = $v['url'];
            else {
                $prn = (array) json_decode($v['parent']);

                if (sizeof($prn) == 1) {
                    if (!isset($tmp[$prn[0]]))
                        $tmp[$prn[0]] = array();

                    $tmp[$prn[0]][$v['label']] = $v['url'];
                } else {
                    if (!isset($tmp[$prn[0]]))
                        $tmp[$prn[0]] = array();

                    if (!isset($tmp[$prn[0]][$prn[1]]))
                        $tmp[$prn[0]][$prn[1]] = array();

                    $tmp[$prn[0]][$prn[1]][$v['label']] = $v['url'];
                }
            }
        }

        return $tmp;
    }

    function reicon($icons)
    {
        if (!$icons)
            return false;

        if (!is_array($icons))
            return false;

        $a = array();
        foreach ($icons as $k => $v) {
            $a[$v['label']] = $v['icon'];
        }

        return $a;
    }
}
