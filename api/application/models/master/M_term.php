<?php

class M_Term extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_term";
        $this->table_key = "M_TermID";
    }

    function search($d)
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records' => [], 'total' => 0, 'total_page' => 1];

        $r = $this->db->query(
            "SELECT M_TermID term_id, IFNULL(M_TermCode, '') term_code, M_TermName term_name, M_TermDuration term_duration
                FROM `{$this->table_name}`
                WHERE `M_TermName` LIKE ?
                AND `M_TermIsActive` = 'Y'
                ORDER BY M_TermCode asc
                LIMIT {$limit} OFFSET {$offset}",
            [$d['search']]
        );
        if ($r) {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_TermName` LIKE ?
            AND `M_TermIsActive` = 'Y'",
            [$d['search']]
        );
        if ($r) {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }

        return $l;
    }

    function save($d, $id = 0)
    {
        $this->db->set('M_TermName', $d['term_name'])
            ->set('M_TermDuration', $d['term_duration'])
            ->set('M_TermCode', $d['term_code']);

        if ($id != 0) {
            $r = $this->db->where('M_TermID', $id)
                ->update($this->table_name);
        } else {
            $r = $this->db->insert($this->table_name);
            $id = $this->db->insert_id();
        }

        if ($r)
            return (object) ["status" => "OK", "data" => $id, "query" => $this->db->last_query()];
        return (object) ["status" => "ERR"];
    }
    function del($id)
    {
        $this->db->set('M_TermIsActive', 'N')
            ->where('M_TermID', $this->sys_input['id'])
            ->update($this->table_name);
        return true;
    }
}
