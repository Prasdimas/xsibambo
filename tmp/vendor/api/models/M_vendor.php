<?php

class M_vendor extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_vendor";
        $this->table_key = "M_VendorID";
    }

    function search( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_VendorID vendor_id, M_VendorName vendor_name,
                M_VendorAddress vendor_address, M_VendorCode vendor_code,
                IFNULL(M_KelurahanName, '') village_name,
                IFNULL(M_DistrictName, '') district_name,
                IFNULL(M_CityName, '') city_name,
                IFNULL(M_ProvinceName, '') province_name,
                M_ProvinceID province_id, M_CityID city_id, 
                M_DistrictID district_id, M_KelurahanID village_id,
                M_VendorEmail vendor_email, M_VendorNote vendor_note, M_VendorPostCode vendor_postcode,
                M_vendorPICName vendor_pic_name,
                M_VendorPICPhone vendor_pic_phone, M_VendorNPWP vendor_npwp,
                IFNULL(M_VendorPhones, '[]') vendor_phones,
                0 vendor_staff
                FROM `{$this->table_name}`
                LEFT JOIN m_kelurahan ON M_VendorM_KelurahanID = M_KelurahanID
                LEFT JOIN m_district ON M_VendorM_DistrictID = M_DistrictID
                LEFT JOIN m_city ON M_VendorM_CityID = M_CityID
                LEFT JOIN m_province ON M_CityM_ProvinceID = M_ProvinceID
                WHERE (`M_VendorName` LIKE ? OR M_VendorCode LIKE ? OR M_VendorAddress LIKE ? OR M_VendorPhones LIKE ?)
                AND `M_VendorIsActive` = 'Y'
                AND ((M_ProvinceID = ? AND ? <> 0) OR ? = 0)
                AND ((M_CityID = ? AND ? <> 0) OR ? = 0)
                ORDER BY M_VendorName ASC
                LIMIT {$limit} OFFSET {$offset}", [$d['vendor_name'], $d['vendor_name'], $d['vendor_name'], $d['vendor_name'], $d['province'], $d['province'], $d['province'], $d['city'], $d['city'], $d['city']]);
        if ($r)
        {
            $r = $r->result_array();
            foreach ($r as $k => $v)
            {
                $r[$k]['vendor_phones'] = json_decode($v['vendor_phones']);

                // banks
                $banks = $this->db->query("SELECT fn_master_vendor_get_banks(?) x", [$v['vendor_id']])->row();
                $r[$k]['banks'] = json_decode($banks->x);

                // addresses
                // $addresses = $this->db->query("SELECT fn_master_vendor_addresses(?) x", [$v['vendor_id']])->row();
                // $r[$k]['addresses'] = json_decode($addresses->x);
            }
                
            $l['records'] = $r;
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            LEFT JOIN m_kelurahan ON M_VendorM_KelurahanID = M_KelurahanID
                LEFT JOIN m_district ON M_VendorM_DistrictID = M_DistrictID
                LEFT JOIN m_city ON M_VendorM_CityID = M_CityID
                LEFT JOIN m_province ON M_CityM_ProvinceID = M_ProvinceID
            WHERE (`M_VendorName` LIKE ? OR M_VendorCode LIKE ? OR M_VendorAddress LIKE ? OR M_VendorPhones LIKE ?)
            AND `M_VendorIsActive` = 'Y'
            AND ((M_ProvinceID = ? AND ? <> 0) OR ? = 0)
                AND ((M_CityID = ? AND ? <> 0) OR ? = 0)", [$d['vendor_name'], $d['vendor_name'], $d['vendor_name'], $d['vendor_name'], $d['province'], $d['province'], $d['province'], $d['city'], $d['city'], $d['city']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }
            
        return $l;
    }

    function search_autocomplete( $d )
    {
        $d['limit'] = 25;
        $d['page'] = 1;
        $r = $this->search( $d );
        
        return $r['records'];
    }

    function search_old( $d )
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records'=>[], 'total'=>0, 'total_page'=>1];

        $r = $this->db->query(
                "SELECT M_VEndorID vendor_id, M_VendorName vendor_name
                FROM `{$this->table_name}`
                WHERE `M_VendorName` LIKE ?
                AND `M_VendorIsActive` = 'Y'
                LIMIT {$limit} OFFSET {$offset}", [$d['vendor_name']]);
        if ($r)
        {
            $l['records'] = $r->result_array();
        }

        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_VendorName` LIKE ?
            AND `M_VendorIsActive` = 'Y'", [$d['vendor_name']]);
        if ($r)
        {
            $l['total'] = $r->row()->n;
            $l['total_page'] = ceil($r->row()->n / $limit);
        }
            
        return $l;
    }

    function save ( $d )
    {
        $r = $this->db->query("CALL sp_master_vendor_save(?,?,?,?)", [
                isset($d['vendor_id'])?$d['vendor_id']:0, json_encode([
                'name'=>$d['vendor_name'],
                'address'=>$d['vendor_address'],
                // 'phone'=>$d['vendor_phone'],
                'phones'=>$d['vendor_phones'],
                'email'=>$d['vendor_email'],
                'postcode'=>$d['vendor_postcode'],
                'note'=>$d['vendor_note'],
                'postcode'=>$d['vendor_postcode'],
                'pic_name'=>$d['vendor_pic_name'],
                'pic_phone'=>$d['vendor_pic_phone'],
                'npwp'=>$d['vendor_npwp'],
                // 'prospect'=>isset($d['vendor_prospect'])?$d['vendor_prospect']:'N',
                // 'company'=>$d['vendor_type'],
                'city'=>isset($d['vendor_city_id'])?$d['vendor_city_id']:0,
                'district'=>isset($d['vendor_district_id'])?$d['vendor_district_id']:0,
                'kelurahan'=>isset($d['vendor_kelurahan_id'])?$d['vendor_kelurahan_id']:0
                // 'staff'=>isset($d['vendor_staff'])?$d['vendor_staff']:0
            ]), isset($d['bdata'])?$d['bdata']:'[]', 0
        ])->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        if ($r->status == "OK")
        {
            $r->data = json_decode($r->data);
            // $this->set_index($r->data->vendor_id);
        }

        return $r;
    }

    function save_old ( $d )
    {
        $r = $this->db->set('M_VendorName', $d['vendor_name'])
                    ->set('M_VendorCode', $d['vendor_code']);
                    // ->set('M_VendorUserID', $d['user_id']);
        if (isset($d['vendor_id']))
        {
            $this->db->where('M_VendorID', $d['vendor_id'])
                ->update( $this->table_name );
            $id = $d['vendor_id'];
        }
        else
        {
            $this->db->insert( $this->table_name );
            $id = $this->db->insert_id();
        }

        if ($r)
        {
            return (object) ["status"=>"OK", "data"=>$id];
        }

        return (object) ["status"=>"ERR"];
    }

    function del ($id)
    {
        $this->db->set('M_VendorIsActive', 'N')
                ->where('M_VendorID', $this->sys_input['id'])
                ->update($this->table_name);

        return true;
    }

    function get($id)
    {
        $r = $this->db->query(
            "SELECT M_VendorID vendor_id, M_VendorName vendor_name, '' city_name
            FROM `{$this->table_name}`
            
            WHERE `M_VendorID` = ?
            AND `M_VendorIsActive` = 'Y'", [$id])
            ->row();

        return $r;
    }
}

?>