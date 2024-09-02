<?php

class System extends MY_Controller
{
    public $pattern;

    function __construct()
    {
        parent::__construct();

        $this->load->model('system/s_system');
    }

    function index()
    {
        return;
    }

    function get_default()
    {
        $r = $this->s_system->get_default();
        $this->sys_ok($r);
    }

    function save()
    {
        $r = $this->s_system->save($this->sys_input);
        $this->sys_ok($r);
    }
}

?>