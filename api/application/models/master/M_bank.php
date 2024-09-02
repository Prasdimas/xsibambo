<?php

class M_Bank extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_bank";
        $this->table_key = "M_BankID";
    }

    function search($d)
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records' => [], 'total' => 0, 'total_page' => 1];

        $r = $this->db->query(
            "SELECT M_BankID bank_id, IFNULL(M_BankCode, '') bank_code, M_BankName bank_name
                FROM `{$this->table_name}`
                WHERE `M_BankName` LIKE ?
                AND `M_BankIsActive` = 'Y'
                ORDER BY M_BankCode asc
                LIMIT {$limit} OFFSET {$offset}",
            [$d['search']]
        );
        if ($r) {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_BankName` LIKE ?
            AND `M_BankIsActive` = 'Y'",
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
        $this->db->set('M_BankName', $d['bank_name'])
            ->set('M_BankCode', $d['bank_code']);

        if ($id != 0) {
            $r = $this->db->where('M_BankID', $id)
                ->update($this->table_name);
        } else {
            $r = $this->db->insert($this->table_name);
            $id = $this->db->insert_id();
        }

        if ($r)
            return (object) ["status" => "OK", "data" => ['bank_id' => $id], "query" => $this->db->last_query()];
        return (object) ["status" => "ERR"];
    }
    function del($id)
    {
        $this->db->set('M_BankIsActive', 'N')
            ->where('M_BankID', $this->sys_input['id'])
            ->update($this->table_name);
        return true;
    }
}
