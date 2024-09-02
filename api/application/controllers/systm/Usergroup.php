<?php

class Usergroup extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('system/s_usergroup');
    }

    function index()
    {
        http_response_code(404);
        die();
    }

    function search()
    {
        $r = $this->s_usergroup->search(['search' => '%']);
        $this->sys_ok($r);
    }

    function save()
    {
        $d = $this->sys_input;
        $r = $this->s_usergroup->save($this->sys_input);

        if ($r->status == "OK")
            $this->sys_ok($r->data);
        else
            $this->sys_error($r->message);
    }
}
