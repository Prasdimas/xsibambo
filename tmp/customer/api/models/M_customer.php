<?php

class M_customer extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_customer";
        $this->table_key = "M_CustomerID";
    }

    function search( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_CustomerID customer_id, M_CustomerName customer_name,
                M_CustomerAddress customer_address, M_CustomerCode customer_code,
                IFNULL(M_KelurahanName, '') village_name,
                IFNULL(M_DistrictName, '') district_name,
                IFNULL(M_CityName, '') city_name,
                IFNULL(M_ProvinceName, '') province_name,
                M_ProvinceID province_id, M_CityID city_id, 
                M_DistrictID district_id, M_KelurahanID village_id,
                M_CustomerEmail customer_email, M_CustomerNote customer_note, M_CustomerPostCode customer_postcode,
                M_CustomerPhone customer_phone, M_customerPICName customer_pic_name,
                M_CustomerPICPhone customer_pic_phone, M_CustomerNPWP customer_npwp,
                M_CustomerIsCompany customer_type,
                IFNULL(M_CustomerPhones, '[]') customer_phones,
                M_CustomerS_StaffID customer_staff, M_CustomerProspect customer_prospect
                FROM `{$this->table_name}`
                LEFT JOIN m_kelurahan ON M_CustomerM_KelurahanID = M_KelurahanID
                LEFT JOIN m_district ON M_CustomerM_DistrictID = M_DistrictID
                LEFT JOIN m_city ON M_CustomerM_CityID = M_CityID
                LEFT JOIN m_province ON M_CityM_ProvinceID = M_ProvinceID
                WHERE (`M_CustomerName` LIKE ? OR M_CustomerCode LIKE ? OR M_CustomerAddress LIKE ? OR M_CustomerPhones LIKE ?)
                AND `M_CustomerIsActive` = 'Y'
                AND ((M_ProvinceID = ? AND ? <> 0) OR ? = 0)
                AND ((M_CityID = ? AND ? <> 0) OR ? = 0)
                AND ((M_CustomerIsCompany = ? AND ? <> '') OR ? = '')
                ORDER BY M_CustomerName ASC
                LIMIT {$limit} OFFSET {$offset}", [$d['customer_name'], $d['customer_name'], $d['customer_name'], $d['customer_name'], $d['province'], $d['province'], $d['province'], $d['city'], $d['city'], $d['city'], $d['type'], $d['type'], $d['type']]);
        if ($r)
        {
            $r = $r->result_array();
            foreach ($r as $k => $v)
            {
                $r[$k]['customer_phones'] = json_decode($v['customer_phones']);

                // banks
                $banks = $this->db->query("SELECT fn_master_customer_get_banks(?) x", [$v['customer_id']])->row();
                $r[$k]['banks'] = json_decode($banks->x);

                // addresses
                $addresses = $this->db->query("SELECT fn_master_customer_addresses(?) x", [$v['customer_id']])->row();
                $r[$k]['addresses'] = json_decode($addresses->x);
            }
                
            $l['records'] = $r;
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            LEFT JOIN m_kelurahan ON M_CustomerM_KelurahanID = M_KelurahanID
                LEFT JOIN m_district ON M_CustomerM_DistrictID = M_DistrictID
                LEFT JOIN m_city ON M_CustomerM_CityID = M_CityID
                LEFT JOIN m_province ON M_CityM_ProvinceID = M_ProvinceID
            WHERE (`M_CustomerName` LIKE ? OR M_CustomerCode LIKE ? OR M_CustomerAddress LIKE ? OR M_CustomerPhones LIKE ?)
            AND `M_CustomerIsActive` = 'Y'
            AND ((M_ProvinceID = ? AND ? <> 0) OR ? = 0)
                AND ((M_CityID = ? AND ? <> 0) OR ? = 0)
                AND ((M_CustomerIsCompany = ? AND ? <> '') OR ? = '')", [$d['customer_name'], $d['customer_name'], $d['customer_name'], $d['customer_name'], $d['province'], $d['province'], $d['province'], $d['city'], $d['city'], $d['city'], $d['type'], $d['type'], $d['type']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }
            
        return $l;
    }

    function save ( $d )
    {
        $r = $this->db->query("CALL sp_master_customer_save(?,?,?,?,?)", [
            0, json_encode([
                'name'=>$d['customer_name'],
                'address'=>$d['customer_address'],
                'phone'=>$d['customer_phone'],
                'phones'=>$d['customer_phones'],
                'email'=>$d['customer_email'],
                'postcode'=>$d['customer_postcode'],
                'note'=>$d['customer_note'],
                'postcode'=>$d['customer_postcode'],
                'pic_name'=>$d['customer_pic_name'],
                'pic_phone'=>$d['customer_pic_phone'],
                'npwp'=>$d['customer_npwp'],
                'prospect'=>isset($d['customer_prospect'])?$d['customer_prospect']:'N',
                'company'=>$d['customer_type'],
                'city'=>isset($d['customer_city_id'])?$d['customer_city_id']:0,
                'district'=>isset($d['customer_district_id'])?$d['customer_district_id']:0,
                'kelurahan'=>isset($d['customer_kelurahan_id'])?$d['customer_kelurahan_id']:0,
                'staff'=>isset($d['customer_staff'])?$d['customer_staff']:0
            ]), isset($d['bdata'])?$d['bdata']:'[]', isset($d['addresses'])?$d['addresses']:'[]', 0
        ])->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        if ($r->status == "OK")
        {
            $r->data = json_decode($r->data);
            $this->set_index($r->data->customer_id);
        }

        return $r;

        // $r = $this->db->set('M_CustomerName', $d['customer_name'])
        //             ->set('M_CustomerAddress', $d['customer_address'])
        //             ->set('M_CustomerPhone', $d['customer_phone'])
        //             ->set('M_CustomerPhones', $d['customer_phones'])
        //             ->set('M_CustomerNote', $d['customer_note'])
        //             ->set('M_CustomerEmail', $d['customer_email'])
        //             ->set('M_CustomerPostCode', $d['customer_postcode'])
        //             ->set('M_CustomerPICName', $d['customer_pic_name'])
        //             ->set('M_CustomerPICPhone', $d['customer_pic_phone'])
        //             ->set('M_CustomerNPWP', $d['customer_npwp'])
        //             ->set('M_CustomerProspect', isset($d['customer_prospect'])?$d['customer_prospect']:'N')
        //             ->set('M_CustomerIsCompany', $d['customer_type'])
        //             ->set('M_CustomerM_CityID', isset($d['customer_city_id'])?$d['customer_city_id']:0)
        //             ->set('M_CustomerM_DistrictID', isset($d['customer_district_id'])?$d['customer_district_id']:0)
        //             ->set('M_CustomerM_KelurahanID', isset($d['customer_kelurahan_id'])?$d['customer_kelurahan_id']:0)
        //             ->set('M_CustomerS_StaffID', isset($d['customer_staff'])?$d['customer_staff']:0)
        //             // ->set('M_CustomerJoinDate', isset($d['customer_join_date'])?date('Y-m-d', strtotime($d['customer_join_date'])):date('Y-m-d'))
        //             // ->set('M_CustomerUserID', $d['user_id'])
        //             ->insert( $this->table_name );
        // $id = $this->db->insert_id();

        // if ($r)
        //     return ["status"=>"OK", "data"=>$id];

        // return ["status"=>"ERR"];
    }

    function edit ( $d )
    {
        $r = $this->db->query("CALL sp_master_customer_save(?,?,?,?,?)", [
            $d['customer_id'], json_encode([
                'name'=>$d['customer_name'],
                'address'=>$d['customer_address'],
                'phone'=>$d['customer_phone'],
                'phones'=>$d['customer_phones'],
                'email'=>$d['customer_email'],
                'postcode'=>$d['customer_postcode'],
                'note'=>$d['customer_note'],
                'postcode'=>$d['customer_postcode'],
                'pic_name'=>$d['customer_pic_name'],
                'pic_phone'=>$d['customer_pic_phone'],
                'npwp'=>$d['customer_npwp'],
                'prospect'=>isset($d['customer_prospect'])?$d['customer_prospect']:'N',
                'company'=>$d['customer_type'],
                'city'=>isset($d['customer_city_id'])?$d['customer_city_id']:0,
                'district'=>isset($d['customer_district_id'])?$d['customer_district_id']:0,
                'kelurahan'=>isset($d['customer_kelurahan_id'])?$d['customer_kelurahan_id']:0,
                'staff'=>isset($d['customer_staff'])?$d['customer_staff']:0
            ]), isset($d['bdata'])?$d['bdata']:'[]', isset($d['addresses'])?$d['addresses']:'[]', 0
        ])->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        if ($r->status == "OK")
        {
            $r->data = json_decode($r->data);
            $this->set_index($r->data->customer_id);
        }

        return $r;

        // $r = $this->db->set('M_CustomerName', $d['customer_name'])
        //             ->set('M_CustomerAddress', $d['customer_address'])
        //             ->set('M_CustomerPhone', $d['customer_phone'])
        //             ->set('M_CustomerPhones', $d['customer_phones'])
        //             ->set('M_CustomerEmail', $d['customer_email'])
        //             ->set('M_CustomerPostCode', $d['customer_postcode'])
        //             ->set('M_CustomerNote', $d['customer_note'])
        //             ->set('M_CustomerM_KelurahanID', $d['customer_kelurahan_id'])
        //             ->set('M_CustomerPostCode', $d['customer_postcode'])
        //             ->set('M_CustomerPICName', $d['customer_pic_name'])
        //             ->set('M_CustomerPICPhone', $d['customer_pic_phone'])
        //             ->set('M_CustomerNPWP', $d['customer_npwp'])
        //             ->set('M_CustomerProspect', isset($d['customer_prospect'])?$d['customer_prospect']:'N')
        //             ->set('M_CustomerIsCompany', $d['customer_type'])
        //             ->set('M_CustomerM_CityID', isset($d['customer_city_id'])?$d['customer_city_id']:0)
        //             ->set('M_CustomerM_DistrictID', isset($d['customer_district_id'])?$d['customer_district_id']:0)
        //             ->set('M_CustomerM_KelurahanID', isset($d['customer_kelurahan_id'])?$d['customer_kelurahan_id']:0)
        //             ->set('M_CustomerS_StaffID', isset($d['customer_staff'])?$d['customer_staff']:0)
        //             // ->set('M_CustomerJoinDate', isset($d['customer_join_date'])?date('Y-m-d', strtotime($d['customer_join_date'])):date('Y-m-d'))
        //             ->where('M_CustomerID', $d['customer_id'])
        //             ->update( $this->table_name );
        // if ($r)
        // {
        //     return ["status"=>"OK", "data"=>$d['customer_id']];
        // }

        // return ["status"=>"ERR"];
    }

    function del ($id, $uid = 0)
    {
        $r = $this->db->query("CALL sp_master_customer_delete(?, ?)", [$id, $uid])
                    ->row();
        $this->clean_mysqli_connection($this->db->conn_id);
        // $this->db->set('M_CustomerIsActive', 'N')
        //         ->where('M_CustomerID', $this->sys_input['id'])
        //         ->update($this->table_name);

        return $r;
    }

    function search_autocomplete( $d )
    {
        $d['limit'] = 25;
        $d['page'] = 1;
        $r = $this->search( $d );
        
        return $r['records'];
    }

    function set_index($id = 0)
    {
        if ($id > 0)
            $this->db->where('M_CustomerID', $id);

        $r = $this->db->select('M_CustomerID id, M_CustomerNAme name', false)
                    ->where('M_CustomerIsACtive', 'Y')
                    ->get($this->table_name)
                    ->result_array();
        foreach ($r as $k => $v)
        {
            $e = explode(" ", $v['name']);
            $f = [];
            foreach ($e as $l => $w)
                if ($w != '')
                    $f[] = '['.metaphone($w).']';
            sort($f);
            $this->db->where('M_CustomerID', $v['id'])
                    ->set('M_CustomerIndex', join('', $f))
                    ->update($this->table_name);
        }
    }

    function search_similar($p)
    {
        $e = explode(" ", $p);
        $f = [];
        $g = [];
        foreach ($e as $k => $v)
        {
            $f[] = metaphone($v);
            $g[] = '['.metaphone($v).']';
        }
        
        $r = $this->db->query("CALL sp_master_customer_search_index(?,?,?)", [join('',$g), $f[0], isset($f[1])?$f[1]:''])
                ->result_array();
        $this->clean_mysqli_connection($this->db->conn_id);

        if ($r)
            return $r;
        return [];
    }

    function _tmp_idx()
    {
        $r = $this->db->where('M_CustomerIsActive', 'Y')
                    ->get($this->table_name)
                    ->result_array();
        foreach($r as $k => $v)
        {
            preg_match_all("/\[[A-Z]+\]/", $v['M_CustomerIndex'], $e);
            foreach ($e[0] as $l => $w)
            {
                echo $w."<br>";
                $this->db->query("insert into _tmp_cust_idx(cid, idx) values(?,?)", [$v['M_CustomerID'], $w]);
            }
                
        }
    }

    function get_main_address($id)
    {
        $r = $this->db->query("SELECT M_DeliveryAddressDesc address_desc,
            IFNULL(M_KelurahanName, '') village_name, IFNULL(M_DistrictName, '') district_name,
            IFNULL(M_CityName, '') city_name, IFNULL(M_ProvinceName, '') province_name,
            IFNULL(M_DeliveryAddressPhones, '[]') phones
            FROM m_customer
            JOIN m_deliveryaddress ON M_DeliveryAddressM_CustomerID = M_CustomerID
                AND M_DeliveryAddressIsActive = 'Y' AND M_DeliveryAddressIsMain = 'Y'
            LEFT JOIN m_kelurahan ON M_DeliveryAddressM_KelurahanID = M_KelurahanID
            LEFT JOIN m_district ON M_DeliveryAddressM_DistrictID = M_DistrictID
            LEFT JOIN m_city ON M_DeliveryAddressM_CityID = M_CityID
            LEFT JOIN m_province ON M_CityM_ProvinceID = M_ProvinceID
            WHERE M_CustomerID = ?
            LIMIT 1", $id)->row();

        $r->phones = json_decode($r->phones);
        return $r;
    }
}

?>