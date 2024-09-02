<?php

class Menu extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('system/s_menu');
        $this->load->helper('url');
    }

    function index()
    {
        return;
    }

    function search_group()
    {
        $r = $this->s_menu->search_group($this->sys_user['group_id']);
        foreach ($r as $k => $v) {
            $r[$k]['url'] = preg_replace("/(\_api\/)/", "pages", base_url()) . $v['url'];

            if ($v['subItems'] != null)
                foreach ($v['subItems'] as $l => $w) {
                    $v['subItems'][$l]->url = preg_replace("/(\_api\/)/", "pages", base_url()) . $w->url;
                }
            $r[$k]['subItems'] = $v['subItems'];
            $r[$k]['x'] = $_SERVER['SERVER_ADDR'];
        }

        $this->sys_ok($r);
    }
    function search_all()
    {
        $r = $this->s_menu->search_group(1);
        foreach ($r as $k => $v) {
            $r[$k]['url'] = preg_replace("/(\_api\/)/", "pages", base_url()) . $v['url'];

            if ($v['subItems'] != null)
                foreach ($v['subItems'] as $l => $w) {
                    $v['subItems'][$l]->url = preg_replace("/(\_api\/)/", "pages", base_url()) . $w->url;
                }
            $r[$k]['subItems'] = $v['subItems'];
            $r[$k]['x'] = $_SERVER['SERVER_ADDR'];
        }

        $this->sys_ok($r);
    }

    function search_all_id()
    {
        $r = $this->s_menu->search_all_id();

        $this->sys_ok($r);
    }
}
