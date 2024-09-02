<?php

class Holiday extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('master/m_holiday');
    }

    function search()
    {
        $r = $this->m_holiday->search([
            'search'=>'%'.$this->sys_input['search'].'%', 
            'year'=>isset($this->sys_input['year'])?$this->sys_input['year']:date('Y'),
            'limit'=>10, 
            'page'=>$this->sys_input['page']]);
        $this->sys_ok($r);
    }

    function search_dd()
    {
        $r = $this->m_holiday->search([
            'search'=>'%'.$this->sys_input['search'].'%', 
            'limit'=>99999, 
            'page'=>1]);
        $this->sys_ok($r);
    }

    function count()
    {
        $r = $this->m_holiday->count(
            isset($this->sys_input['year'])?$this->sys_input['year']:date('Y'),
            isset($this->sys_input['type'])?$this->sys_input['type']:"",
            isset($this->sys_input['search'])?'%'.$this->sys_input['search'].'%':"");
        $this->sys_ok($r);
    }

    function save()
    {
        // $this->sys_input['user_id'] = $this->sys_user['user_id'];
        if (isset($this->sys_input['holiday_id']))
            $r = $this->m_holiday->save( $this->sys_input, $this->sys_input['holiday_id'] );
        else
            $r = $this->m_holiday->save( $this->sys_input );
        
        if ($r->status == "OK")
            $this->sys_ok($r->data);
        else
            $this->sys_error($r->message);
    }

    function del()
    {
        $r = $this->m_holiday->del( $this->sys_input );
        $this->sys_ok($r);
    }
}

?>