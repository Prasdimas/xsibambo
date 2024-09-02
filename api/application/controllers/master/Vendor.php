<?php

class Vendor extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('master/m_vendor');
    }

    function search()
    {
        $r = $this->m_vendor->search([
            'search'=>'%'.$this->sys_input['search'].'%', 
            'limit'=>10, 
            'page'=>$this->sys_input['page']]);
        $this->sys_ok($r);
    }

    function search_dd()
    {
        $r = $this->m_vendor->search([
            'search'=>'%'.$this->sys_input['search'].'%', 
            'limit'=>99999, 
            'page'=>1]);
        $this->sys_ok($r);
    }

    function save()
    {
        if (isset($this->sys_input['vendor_id']))
            $r = $this->m_vendor->save( $this->sys_input, $this->sys_input['vendor_id'] );
        else
            $r = $this->m_vendor->save( $this->sys_input );
        
        if ($r->status == "OK")
            $this->sys_ok($r->data);
        else
            $this->sys_error('ERROR');
    }

    function del()
    {
        $r = $this->m_vendor->del( $this->sys_input );
        $this->sys_ok($r);
    }
}

?>