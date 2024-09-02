<?php

class Project extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('project/p_project');
        $this->load->helper('url');
    }

    function index()
    {
        return;
    }

    function search()
    {
        $r = $this->p_project->search(
            [
                'search' => '%' . $this->sys_input['search'] . '%',
                'page' => isset($this->sys_input['page']) ? $this->sys_input['page'] : 1,
                'limit' => isset($this->sys_input['limit']) ? $this->sys_input['limit'] : 10,
                'user' => $this->sys_user['group_code'] == 'ONE.GROUP.SA' ? ['user_id'=>0] : $this->sys_user
                // 'city'=>isset($this->sys_input['city'])?$this->sys_input['city']:0,
                // 'province'=>isset($this->sys_input['province'])?$this->sys_input['province']:0,
                // 'type'=>isset($this->sys_input['type'])?$this->sys_input['type']:''
            ]
        );

        // FORMAT PHONES
        $records = $r['records'];
        foreach ($records as $k => $v) {
            // foreach ($v['addresses'] as $l => $w)
            // {
            //     $pxs = [];
            //     $phones = json_decode($w->address_phones);
            //     foreach ($phones as $p => $z)
            //         $pxs[] = $this->phone_format($z->no);

            //     $records[$k]['addresses'][$l]->address_phone = join(", ", $pxs);
            // }
        }

        $r['records'] = $records;
        $this->sys_ok($r);
    }


    function search_one()
    {
        $r = $this->p_project->search([
            'search' => '%', 'limit' => 1, 'page' => 1
        ], $this->sys_input['project_id']);

        $r = $r['records'][0];
        $this->sys_ok($r);
    }
    function countbyGroup()
    {
        $r = $this->p_project->countByGroup($this->sys_input['timeline_groupID']);
        $this->sys_ok($r);
    }

    function count()
    {
        $r = $this->p_project->count(
            [
                'search' => '%' . $this->sys_input['search'] . '%',
                'page' => isset($this->sys_input['page']) ? $this->sys_input['page'] : 1,
                'limit' => isset($this->sys_input['limit']) ? $this->sys_input['limit'] : 10
                // 'city'=>isset($this->sys_input['city'])?$this->sys_input['city']:0,
                // 'province'=>isset($this->sys_input['province'])?$this->sys_input['province']:0,
                // 'type'=>isset($this->sys_input['type'])?$this->sys_input['type']:''
            ]
        );

        // FORMAT PHONES
        $records = $r['records'];
        foreach ($records as $k => $v) {
            // foreach ($v['addresses'] as $l => $w)
            // {
            //     $pxs = [];
            //     $phones = json_decode($w->address_phones);
            //     foreach ($phones as $p => $z)
            //         $pxs[] = $this->phone_format($z->no);

            //     $records[$k]['addresses'][$l]->address_phone = join(", ", $pxs);
            // }
        }

        $r['records'] = $records;
        $this->sys_ok($r);
    }

    function save()
    {
        $this->sys_input['uid'] = $this->sys_user['user_id'];
        if (isset($this->sys_input['project_id']))
            $r = $this->p_project->save($this->sys_input, $this->sys_input['project_id']);
        else
            $r = $this->p_project->save($this->sys_input);

        if ($r->status == "OK")
            // $this->sys_ok(json_decode($r->data));
            $this->sys_ok($r->q);
        else
            $this->sys_error($r->message);
    }
    function del()
    {
        $r = $this->p_project->del($this->sys_input);
        $this->sys_ok($r);
    }
}
