<?php

class Customer extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('master/m_customer');
    }

    function search()
    {
        $r = $this->m_customer->search([
            'search'=>'%'.$this->sys_input['search'].'%', 
            'limit'=>10, 
            'page'=>$this->sys_input['page']]);
        $this->sys_ok($r);
    }

    function search_dd()
    {
        $r = $this->m_customer->search([
            'search'=>'%'.$this->sys_input['search'].'%', 
            'limit'=>99999, 
            'page'=>1]);
        $this->sys_ok($r);
    }

    function search_one()
    {
        $r = $this->m_customer->search([
            'search'=>'%', 'limit'=>10, 'page'=>1, 'customer_id'=>$this->sys_input['customer_id']]);

        $x = $r['records'][0];
        $x['customer_age'] = $this->dateDiff($x['customer_join_date']);
        $x['customer_join_date_formatted'] = date('d M Y', strtotime($x['customer_join_date']));
        $this->sys_ok($x);
    }

    function save()
    {
        $this->sys_input['user_id'] = $this->sys_user['user_id'];
        if (isset($this->sys_input['customer_id']))
            $r = $this->m_customer->save( $this->sys_input, $this->sys_input['customer_id'] );
        else
            $r = $this->m_customer->save( $this->sys_input );
        
        if ($r->status == "OK")
            $this->sys_ok($r->data);
        else
            $this->sys_error('ERROR');
    }

    function del()
    {
        $r = $this->m_customer->del( $this->sys_input );
        $this->sys_ok($r);
    }
}

?>