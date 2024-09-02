<?php

class M_Employee extends MY_Model
{
    function __construct()
    {
        parent::__construct();
        $this->load->library('upload');
        $this->table_name = "m_employee";
        $this->table_as = 'employee';

        $tname = $this->table_name;
        $tas = $this->table_as;

        $this->table_key = $tname . "ID";
        $this->table_field = array(
            ['field' => $tname . 'ID', 'as' => $tas . '_id'],
            ['field' => $tname . 'M_PositionID', 'as' => $tas . '_positionid'],
            ['field' => $tname . 'Code', 'as' => $tas . '_code'],
            ['field' => $tname . 'Name', 'as' => $tas . '_name'],
            ['field' => $tname . 'DOB', 'as' => $tas . '_dob'],
            ['field' => $tname . 'Address', 'as' => $tas . '_address'],
            ['field' => $tname . 'M_CityID', 'as' => $tas . '_cityid'],
            // ['field'=>$tname.'M_ContactID','as'=>$tas.'_contactid'],
            ['field' => $tname . 'JoinDate', 'as' => $tas . '_joindate'],
            ['field' => $tname . 'Note', 'as' => $tas . '_note']
        );
        $this->table_field_search = $tname . "Name";
        $this->table_field_sort = $tname . "Code";
        $this->table_field_active = $tname . "IsActive";
    }

    function search($d)
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $page = isset($d['page']) ? max(1, intval($d['page'])) : 1;
        $offset = ($page - 1) * $limit;

        $qDiv = isset($d['division']) ? $d['division'] : "";

        $l = ['records' => [], 'total' => 0, 'total_page' => 1];

        $r = $this->db->query(
            "SELECT 
                    M_EmployeeID AS employee_id, 
                    M_EmployeeCode AS employee_code, 
                    M_EmployeeDOB AS employee_date, 
                    M_EmployeeName AS employee_name, 
                    M_EmployeeAddress AS employee_address, 
                    M_EmployeeM_PositionID AS position_id,
                    m_position.M_PositionName AS position_name,
                    M_EmployeeM_DivisionID AS division_id,
                    m_division.M_DivisionName AS division_name,
                    M_EmployeeM_CityID AS city_id,
                    m_city.M_CityName AS city_name,
                    M_EmployeeM_ContactID AS contact_id,
                    m_contact.M_ContactName AS contact_name,
                    M_EmployeeJoinDate AS employee_joindate,
                    M_EmployeeNote AS employee_note,
                    M_EmployeeSex AS employee_sex,
                    M_EmployeeImage AS employee_image,
                    M_EmployeePOBM_CityID AS employee_POB,
                    IFNULL(M_EmployeeAccountM_BankID, '') AS employee_bank,
                    IFNULL(M_EmployeeAccountNumber, '') AS employee_nobank,
                    IFNULL(M_EmployeeNikNumber, '') AS employee_nik,
                    IFNULL(M_EmployeeKkNumber, '') AS employee_kk,
                    IFNULL(M_EmployeeBpjsNumber, '') AS employee_bpjs,
                    IFNULL(M_EmployeeBpjsTkNumber, '') AS employee_bpjstk,
                    IFNULL(M_EmployeeAccountNumber, '') AS employee_account_number,
                    IFNULL(M_EmployeeAccountM_BankID, 0) AS employee_account_bank,
                    IFNULL(M_EmployeeEduGradeM_MiscID, 0) AS employee_education,
                    IFNULL(M_EmployeeEduName, '') AS employee_education_name,
                    IFNULL(M_EmployeeEduProgram, '') AS employee_education_program,
                    IFNULL(M_EmployeeMother, '') AS employee_mother,
                    IFNULL(M_EmployeeSiblingName, '') AS employee_sibling_name,
                    IFNULL(M_EmployeeSiblingPhone, '') AS employee_sibling_phone,
                    IFNULL(M_EmployeeSiblingCorrelation, '') AS employee_sibling_correlation,
                    M_EmployeeS_UserID AS user_id,
                    s_user.S_UserFullName AS user_fullname,
                    s_user.S_UserUsername AS username,
                    COUNT(P_ProjectID) as project_cnt
                FROM 
                    `m_employee`
                    JOIN `m_division` ON M_EmployeeM_DivisionID = M_DivisionID
                        AND ((M_DivisionCode = ? AND ? <> \"\") OR ? = \"\")
                    LEFT JOIN `m_position` ON M_EmployeeM_PositionID = M_PositionID 
                    LEFT JOIN `m_city` ON M_EmployeeM_CityID = M_CityID
                    LEFT JOIN `m_contact` ON M_EmployeeM_ContactID = M_ContactID
                    LEFT JOIN `s_user` ON M_EmployeeS_UserID = S_UserID
                    LEFT JOIN `m_bank` ON M_EmployeeAccountM_BankID = M_BankID
                    LEFT JOIN `p_project` ON P_ProjectM_EmployeeID = M_EmployeeID AND P_ProjectIsActive = 'Y' AND P_ProjectDone = 'N'
                WHERE 
                    `M_EmployeeName` LIKE ?
                    AND `M_EmployeeIsActive` = 'Y'
                GROUP BY M_EmployeeID
                ORDER BY 
                M_EmployeeName ASC 
                LIMIT {$limit} OFFSET " . max(0, $offset),
            [$qDiv, $qDiv, $qDiv, $d['search']]
        );

        if ($r) {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT COUNT(`{$this->table_key}`) AS n
                FROM `{$this->table_name}`
                JOIN `m_division` ON M_EmployeeM_DivisionID = M_DivisionID
                        AND ((M_DivisionCode = ? AND ? <> \"\") OR ? = \"\")
                WHERE `M_EmployeeName` LIKE ?
                AND `M_EmployeeIsActive` = 'Y'",
            [$qDiv, $qDiv, $qDiv, $d['search']]
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
    //             , m_position.M_PositionName as " . $this->table_as . "_position
    //             , concat(M_CityName,' - ',M_ProvinceName) as " . $this->table_as . "_city
    //             , m_contact.M_ContactName as " . $this->table_as . "_contact,
    //             IFNULL(M_ProvinceID, 0) province_id
    //         FROM `{$this->table_name}`
    //         LEFT OUTER JOIN m_position ON " . $this->table_name . "M_PositionID = M_PositionID and M_PositionIsActive = 'Y'
    //         LEFT OUTER JOIN m_city ON " . $this->table_name . "M_CityID = M_CityID and M_CityIsActive = 'Y'
    //         LEFT OUTER JOIN m_province ON M_CityM_ProvinceID = M_ProvinceID and M_ProvinceIsActive = 'Y'
    //         LEFT OUTER JOIN m_contact ON M_EmployeeM_ContactID = M_ContactID and M_ContactIsActive = 'Y'
    //         LEFT JOIN m_division ON M_EmployeeM_DivisionID = M_DivisionID
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
        if (isset($d['user_password']))
            $d['user_password'] = $this->pass_prefix . $d['user_password'] . $this->pass_suffix;

        $r = $this->db->query("CALL sp_master_employee_save(?, ?)", [$id, json_encode($d)])->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        if ($r->status == "OK")
            $r->data = json_decode($r->data);

        return $r;
    }



    // function save($d, $id = 0)
    // {
    //     $fa = $this->table_field;
    //     unset($fa[0]);
    //     $f = array();
    //     for ($x = 1; $x <= count($fa); $x++) {
    //         $f[$fa[$x]['field']] = $d[$fa[$x]['as']];
    //     }
    //     $this->db->set($f);

    //     if ($id != 0) {
    //         $r = $this->db->where($this->table_key, $id)
    //             ->update($this->table_name);
    //     } else {
    //         $r = $this->db->insert($this->table_name);
    //         $id = $this->db->insert_id();
    //     }

    //     if ($r)
    //         return (object) ["status" => "OK", "data" => $id, "query" => $this->db->last_query()];
    //     return (object) ["status" => "ERR"];
    // }

    function del($id)
    {
        $this->db->set('M_EmployeeIsActive', 'N')
            ->where('M_EmployeeID', $id)
            ->update($this->table_name);

        return true;
    }
    public function list_files()
    {
        $folder_path = '../assets/uploads/';
        $files = get_filenames($folder_path);

        // Memasukkan hasil ke dalam array
        $result_array = array(
            'files' => $files
        );

        // Mengembalikan hasil dalam format JSON
        return $result_array;
    }

    function get_by_uid ($uid) 
    {
        $r = $this->db->select("M_EmployeeID as employee_id")
                ->where("M_EmployeeS_UserID", $uid)
                ->where("M_EmployeeIsActive", "Y")
                ->get($this->table_name)->row();

        return $r;
    }
}
