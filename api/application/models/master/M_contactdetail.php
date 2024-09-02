<?php

class M_Contactdetail extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "M_ContactDetail";
        $this->table_as = 'contactdetail';

        $tname = $this->table_name;
        $tas = $this->table_as;

        $this->table_key = $tname . "ID";
        $this->table_field = array(
            ['field' => $tname . 'ID', 'as' => $tas . '_id'],
            ['field' => $tname . 'M_ContactID', 'as' => $tas . '_contactid'],
            ['field' => $tname . 'Type', 'as' => $tas . 'type'],
            ['field' => $tname . 'Desc', 'as' => $tas . '_desc'],
        );
        $this->table_field_search = $tname . "Type";
        $this->table_field_sort = $tname . "ID";
        $this->table_field_active = $tname . "IsActive";
    }

    function search($d)
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $page = isset($d['page']) ? max(1, intval($d['page'])) : 1;
        $offset = ($page - 1) * $limit;

        $l = ['records' => [], 'total' => 0, 'total_page' => 1];

        $r = $this->db->query(
            "SELECT 
                    M_ContactDetailID AS id, 
                    M_ContactDetailM_ContactID AS contact_id, 
                    M_ContactDetailType AS `type`, 
                    M_ContactDetailDesc AS `desc`,  
                    M_ContactDetailS_UserID AS user_id
                FROM 
                    `m_contactdetail`
    LEFT JOIN `m_contact` ON M_ContactDetailM_ContactID = M_ContactID
    LEFT JOIN `s_user` ON M_ContactS_UserID = S_UserID
                WHERE 
                    `M_ContactDetailDesc` LIKE ?
                    AND `M_ContactDetailIsActive` = 'Y'
                ORDER BY 
                M_ContactDetailDesc ASC 
                LIMIT {$limit} OFFSET " . max(0, $offset),
            [$d['search']]
        );

        if ($r) {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT COUNT(`{$this->table_key}`) AS n
                FROM `{$this->table_name}`
                WHERE `M_ContactDetailDesc` LIKE ?
                AND `M_ContactDetailIsActive` = 'Y'",
            [$d['search']]
        );

        if ($r) {
            $total = $r->row()->n;
            $l['total'] = $total;
            $l['total_page'] = ceil($total / $limit);
        }
        return $l;
    }


    // function search($d)
    // {
    //     $limit = isset($d['limit']) ? $d['limit'] : 10;
    //     $offset = ($d['page'] - 1) * $limit;
    //     $l = ['records' => [], 'total' => 0, 'total_page' => 1];
    //     $f = "";
    //     $af = $this->table_field;
    //     for ($x = 0; $x < count($af); $x++) {
    //         $f .= ($x != 0) ? ', ' : '';
    //         $f .= $af[$x]['field'] . ' as ' . $af[$x]['as'];
    //     }
    //     $q = "
    //         SELECT $f
    //         FROM `{$this->table_name}`
    //         WHERE `$this->table_field_search` LIKE ?
    //         AND `$this->table_field_active` = 'Y'
    //         ORDER BY `$this->table_field_sort` asc
    //         LIMIT {$limit} OFFSET {$offset}
    //     ";
    //     $r = $this->db->query($q, [$d['search']]);
    //     if ($r) {
    //         $l['records'] = $r->result_array();
    //     }
    //     $qall = "
    //         SELECT count(`{$this->table_key}`) n
    //         FROM `{$this->table_name}`
    //         WHERE `$this->table_field_search` LIKE ?
    //         AND `$this->table_field_active` = 'Y'
    //     ";
    //     $r = $this->db->query($qall, [$d['search']]);
    //     if ($r) {
    //         $l['total'] = $r->row()->n;
    //         $l['total_page'] = ceil($r->row()->n / $limit);
    //     }
    //     return $l;
    // }

    function save($d, $id = 0)
    {
        $fa = $this->field;
        unset($fa[0]);
        $f = array();
        for ($x = 1; $x <= count($fa); $x++) {
            $f[$fa[$x]['field']] = $fa[$x]['as'];
        }
        $this->db->set($f);

        if ($id != 0) {
            $r = $this->db->where($this->table_key, $id)
                ->update($this->table_name);
        } else {
            $r = $this->db->insert($this->table_name);
            $id = $this->db->insert_id();
        }

        if ($r)
            return (object) ["status" => "OK", "data" => $id, "query" => $this->db->last_query()];
        return (object) ["status" => "ERR"];
    }
}
