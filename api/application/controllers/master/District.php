<?php

class District extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('master/m_district');
    }

    function index()
    {
        return;
    }

    function search()
    {
        $r = $this->m_district->search(['district_name'=>'%', 'city_id'=>$this->sys_input['city_id']]);
        $this->sys_ok($r);
    }
}

?>