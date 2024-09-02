<?php

class M_Packet extends MY_Model
{
    function __construct()
    {
        parent::__construct();

        $this->table_name = "m_salespacket";
        $this->table_key = "M_SalesPacketID";
    }

    function search($d)
    {
        $limit = isset($d['limit']) ? $d['limit'] : 10;
        $offset = ($d['page'] - 1) * $limit;
        $l = ['records' => [], 'total' => 0, 'total_page' => 1];

        // Query untuk mendapatkan data
        $r = $this->db->query(
            "SELECT 
                m.M_SalesPacketID AS packet_id, 
                m.M_SalesPacketName AS packet_name, 
                IFNULL(m.M_SalesPacketNote, '') AS packet_note,
                d.M_SalesPacketDetailM_TimelineID AS timeline_id
            FROM `{$this->table_name}` m
            JOIN m_salespacketdetail d 
                ON m.M_SalesPacketID = d.M_SalesPacketDetailM_SalesPacketID 
                AND d.M_SalesPacketDetailIsActive = 'Y'
            WHERE m.M_SalesPacketName LIKE ?
            AND m.M_SalesPacketIsActive = 'Y'
            ORDER BY m.M_SalesPacketName ASC
            LIMIT {$limit} OFFSET {$offset}",
            [$d['search']]
        );

        if ($r) {
            // Mengambil hasil query sebagai array
            $rows = $r->result_array();

            // Array untuk menyimpan hasil akhir
            $records = [];

            // Proses setiap baris hasil
            foreach ($rows as $row) {
                $packet_id = $row['packet_id'];

                // Jika packet_id belum ada di array hasil, inisialisasi array
                if (!isset($records[$packet_id])) {
                    $records[$packet_id] = [
                        'packet_id' => $packet_id,
                        'packet_name' => $row['packet_name'],
                        'packet_note' => $row['packet_note'],
                        'timeline' => [] // Inisialisasi array timeline
                    ];
                }

                // Tambahkan timeline_id ke array
                $records[$packet_id]['timeline'][] = $row['timeline_id'];
            }

            // Mengubah array hasil ke dalam format yang diinginkan
            $l['records'] = array_values($records);
        }

        // Query untuk menghitung total record
        $r = $this->db->query(
            "SELECT COUNT(`{$this->table_key}`) AS n
            FROM `{$this->table_name}`
            WHERE `M_SalesPacketName` LIKE ?
            AND `M_SalesPacketIsActive` = 'Y'",
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
        $r = $this->db->query("CALL sp_master_packet_save(?)", [json_encode($d)])->row();
        $this->clean_mysqli_connection($this->db->conn_id);
        if ($r->status == "OK")
            $r->data = json_decode($r->data);

        return $r;
    }
    function del($id)
    {
        $this->db->set('M_SalesPacketIsActive', 'N')
            ->where('M_SalesPacketID', $this->sys_input['id'])
            ->update($this->table_name);
        return true;
    }
}
