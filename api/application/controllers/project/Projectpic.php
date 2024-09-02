<?php

class ProjectPIC extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('project/p_projectpic');
    }
    function index()
    {
        http_response_code(404);
        die();
    }

    function search_pic()
    {
        // Ambil data dari input request
        $search_term = isset($this->sys_input['search']) ? $this->sys_input['search'] : '';
        $page = isset($this->sys_input['page']) ? intval($this->sys_input['page']) : 1;

        // Validasi input jika diperlukan
        if (empty($search_term)) {
            // Jika search_term kosong, bisa mengembalikan error atau nilai default
            $this->sys_ok(['records' => [], 'total' => 0, 'total_page' => 1]);
            return;
        }

        // Panggil fungsi search di model dengan parameter yang sesuai
        $result = $this->p_projectpic->search([
            'search' => $search_term,   // project_id atau keyword pencarian
            'limit' => 9999,              // Jumlah record per halaman
            'page' => $page             // Nomor halaman untuk paginasi
        ]);

        // Kirimkan hasil pencarian sebagai response
        $this->sys_ok($result);
    }



    // function search()
    // {
    //     $r = $this->p_projectpic->search([
    //         'search' => '%' . $this->sys_input['search'] . '%',
    //         'limit' => 10,
    //         'page' => $this->sys_input['page']
    //     ]);
    //     $this->sys_ok($r);
    // }

    function search_dd()
    {
        $r = $this->p_projectpic->search([
            'search' => '%' . $this->sys_input['search'] . '%',
            'limit' => 99999,
            'page' => 1
        ]);
        $this->sys_ok($r);
    }
}
