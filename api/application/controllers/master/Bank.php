<?php

class Bank extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('master/M_bank');
    }

    function search()
    {
        $r = $this->M_bank->search([
            'search' => '%' . $this->sys_input['search'] . '%',
            'limit' => 10,
            'page' => $this->sys_input['page']
        ]);
        $this->sys_ok($r);
    }

    function search_dd()
    {
        $r = $this->M_bank->search([
            'search' => '%' . $this->sys_input['search'] . '%',
            'limit' => 99999,
            'page' => 1
        ]);
        $this->sys_ok($r);
    }

    function save()
    {
        // $this->sys_input['user_id'] = $this->sys_user['user_id'];
        if (isset($this->sys_input['bank_id']))
            $r = $this->M_bank->save($this->sys_input, $this->sys_input['bank_id']);
        else
            $r = $this->M_bank->save($this->sys_input);

        if ($r->status == "OK")
            $this->sys_ok($r->data);
        else
            $this->sys_error('ERROR');
    }

    function del()
    {
        $r = $this->M_bank->del($this->sys_input);
        $this->sys_ok($r);
    }
}
