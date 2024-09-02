<?php

class MY_Model extends CI_Model
{
    public $table_name;
    public $table_key;

    public $pass_prefix = "HR15";
    public $pass_suffix = "One!123";

    public $balance_year = "2023";

    function __construct()
    {
        parent::__construct();

        $this->load->database();
    }

    public function clean_mysqli_connection( $dbc )
    {
        while( mysqli_more_results($dbc) )
        {
            if(mysqli_next_result($dbc))
            {
                $result = mysqli_use_result($dbc);

                unset($result);
            }
        }
    }

    function GetMultipleQueryResult($queryString, $queryCount)
    {
        if (empty($queryString)) {
                    return false;
                }

        $index     = 0;
        $ResultSet = array();

        /* execute multi query */
        if (mysqli_multi_query($this->db->conn_id, $queryString)) {
            for ($i=0; $i<$queryCount; $i++) {
                if (false != $result = mysqli_store_result($this->db->conn_id)) {
                    $rowID = 0;
                    while ($row = $result->fetch_assoc()) {
                        $ResultSet[$index][$rowID] = $row;
                        $rowID++;
                    }
                    mysqli_free_result($result);
                }
                $index++;
                mysqli_next_result($this->db->conn_id);
            }
        }

        $this->clean_mysqli_connection( $this->db->conn_id );
        return $ResultSet;
    }

    public function qSelect($col_prefix, $replacement, $columns)
    {
        $r = [];
        foreach ($columns as $k => $v) {
            $s = $col_prefix.$v;
            $r[] = $s.' '.strtolower(str_replace($col_prefix, $replacement, $s));
        }

        return $r;
    }
}


?>