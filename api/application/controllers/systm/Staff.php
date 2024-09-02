<?php

class Staff extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('system/s_staff');
    }

    function search()
    {
        $d = ['search'=>'%'.$this->sys_input['search'].'%', 
            'page'=>$this->sys_input['page']
            ];
        if (isset($this->sys_input['position']))
            $d['position'] = $this->sys_input['position'];
        
            $r = $this->s_staff->search( $d );
        $this->sys_ok($r);
    }

    function search_autocomplete()
    {
        $r = $this->s_staff->search_autocomplete(['search'=>'%'.$this->sys_input['search'].'%']);
        $this->sys_ok($r);
    }

    function save()
    {
        $this->sys_input['user_id'] = $this->sys_user['user_id'];
        if (isset($this->sys_input['staff_id']))
            $r = $this->s_staff->save( $this->sys_input, $this->sys_input['staff_id'] );
        else
            $r = $this->s_staff->save( $this->sys_input );
        
        if ($r->status == "OK")
            $this->sys_ok($r->data);
        else
            $this->sys_error($r->message);
    }
}

?>