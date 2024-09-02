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
        $r = $this->m_vendor->search(['vendor_name'=>'%'.$this->sys_input['search'].'%', 
            'page'=>$this->sys_input['page'],
            'city'=>isset($this->sys_input['city'])?$this->sys_input['city']:0,
            'province'=>isset($this->sys_input['province'])?$this->sys_input['province']:0]);

        // FORMAT PHONES
        $records = $r['records'];
        // foreach ($records as $k => $v)
        // {
        //     foreach ($v['addresses'] as $l => $w)
        //     {
        //         $pxs = [];
        //         $phones = json_decode($w->address_phones);
        //         foreach ($phones as $p => $z)
        //             $pxs[] = $this->phone_format($z->no);

        //         $records[$k]['addresses'][$l]->address_phone = join(", ", $pxs);
        //     }
        // }

        $r['records'] = $records;
        $this->sys_ok($r);
    }

    function search_old()
    {
        $r = $this->m_vendor->search(['vendor_name'=>$this->sys_input['search'].'%', 'page'=>$this->sys_input['page']]);
        $this->sys_ok($r);
    }

    function search_dd()
    {
        $r = $this->m_vendor->search(['vendor_name'=>'%', 'limit'=>99999, 'page'=>1,'city'=>0,'province'=>0]);
        $this->sys_ok($r);
    }

    function save()
    {
        $this->sys_input['user_id'] = $this->sys_user['user_id'];
        if (isset($this->sys_input['customer_id']))
            $r = $this->m_vendor->edit( $this->sys_input );
        else
            $r = $this->m_vendor->save( $this->sys_input );

        echo json_encode($r);
    }

    function save_old()
    {
        $this->sys_input['user_id'] = $this->sys_user['user_id'];
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