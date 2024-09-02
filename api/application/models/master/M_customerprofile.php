<?php

class M_Customerprofile extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_customerprofile";
        $this->table_key = "M_CustomerProfileID";
    }

    function search( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_CustomerProfileID profile_id, 
                    M_CustomerProfileDesc profile_desc,
                    M_CustomerProfileTitleID title_id,
                    M_CustomerProfileTitleLabel title_label,
                    M_EmployeeID employee_id, M_EmployeeName employee_name,
                    M_DivisionID division_id, M_DivisionName division_name
                FROM `{$this->table_name}`
                JOIN m_customerprofiletitle ON M_CustomerProfileM_CustomerProfileTitleID = M_CustomerProfileTitleID
                JOIN m_employee ON M_CustomerProfileM_EmployeeID = M_EmployeeID
                JOIN m_division ON M_EmployeeM_DivisionID = M_DivisionID
                WHERE `M_CustomerProfileDesc` LIKE ?
                AND `M_CustomerProfileIsActive` = 'Y'
                AND M_CustomerProfileM_CustomerID = ?
                ORDER BY M_DivisionName, M_CustomerProfileTitleLabel asc
                LIMIT {$limit} OFFSET {$offset}", [$d['search'], $d['customer_id']]);
        if ($r)
        {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            JOIN m_customerprofiletitle ON M_CustomerProfileM_CustomerProfileTitleID = M_CustomerProfileTitleID
            WHERE `M_CustomerProfileDesc` LIKE ?
            AND `M_CustomerProfileIsActive` = 'Y'
            AND M_CustomerProfileM_CustomerID = ?", [$d['search'], $d['customer_id']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }
            
        return $l;
    }

    // function save ( $d, $id = 0)
    // {
    //     $this->db->set('M_CustomerProfileName', $d['title_name'])
    //                 ->set('M_CustomerProfileNote', $d['title_note']);
    
    //     if ($id != 0) {
    //         $r = $this->db->where('M_CustomerProfileID', $id)
    //                 ->update( $this->table_name );
    //     }
    
    //     else {
    //         $r = $this->db->insert( $this->table_name );
    //         $id = $this->db->insert_id();
    //     }

    //     if ($r)
    //         return (object) ["status"=>"OK", "data"=>['title_id'=>$id], "query"=>$this->db->last_query()];
    //     return (object) ["status"=>"ERR"];
    // }
    // function del ($id)
    // {
    //     $this->db->set('M_CustomerProfileIsActive', 'N')
    //         ->where('M_CustomerProfileID', $this->sys_input['id'])
    //         ->update($this->table_name);
    //     return true;
    // }
}

?>