<?php

class Employee extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->helper(array('form', 'url', 'file'));
        $this->load->model('master/m_employee');
    }

    function search()
    {
        $r = $this->m_employee->search([
            'search' => '%' . $this->sys_input['search'] . '%',
            'limit' => 10,
            'page' => $this->sys_input['page'],
            'division' => isset($this->sys_input['division']) ? $this->sys_input['division'] : ""
        ]);
        $this->sys_ok($r);
    }

    function search_dd()
    {
        $r = $this->m_employee->search([
            'search' => '%' . $this->sys_input['search'] . '%',
            'limit' => 99999,
            'page' => 1,
            'division' => isset($this->sys_input['division']) ? $this->sys_input['division'] : ""
        ]);
        $this->sys_ok($r);
    }



    // function search_dd()
    // {
    //     $r = $this->m_employee->search([
    //         'search' => '%' . $this->sys_input['search'] . '%',
    //         'limit' => 99999,
    //         'page' => 1
    //     ]);

    //     $div = '';
    //     $rst = [];
    //     foreach ($r['records'] as $k => $v) {
    //         if ($div != $v['division_name']) {
    //             $div = $v['division_name'];
    //             $rst[] = ['group' => $v['division_name']];
    //         }

    //         $rst[] = $v;
    //     }

    //     $this->sys_ok($rst);
    // }

    public function upload_file()
    {
        $response = array();

        $config['upload_path'] = '../assets/uploads/';
        $config['allowed_types'] = 'jpg|png|jpeg';
        $config['max_size'] = 2000;
        $config['max_width'] = 1920;
        $config['max_height'] = 1080;

        $this->upload->initialize($config);

        if (!$this->upload->do_upload('userfile')) {
            $response['status'] = 'error';
            $response['error'] = $this->upload->display_errors();
        } else {
            $upload_data = $this->upload->data();

            $response['file_name'] = $upload_data['file_name'];
            // $response['file_url'] = base_url('uploads/' . $upload_data['file_name']);
        }

        $this->output
            ->set_content_type('application/json')
            ->set_output(json_encode($response));
    }

    public function list_files()
    {
        $folder_path = '../assets/uploads/';
        $files = get_filenames($folder_path);

        // Mengembalikan daftar file dalam format JSON
        $this->output
            ->set_content_type('application/json')
            ->set_output(json_encode($files));
    }
    function search_files()
    {
        $r = $this->m_employee->list_files($this->sys_input['search']);

        $this->sys_ok($r);
    }
    function save()
    {
        if (isset($this->sys_input['employee_id']))
            $r = $this->m_employee->save($this->sys_input, $this->sys_input['employee_id']);
        else
            $r = $this->m_employee->save($this->sys_input);

        if ($r->status == "OK")
            $this->sys_ok($r->data);
        else
            $this->sys_error($r->message);
    }

    function del()
    {
        $r = $this->m_employee->del($this->sys_input['id']);
        $this->sys_ok($r);
    }
}
