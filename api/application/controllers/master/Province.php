<?php

class Province extends MY_Controller
{
    function __construct()
    {
        parent::__construct();
        $this->load->model('master/m_province');
    }

    function search()
    {
        $r = $this->m_province->search([]);
        $this->sys_ok($r);
    }
}

?>