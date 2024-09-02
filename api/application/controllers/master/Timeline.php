<?php

class Timeline extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('master/m_timeline');
    }

    function search()
    {
        $r = $this->m_timeline->search([
            'search'=>'%'.$this->sys_input['search'].'%', 
            'limit'=>isset($this->sys_input['limit'])?$this->sys_input['limit']:10, 
            'page'=>$this->sys_input['page']]);
        $this->sys_ok($r);
    }

    function search_dd()
    {
        $r = $this->m_timeline->search([
            'search'=>'%'.$this->sys_input['search'].'%', 
            'limit'=>99999, 
            'page'=>1]);

        $this->sys_ok($r);
    }

    function search_assignee()
    {
        $r = $this->m_timeline->search_assignee( $this->sys_input['timeline_id'] );

        $this->sys_ok($r);
    }

    function save()
    {
        $this->sys_input['user_id'] = $this->sys_user['user_id'];
        if (isset($this->sys_input['t_id']))
            $r = $this->m_timeline->save( $this->sys_input, $this->sys_input['t_id'] );
        else
            $r = $this->m_timeline->save( $this->sys_input );
        
        if ($r->status == "OK")
            $this->sys_ok($r->data);
        else
            $this->sys_error('ERROR');
    }

    function del()
    {
        $r = $this->m_timeline->del( $this->sys_input );
        $this->sys_ok($r);
    }
}

?>