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
        $r = $this->m_customer->search(['customer_name'=>'%'.$this->sys_input['search'].'%', 
            'page'=>$this->sys_input['page'],
            'city'=>isset($this->sys_input['city'])?$this->sys_input['city']:0,
            'province'=>isset($this->sys_input['province'])?$this->sys_input['province']:0,
            'type'=>isset($this->sys_input['type'])?$this->sys_input['type']:'']);

        // FORMAT PHONES
        $records = $r['records'];
        foreach ($records as $k => $v)
        {
            foreach ($v['addresses'] as $l => $w)
            {
                $pxs = [];
                $phones = json_decode($w->address_phones);
                foreach ($phones as $p => $z)
                    $pxs[] = $this->phone_format($z->no);

                $records[$k]['addresses'][$l]->address_phone = join(", ", $pxs);
            }
        }

        $r['records'] = $records;
        $this->sys_ok($r);
    }

    function search_dd()
    {
        $r = $this->m_customer->search([
            'customer_name'=>'%'.(isset($this->sys_input['search'])?$this->sys_input['search']:'').'%', 
            'limit'=>99999, 
            'page'=>1, 'city'=>0, 'province'=>0, 'type'=>'']);
        $this->sys_ok($r);
    }

    function save()
    {
        $this->sys_input['user_id'] = $this->sys_user['user_id'];
        if (isset($this->sys_input['customer_id']))
            $r = $this->m_customer->edit( $this->sys_input );
        else
            $r = $this->m_customer->save( $this->sys_input );

        echo json_encode($r);
    }

    function del()
    {
        $r = $this->m_customer->del( $this->sys_input['customer_id'], $this->sys_user['user_id'] );
        if ($r->status=='OK')
            $this->sys_ok(json_decode($r->data));
        else
            $this->sys_error($r->message);
    }

    function search_autocomplete()
    {
        $r = $this->m_customer->search_autocomplete(
            ['customer_name'=>'%'.$this->sys_input['customer_name'].'%', 
            'page'=>1,
            'city'=>0,
            'province'=>0,
            'type'=>'']);
        $this->sys_ok($r);
    }

    function set_index()
    {
        $this->m_customer->set_index( isset($this->sys_input['id']) ? $this->sys_input['id'] : 0 );
    }

    function search_similar()
    {
        $r = $this->m_customer->search_similar($this->sys_input['search']);
        $this->sys_ok($r);
    }

    function tmp_idx()
    {
        $this->m_customer->_tmp_idx();
    }
}

?>