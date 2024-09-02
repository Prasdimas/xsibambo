<?php

class S_user extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "s_user";
        $this->table_key = "S_UserID";
    }

    function get_user($d)
    {

        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $page = isset($d['page']) ? max(1, intval($d['page'])) : 1;
        $offset = ($page - 1) * $limit;

        $l = ['records' => [], 'total' => 0, 'total_page' => 1];

        $r = $this->db->query(
            "SELECT 
                    S_UserID AS user_id, 
                    S_UserFullName AS user_fullname, 
                    S_UserUsername AS username 
                FROM 
                    `s_user`
                WHERE 
                    `S_UserFullName` LIKE ?
                    AND `S_UserIsActive` = 'Y'
                ORDER BY 
                S_UserFullName ASC 
                LIMIT {$limit} OFFSET " . max(0, $offset),
            [$d['search']]
        );

        if ($r) {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT COUNT(`{$this->table_key}`) AS n
                FROM `{$this->table_name}`
                WHERE `S_UserFullName` LIKE ?
                AND `S_UserIsActive` = 'Y'",
            [$d['search']]
        );

        if ($r) {
            $total = $r->row()->n;
            $l['total'] = $total;
            $l['total_page'] = ceil($total / $limit);
        }
        return $l;
    }






    function login($username, $password)
    {
        $password = $this->pass_prefix . $password . $this->pass_suffix;
        $r = $this->db->query("CALL sp_system_login(?, ?)", [$username, $password])
            ->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        return $r;
    }

    function logout($uid)
    {
        $query = $this->db->query(
            "
            UPDATE s_user
            SET S_UserIsLogin = 'N', S_UserToken = null
            WHERE S_UserID = ?",
            [$uid]
        );

        if (!$query)
            return false;
        return true;
    }

    function get_profile($id)
    {
        $r = $this->db->query("SELECT S_UserUsername user_name,
                            S_UserGroupID group_id,
                            S_UserGroupName group_name,
                            M_EmployeeName employee_name,
                            M_DivisionID division_id, M_DivisionName division_name

                        FROM `{$this->table_name}`
                        JOIN s_usergroup ON S_UserS_UserGroupID = S_UserGroupID
                        JOIN m_employee ON M_EmployeeS_UserID = S_UserID AND M_EmployeeIsActive = 'Y'
                        JOIN m_division ON M_EmployeeM_DivisionID = M_DivisionID
                        WHERE S_UserID = ?", [$id])
            ->row();
        return $r;
    }

    function check_old_password($username, $password)
    {
        $r = $this->db->query("CALL sp_system_login_check(?, ?)", [$username, $password])
            ->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        return $r;
    }

    function save_password($id, $d)
    {
        $d['prefix'] = $this->pass_prefix;
        $d['suffix'] = $this->pass_suffix;

        $r = $this->db->query("CALL sp_system_user_password_save(?, ?)", [$id, json_encode($d)])
            ->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        return $r;
        // $password = md5($this->pass_prefix . $d['user_old_password'] . $this->pass_suffix);
        // $r = $this->check_old_password($d['user_name'], $password);

        // if ($r->status == 'OK')
        // {
        //     $pwd = md5($this->pass_prefix . $d['user_password'] . $this->pass_suffix);
        //     $this->db->query("UPDATE s_user
        //                     SET S_UserPassword = ?
        //                     WHERE S_UserUsername = ? AND S_UserIsActive = 'Y'", [$pwd, $d['user_name']]);
        // }

        // return $r;
    }

    function save_profile($d, $id)
    {
        $r = $this->db->set('S_UserProfileFullName', $d['user_fullname'])
            ->set('S_UserProfileAddress', $d['user_fulladdress'])
            ->set('S_UserProfilePhone', $d['user_phone'])
            ->set('S_UserProfileEmail', isset($d['user_email']) ? $d['user_email'] : '')
            ->set('S_UserProfilePostCode', isset($d['user_postcode']) ? $d['user_postcode'] : '')
            ->set('S_UserProfileM_KelurahanID', $d['user_village_id'])
            ->where('S_UserProfileS_UserID', $id)
            ->update('s_userprofile');
        if ($r) {
            return ["status" => "OK", "data" => $id];
        }

        return ["status" => "ERR"];
    }

    function search($d)
    {
        $l = ['records' => [], 'total' => 0];
        if (!isset($d['uid']))
            $d['uid'] = 0;
        if (!isset($d['gid']))
            $d['gid'] = 0;

        $r = $this->db->query(
            "SELECT S_UserID user_id, S_UserUsername user_name, S_UserProfileFullName user_full_name,
                    S_UserGroupID group_id, S_UserGroupCode group_code, S_UserGroupName group_name,
                    S_UserProfileAddress user_address, S_UserProfilePhone user_phone, S_UserProfileEmail user_email, S_UserProfileJoinDate user_join
                FROM `{$this->table_name}`
                JOIN s_usergroup ON S_UserS_UserGroupID = S_USerGroupID
                    AND ((S_UserGroupID = ? AND ? <> 0) OR ? = 0)
                JOIN s_userprofile ON S_UserID = S_UserProfileS_UserID AND S_UserProfileIsActive = 'Y'
                WHERE (`S_UserUsername` LIKE ? OR `S_UserProfileFullName` LIKE ?)
                AND `S_UserIsActive` = 'Y'
                AND ((S_UserID = ? AND ? <> 0) OR ? = 0)",
            [$d['gid'], $d['gid'], $d['gid'], $d['search'], $d['search'], $d['uid'], $d['uid'], $d['uid']]
        );
        if ($r) {
            $r = $r->result_array();
            $l['records'] = $r;
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            JOIN s_usergroup ON S_UserS_UserGroupID = S_USerGroupID
                AND ((S_UserGroupID = ? AND ? <> 0) OR ? = 0)
            JOIN s_userprofile ON S_UserID = S_UserProfileS_UserID AND S_UserProfileIsActive = 'Y'
                WHERE (`S_UserUsername` LIKE ? OR `S_UserProfileFullName` LIKE ?)
                AND `S_UserIsActive` = 'Y'
                AND ((S_UserID = ? AND ? <> 0) OR ? = 0)",
            [$d['gid'], $d['gid'], $d['gid'], $d['search'], $d['search'], $d['uid'], $d['uid'], $d['uid']]
        );
        if ($r) {
            $l['total'] = $r->row()->n;
        }

        return $l;
    }

    function save($d)
    {
        $d['user_pass'] = $d['user_pass'] == '' ? '' : md5($this->pass_prefix . $d['user_pass'] . $this->pass_suffix);
        $jdata = json_encode($d);
        $r = $this->db->query("CALL sp_system_user_save(?, ?, ?)", [$d['user_id'], $d['user_name'], $jdata])
            ->row();

        return $r;
    }

    function check($d)
    {
        $r = $this->db->query("SELECT S_UserID FROM s_user WHERE S_UserUsername = ? AND S_UserIsActive = 'Y'", $d['user_name']);
        if ($r) {
            if ($r->num_rows() > 0) {
                $r = $r->row();
                if ($r->S_UserID != null)
                    return (object) ["status" => "ERR", "message" => "Username sudah digunakan, silahkan pilih yang lain :)"];
            }
        }
        return (object) ["status" => "OK"];
    }

    function del($d)
    {
        $r = $this->db->query("UPDATE s_user SET S_UserIsActive = 'N' WHERE S_UserID = ?", $d['id']);
        $r = $this->db->query("UPDATE s_userprofile SET S_UserProfileIsActive = 'N' WHERE S_UserProfileS_UserID = ?", $d['id']);
        return (object) ["status" => "OK"];
    }
}
