<?php

class M_misc extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_misc";
        $this->table_key = "M_MiscID";
    }

    function search_dd($code)
    {
        $r = $this->db->select('M_MiscID misc_id, M_MiscCode misc_code, M_MiscKey misc_key, M_MiscValue misc_value, M_MiscName misc_name')
            ->where('M_MiscCode', $code)
            ->where('M_MiscIsActive', 'Y')
            ->get($this->table_name)
            ->result_array();

        if ($r) return $r;
        return [];
    }

    function get_by_key($code, $key)
    {
        $r = $this->db->select('M_MiscID misc_id, M_MiscValue misc_value')
            ->where('M_MiscCode', $code)
            ->where('M_MiscKey', $key)
            ->where('M_MiscIsActive', 'Y')
            ->limit(1)
            ->get($this->table_name)
            ->row();

        if ($r) return $r;
        return null;
    }

    function save_by_key($code, $key, $value)
    {
        $id = 0;
        $r = $this->get_by_key($code, $key);
        if ($r) {
            $id = $r->misc_id;
            $this->db->where($this->table_key, $r->misc_id)
                ->set('M_MiscValue', $value)
                ->update($this->table_name);
            echo $this->db->last_query();
        } else {
            $this->db->insert($this->table_name, [
                'M_MiscCode' => $code, 'M_MiscKey' => $key, 'M_MiscValue' => $value
            ]);
            $id = $this->db->insert_id();
        }

        return ['id' => $id, 'value' => $value];
    }
}
