<?php

class ContactDetail extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('master/m_contactdetail');
    }

    function search()
    {
        $r = $this->m_contactdetail->search([
            'search'=>'%'.$this->sys_input['search'].'%', 
            'limit'=>10, 
            'page'=>$this->sys_input['page']]);
        $this->sys_ok($r);
    }

    function search_dd()
    {
        $r = $this->m_contactdetail->search([
            'search'=>'%'.$this->sys_input['search'].'%', 
            'limit'=>99999, 
            'page'=>1]);
        $this->sys_ok($r);
    }

    function save()
    {
        if (isset($this->sys_input['contactdetail_id']))
            $r = $this->m_contactdetail->save( $this->sys_input, $this->sys_input['contactdetail_id'] );
        else
            $r = $this->m_contactdetail->save( $this->sys_input );
        
        if ($r->status == "OK")
            $this->sys_ok($r->data);
        else
            $this->sys_error('ERROR');
    }

    function del()
    {
        $r = $this->m_contactdetail->del( $this->sys_input );
        $this->sys_ok($r);
    }
}

?>