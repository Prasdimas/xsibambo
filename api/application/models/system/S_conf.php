<?php

class S_conf extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = 's_conf';
        $this->primary_key = 'S_ConfID';
    }

    function get_conf($key = "")
    {
        $r = $this->db->query("SELECT fn_conf(?) as conf", $key)
                    ->row();

        if ($key == "")
            $r->conf = json_decode($r->conf);

        return $r->conf;
    }

    function save($v)
    {
        $pre_conf = 'S_Conf';
        $conf = [];

        if (isset($v['company_name']))
            $conf[$pre_conf.'CompanyName'] = $v['company_name'];

        if (isset($v['ppn']))
            $conf[$pre_conf.'PPN'] = $v['ppn'];
        
        $this->db->where('S_ConfIsActive', 'Y')
                ->set($conf)
                ->update($this->table_name);

        return true;
    }
}
?>
