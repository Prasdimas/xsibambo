<?php

class D extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('dashboard/d_dashboard2');
    }

    function admin()
    {
        $d = [];
        // leave datas
        $this->load->model('trans/t_leave');
        $d['leaves'] = $this->t_leave->search_who_leave( date('Y-m-d') );

        $this->sys_ok($d);
    }
}