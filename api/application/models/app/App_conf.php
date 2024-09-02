<?php

class App_conf extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = 'app_conf';
        $this->primary_key = 'App_ConfID';
    }

    function get($key = "", $array = false)
    {
        $r = $this->db->query("SELECT App_ConfMd5 conf_md5, App_ConfName conf_name, App_ConfValue conf_value
            FROM app_conf WHERE App_ConfCode = ? AND App_ConfIsActive = 'Y'", $key);
        
        if ($r->num_rows() > 0)
        {
            if (!$array)
            {
                $r = $r->row();
                if ($this->isJson($r->conf_value)) $r->conf_value = json_decode($r->conf_value);
            }
                
            else
            {
                $r = $r->result_array();
                foreach ($r as $k => $v)
                    if ($this->isJson($v['conf_value'])) $r[$k]['conf_value'] = json_decode($v['conf_value']);
            }

            return $r;
        }
        
        return false;
    }

    // function save($v)
    // {
    //     $pre_conf = 'S_Conf';
    //     $conf = [];

    //     if (isset($v['company_name']))
    //         $conf[$pre_conf.'CompanyName'] = $v['company_name'];

    //     if (isset($v['ppn']))
    //         $conf[$pre_conf.'PPN'] = $v['ppn'];
        
    //     $this->db->where('S_ConfIsActive', 'Y')
    //             ->set($conf)
    //             ->update($this->table_name);

    //     return true;
    // }

    function isJson($string) {
        json_decode($string);
        return (json_last_error() == JSON_ERROR_NONE);
    }
}
?>
