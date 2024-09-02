<?php

class Conf extends MY_Controller
{
    public $pattern;

    function __construct()
    {
        parent::__construct();

        $this->load->model('app/app_conf');
    }

    function index()
    {
        return;
    }

    function get_conf()
    {
        $r = $this->app_conf->get(isset($this->sys_input['key'])?$this->sys_input['key']:'');
        $this->sys_ok($r);
    }

    function save()
    {
        $r = $this->app_conf->save($this->sys_input);

        $this->sys_ok($r);
    }
}

?>