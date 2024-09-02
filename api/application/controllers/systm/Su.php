<?php

class Su extends MY_Controller
{
    public $pattern;

    function __construct()
    {
        parent::__construct();
    }

    function index()
    {
        return;
    }

    function get_not_received()
    {
        $t = $this->db->get('tmp_received')
                    ->row();
        if ($t)
        {
            $r = $this->db->select('M_ExpeditionROCode, W_CourierReceiptNo', false)
                ->join('l_so', 'W_CourierL_SoID = L_SoID')
                ->join('m_expedition', 'L_SoM_ExpeditionID = M_ExpeditionID')
                ->where('W_CourierID', $t->wh_id)
                ->get('w_courier')
                ->row();
        
            $this->db->where('wh_id', $t->wh_id)
                ->delete('tmp_received');

                $curl = curl_init();
                curl_setopt_array($curl, array(
                    CURLOPT_URL => $this->RO_URL."waybill",
                    CURLOPT_RETURNTRANSFER => true,
                    CURLOPT_ENCODING => "",
                    CURLOPT_MAXREDIRS => 10,
                    CURLOPT_TIMEOUT => 30,
                    CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
                    CURLOPT_CUSTOMREQUEST => "POST",
                    CURLOPT_POSTFIELDS => "waybill={$r->W_CourierReceiptNo}&courier={$r->M_ExpeditionROCode}",
                    CURLOPT_HTTPHEADER => array(
                    "content-type: application/x-www-form-urlencoded",
                    "key: ".$this->RO_KEY
                    ),
                ));
        
                $response = curl_exec($curl);
                $err = curl_error($curl);
        
                curl_close($curl);
                
                if ($err) {
                    echo "cURL Error #:" . $err;
                } else {
                    $x = json_decode($response);
                    $y = $x->rajaongkir->result;

                    if ($y != null)
                    {
                        echo "{$r->W_CourierReceiptNo} - {$r->M_ExpeditionROCode} - success";
                        if (isset($y->delivered))
                        {
                            if ($y->delivered == true)
                            {
                                $this->db->query("call sp_wh_receive(?)", $t->so_id);
                            }
                        }
                    }
                    else
                    {
                        echo "invalid waybill";
                    }
                }

            
        }
    }
}

?>