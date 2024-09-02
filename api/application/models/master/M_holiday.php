<?php

class M_holiday extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_holiday";
        $this->table_key = "M_HolidayID";

        // type : L : Libur Pekanan, B: Cuti Bersama, M : Tanggal Merah
        // date
        // name
    }

    function search($d, $scalar = false)
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records' => [], 'total' => 0, 'total_page' => 1];
        $min_date = isset($d['min_date']) ? date('Y-m-d', strtotime($d['min_date'])) : '2024-01-01';

        $r = $this->db->query(
            "SELECT M_HolidayID holiday_id, M_HolidayType holiday_type, M_HolidayName holiday_name, M_HolidayDate holiday_date,
                    IFNULL(M_DayNameLocalized, '') day_name, IFNULL(M_MiscValue, '') type_name
                FROM `{$this->table_name}`
                LEFT JOIN m_day ON M_HolidayM_DayID = M_DayID
                LEFT JOIN m_misc ON M_HolidayType = M_MiscKey AND M_MiscCode = 'HOLIDAY.TYPE' AND M_MiscIsActive = 'Y'
                WHERE `M_HolidayName` LIKE ?
                AND `M_HolidayIsActive` = 'Y' 
                AND ((year(M_HolidayDate) = ? AND ? <> \"\") OR ? = \"\")
                AND M_HolidayDate >= ?
                ORDER BY M_HolidayDate asc
                LIMIT {$limit} OFFSET {$offset}",
            [$d['search'], $d['year'], $d['year'], $d['year'], $min_date]
        );
        if ($r) {
            $l['records'] = $r->result_array();

            // quota
            $this->load->model('master/m_misc');
            $quota = $this->m_misc->get_by_key('HOLIDAY.QUOTA', $d['year']);
            $l['holiday_quota'] = !!$quota ? $quota : 0;
        }

        // count by type
        // $r = $this->db->query(
        //     "SELECT count(`{$this->table_key}`) cnt, M_MiscKey type_id, M_MiscValue type_name
        //         FROM m_misc 
        //         LEFT JOIN {$this->table_name} ON M_HolidayType = M_MiscKey 
        //             AND ((year(M_HolidayDate) = ? AND ? <> \"\") OR ? = \"\")
        //             AND M_HolidayIsActive = 'Y' AND M_HolidayDate >= ?
        //     WHERE M_MiscCode = 'HOLIDAY.TYPE' AND M_MiscIsActive = 'Y'
        //     GROUP BY M_MiscKey", [$d['year'], $d['year'], $d['year'], $min_date])->result_array();

        // $l['types'] = $r;

        $r = $this->db->query(
            "SELECT COUNT(`{$this->table_key}`) AS cnt, M_MiscKey AS type_id, M_MiscValue AS type_name
            FROM m_misc 
            LEFT JOIN {$this->table_name} ON M_HolidayType = M_MiscKey 
                AND ((YEAR(M_HolidayDate) = ? AND ? <> \"\") OR ? = \"\")
                AND M_HolidayIsActive = 'Y' AND M_HolidayDate >= ?
            WHERE M_MiscCode = 'HOLIDAY.TYPE' AND M_MiscIsActive = 'Y'
            GROUP BY M_MiscKey, M_MiscValue",
            [$d['year'], $d['year'], $d['year'], $min_date]
        )->result_array();

        $l['types'] = $r;



        // count all
        $cnt = $this->count($d['year'], "", $d['search']);
        $l['total'] = $cnt;
        $l['total_page'] = ceil($cnt / $limit);

        if ($scalar) {
            $holis = [];
            foreach ($l['records'] as $k => $v) $holis[] = $v['holiday_date'];
            return $holis;
        }

        return $l;
    }

    function count($year, $type = "", $search = "%")
    {
        $r = $this->db->query(
            "SELECT count(`{$this->table_key}`) n
            FROM `{$this->table_name}`
            WHERE `M_HolidayName` LIKE ? 
                AND ((`M_HolidayType` = ? AND ? <> '') OR ? = '') 
                AND year(M_HolidayDate) = ?
            AND `M_HolidayIsActive` = 'Y'",
            [$search, $type, $type, $type, $year]
        );

        if ($r)
            return $r->row()->n;

        return 0;
    }

    function save($d, $id = 0)
    {
        // Start a transaction
        $this->db->trans_start();

        try {

            $data = array(
                'M_HolidayDate' => $d['holiday_date'],
                'M_HolidayName' => $d['holiday_name'],
                'M_HolidayType' => $d['holiday_type'],
                // Add more columns and values as needed
            );

            if ($id == 0) {
                $this->db->insert($this->table_name, $data);
                $id = $this->db->insert_id();
            } else {
                $this->db->where($this->table_key, $id)
                    ->update($this->table_name, $data);
            }

            // Commit the transaction
            $this->db->trans_complete();

            // Check if the transaction was successful
            if ($this->db->trans_status() === FALSE) {
                // If something went wrong, rollback the transaction
                $this->db->trans_rollback();
                $r = ['status' => 'ERR', 'message' => 'Transaction failed !'];
            } else {
                // If everything is successful, commit the transaction
                $this->db->trans_commit();
                $r = ['status' => 'OK', 'message' => 'Transaction successfull !', 'data' => ['holiday_id' => $id]];
            }
        } catch (Exception $e) {
            // Rollback the transaction
            $this->db->trans_rollback();
            // Handle exceptions
            $r = ['status' => 'ERR', 'message' => $e->getMessage()];
        }

        return json_decode(json_encode($r));
    }

    function set_weekly_holiday($year, $workday)
    {
    }

    function del($id)
    {
        $this->db->set('M_HolidayIsActive', 'N')
            ->where('M_HolidayID', $this->sys_input['id'])
            ->update($this->table_name);

        return true;
    }
}
