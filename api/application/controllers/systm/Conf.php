<?php

class Conf extends MY_Controller
{
    public $pattern;

    function __construct()
    {
        parent::__construct();

        $this->load->model('system/s_conf');
    }

    function index()
    {
        return;
    }

    function get_conf()
    {
        $r = $this->s_conf->get_conf(isset($this->sys_input['key'])?$this->sys_input['key']:'');
        $this->sys_ok($r);
    }

    function save()
    {
        $r = $this->s_conf->save($this->sys_input);

        $this->sys_ok($r);
    }
}

?>