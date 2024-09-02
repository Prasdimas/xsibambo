<?php

class Kelurahan extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('master/m_kelurahan');
    }

    function index()
    {
        return;
    }

    function search()
    {
        $r = $this->m_kelurahan->search(['kelurahan_name'=>'%', 'district_id'=>$this->sys_input['district_id']]);
        $this->sys_ok($r);
    }
}

?>