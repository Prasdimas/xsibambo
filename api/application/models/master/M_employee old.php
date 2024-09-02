<?php

class M_employee extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_employee";
        $this->table_key = "M_EmployeeID";
    }

    function search($d)
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records' => [], 'total' => 0, 'total_page' => 1];
        $uid = isset($d['uid']) ? $d['uid'] : 0;

        $r = $this->db->query(
            "SELECT M_EmployeeID employee_id, sha(M_EmployeeCode) employee_code, M_EmployeeName employee_name, M_EmployeeNote employee_note,
                    M_EmployeeAddress employee_address, IF(M_EmployeeJoinDate = '0000-00-00', null, M_EmployeeJoinDate) employee_join, 
                    M_EmployeeM_ContactID contact_id, IFNULL(contacts, '[]') contacts,
                    IF(M_EmployeeDOB = '0000-00-00', null, M_EmployeeDOB) employee_dob,
                    IFNULL(M_CityID, 0) city_id, IFNULL(M_CityName, '') city_name,
                    IFNULL(M_ProvinceID, 0) province_id, IFNULL(M_ProvinceName, '') province_name,
                    IFNULL(M_PositionID, 0) position_id, IFNULL(M_PositionName, '') position_name,
                    IFNULL(M_DivisionID, 0) division_id, IFNULL(M_DivisionName, '') division_name,
                    IFNULL(S_UserID, 0) user_id, IFNULL(S_UserUsername, '') user_name
                FROM `{$this->table_name}`
                LEFT JOIN m_position ON M_EmployeeM_PositionID = M_PositionID
                LEFT JOIN m_division ON M_EmployeeM_DivisionID = M_DivisionID
                LEFT JOIN m_city ON M_EmployeeM_CityID = M_CityID
                LEFT JOIN m_province ON M_CityM_ProvinceID = M_ProvinceID
                LEFT JOIN s_user ON M_EmployeeS_UserID = S_UserID
        
                LEFT JOIN (
                    SELECT M_ContactDetailM_ContactID c_id,
                        CONCAT('[', GROUP_CONCAT(JSON_OBJECT('id', M_ContactDetailID, 'type', M_ContactDetailType, 'desc', M_ContactDetailDesc)), ']') contacts
                    FROM m_contactdetail
                    WHERE M_ContactDetailIsActive = 'Y'
                    GROUP BY M_ContactDetailM_ContactID
                ) ctc ON M_EmployeeM_ContactID = c_id
        
                WHERE `M_EmployeeName` LIKE ?
                AND `M_EmployeeIsActive` = 'Y'
                AND ((M_EmployeeS_UserID = ? AND ? <> 0) Or ? = 0)
                ORDER BY M_DivisionName asc, M_EmployeeName asc
                LIMIT {$limit} OFFSET {$offset}",
            ["%" . $d['search'] . "%", $uid, $uid, $uid]
        );

        if ($r) {
            $rst = $r->result_array();

            $this->load->model("master/m_contact");
            foreach ($rst as $k => $v) {
                $rst[$k]['contacts'] = json_decode($v['contacts']);
            }

            $l['records'] = $rst;
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_EmployeeName` LIKE ?
            AND `M_EmployeeIsActive` = 'Y'
            AND ((M_EmployeeS_UserID = ? AND ? <> 0) Or ? = 0)",
            [$d['search'], $uid, $uid, $uid]
        );
        if ($r) {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }

        return $l;
    }

    function search_me($uid)
    {
        $r = $this->search(['limit' => 1, 'page' => 1, 'search' => '%', 'uid' => $uid]);
        return $r['records'][0];
    }

    function save($d, $id = 0)
    {
        if (isset($d['user_password']))
            $d['user_password'] = $this->pass_prefix . $d['user_password'] . $this->pass_suffix;

        $r = $this->db->query("CALL sp_master_employee_save(?, ?)", [$id, json_encode($d)])->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        if ($r->status == "OK")
            $r->data = json_decode($r->data);

        return $r;
    }

    function del($id)
    {
        $this->db->set('M_EmployeeIsActive', 'N')
            ->where('M_EmployeeID', $this->sys_input['id'])
            ->update($this->table_name);

        return true;
    }
}
