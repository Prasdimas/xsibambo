<?php

class MY_Controller extends CI_Controller
{
    public $sys_input;
    public $is_login;

    public $SECRET_KEY = "--one-secret-1924";
    public $RO_KEY = "bd505a3f96a95686f7ac2775e43a37fa";
    public $RO_URL = "https://pro.rajaongkir.com/api/";

    public $IPAYMU_KEY = "HWuK5V6Q9GRbAzoCG2tDbfbr4OBxk.";
    public $IPAYMU_URL = "https://my.ipaymu.com/api/";
    public $IPAYMU_URL2 = "https://api.ipaymu.com/api/";

    public $MEMBER_URL = "http://register.zalfa.id/";

    public $APP_MAIL_PASSWORD = "kjvwquzhbprhiebr";

    public $YOUTUBE_V3_API = "AIzaSyAnX9izL8bUOhs85CqGldFXwKHssKle01w";
    public $YOUTUBE_V3_URL = "https://www.googleapis.com/youtube/v3/videos";

    public $GOOGLE_MAP_API = "AIzaSyD6TGR2oXEvU_diB_guxu-DuaLp7Qfh5Vc";

    public $REPORT_EXCEL_URL;

    function __construct()
    {
        parent::__construct();
        
        $this->load->library("Jwt");
        $this->load->database();

        if ($_SERVER['SERVER_NAME'] == '127.0.0.1')
            $this->REPORT_EXCEL_URL = "http://{$_SERVER['SERVER_NAME']}:8080/one-account-ady/uploads/reports/";
        else
            $this->REPORT_EXCEL_URL = "https://{$_SERVER['SERVER_NAME']}/uploads/reports/";

        $this->sys_input = json_decode($this->input->raw_input_stream, true);
        if (! $this->sys_input ) {
            if ( count($this->input->post()) > 0 ) {
                $this->sys_input = $this->input->post();
            } else {
                $this->sys_input = $this->input->get();
            }
        }

        // CHECK USER TOKEN
        try {
            $prm  = $this->sys_input;
            if (! isset($prm["token"])) {
               $this->is_login = false;
            } else {
               $user = JWT::decode($prm["token"],$this->SECRET_KEY,true);
               unset($this->sys_input["token"]);
               $user = json_decode(json_encode($user),true);
               
               if (!isset($user["user_id"])) die($this->sys_error("User not created !"));
            //    var_dump($user);
               if ($user["user_id"] > 0 ) {
                  $this->is_login = true;
               }
               $this->sys_user = $user;
               $query = $this->db->query("update s_user SET S_UserLastLogin = now() WHERE S_UserID = ?", array($user["user_id"]));
               if (!$query) {
                 $message = $this->db->error();
                 $this->sys_error($message);
                 exit;
               }
               //update last accessed 
            }
        } catch(Exception $e) {
            $this->is_login = false;
        }
    }

    public function sys_ok($data) {
        echo json_encode(
           array(
              "status" => "OK",
              "data" => $data
           )
        );
    }

    public function sys_error($message) {
        echo json_encode(
           array(
              "status" => "ERR",
              "message" => $message
           )
        );
    }

    public function sys_output($r) {
        if ($r->status == "OK")
            return $this->sys_ok(json_decode($r->data));

        return $this->sys_error($r->message);
    }

    public function base64_to_jpeg($base64_string, $output_file) {
        // open the output file for writing
        $ifp = fopen( $output_file, 'wb' ); 
    
        // split the string on commas
        // $data[ 0 ] == "data:image/png;base64"
        // $data[ 1 ] == <actual base64 string>
        $data = explode( ',', $base64_string );
    
        // we could add validation here with ensuring count( $data ) > 1
        fwrite( $ifp, base64_decode( $data[ 1 ] ) );
    
        // clean up the file resource
        fclose( $ifp ); 
    
        return $output_file; 
    }

    public function phone_format($phone)
    {
        $x = false;
        $matches = ["/^\+/"];
        foreach ($matches as $k => $v)
            if (!$x) $x = preg_match($v, $phone);

        if (!$x && preg_match("/^08/", $phone))
            return "+62 ".substr($phone, 1);

        if (!$x)
            return "+62 ".$phone;

        return $phone;
    }

    public function getRelativeTime($datetime) 
    {
        $currentDateTime = new DateTime();
        $givenDateTime = new DateTime($datetime);

        $interval = $currentDateTime->diff($givenDateTime);

        $minutes = $interval->i;
        $hours = $interval->h;
        $days = $interval->d;

        if ($interval->y == 0 && $interval->m == 0) {
            if ($days == 0 && $hours == 0) {
                if ($minutes < 60) {
                    return "$minutes menit" . ($minutes > 1 ? '' : '') . ' ';
                } else {
                    return "$hours jam" . ($hours > 1 ? '' : '') . ' ';
                }
            } elseif ($days == 0 && $hours >= 1 && $hours <= 11) {
                return "$hours jam" . ($hours > 1 ? '' : '') . ' ';
            } elseif ($days == 0 && $hours > 11) {
                return 'hari ini';
            } elseif ($days >= 1 && $days <= 6) {
                return "$days hari" . ($days > 1 ? '' : '') . ' ';
            } elseif ($days >= 7 && $days <= 27) {
                $weeks = floor($days / 7);
                return "$weeks minggu" . ($weeks > 1 ? '' : '') . ' ';
            }
        }

        // If none of the conditions are met, return the actual date
        return $givenDateTime->format('Y-m-d H:i:s');
    }

    public function dateDiff($date1, $date2 = null) {
        if (!$date2) $date2 = date('Y-m-d');
        if (!$date1) return [0, 0, 0];
        
        // Create DateTime objects from the input dates
        $datetime1 = new DateTime($date1);
        $datetime2 = new DateTime($date2);
    
        // Calculate the difference
        $interval = $datetime1->diff($datetime2);
    
        // Extract the difference in years, months, and days
        $years = $interval->y;
        $months = $interval->m;
        $days = $interval->d;
    
        // Return the difference as an array
        return [$years, $months, $days];
    }
}

class RPT_Controller extends MY_Controller
{
    public $data_phone;
    public $data_email;

    function __construct()
    {
        parent::__construct();

        $this->load->library('pdf');
        $this->data_phone = '+62 8132259 9149';
        $this->data_email = 'adywater@gmail.com';
    }

    public static function my_header($me, $title = 'anu', $desc = 'asd', $orientation = 'P')
    {
        $width = $orientation == 'P' ? 19 : 28;
        $cp = 'me->company';
        $me->pdf->SetFont('Arial', 'B', 13);
        $gy = $me->pdf->GetY();

        $me->pdf->Image(base_url() . '/assets/images/logo-mph.png', 0.8, 0.7, 3);

        $me->pdf->SetY($gy+0.5);
        $me->pdf->SetFont('Arial', '', 18);
        $me->pdf->Cell($width, 0.5, $title, '', 1, 'R');
        
        $me->pdf->SetFont('Arial', '', 11);
        $me->pdf->Cell($width, 0.7, $desc, 'B', 1, 'R');
        $me->pdf->Ln(1);
    }

    public function my_header_a5($me, $title = 'anu', $desc = 'asd', $orientation = 'L', $margins = [0.7,0.7,0.7])
    {
        $width = $me->pdf->w - $me->pdf->lMargin - $me->pdf->rMargin;
        $cp = 'me->company';
        $me->pdf->SetFont('Arial', 'B', 13);
        $gy = $me->pdf->tMargin;

        $me->pdf->Image(base_url() . '/assets/images/logo-mph.png', $me->pdf->lMargin+0.5, $me->pdf->tMargin+0.5, 2);
        // $rtt = new PDF_Rotate();
        // $me->pdf->RotatedImage(base_url() . '/assets/images/logo-mph.png', $me->pdf->lMargin+0.5+2, $me->pdf->tMargin+0.5+2, 2, 2, 180);

        // blank columns
        $row_first = 2.5;
        $row_small = 0.5;
        $me->pdf->SetY($gy);
        $me->pdf->Cell(3, $row_first, '', 'RB', 0, 'R');
        $me->pdf->Cell($width-7, $row_first, '', 'RB', 0, 'R');
        $me->pdf->Cell(4, $row_first, '', 'B', 0, 'R');
        $me->pdf->SetY($gy+$row_first);

        $me->pdf->SetY($gy+0.5);
        $me->pdf->SetFont('Arial', '', 18);
        $me->pdf->Cell($width-4, 0.5, '', '', 0, 'R');
        $me->pdf->MultiCell(4, 0.7, $title, '', 'C');

        $me->pdf->SetFont('Arial', 'B', 14);
        $me->pdf->SetY($gy);
        $me->pdf->SetX($margins[0]+3.3);
        $me->pdf->Cell($width-6, 0.5, 'CV. Ady Water', '', 0, 'L');

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($gy+0.5);
        $me->pdf->SetX($margins[0]+3.3);       
        $me->pdf->Write(0.5,'Office : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,'Jl. Mande Raya No. 26 Cikadut Cicaheum Bandung');

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($gy+0.85);
        $me->pdf->SetX($margins[0]+3.3);       
        $me->pdf->Write(0.5,'Jakarta 1 : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,'Jl. Kemanggisan Pulo I No. 6 Palmerah Jakarta Barat');

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($gy+1.2);
        $me->pdf->SetX($margins[0]+3.3);       
        $me->pdf->Write(0.5,'Jakarta 2 : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,'Jl. Tanah Merdeka No. 80B RT 15 / RW 05 Rambutan, Ciracas Jakarta Timur');

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($gy+1.55);
        $me->pdf->SetX($margins[0]+3.3);       
        $me->pdf->Write(0.5,'Phone / Fax : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,'+62(22) 7238019');
        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->Write(0.5,' Mobile Phone : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,isset($me->pdf->hdr_data['phone'])?$me->pdf->hdr_data['phone']:$this->data_phone);

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($gy+1.95);
        $me->pdf->SetX($margins[0]+3.3);       
        $me->pdf->Write(0.5,'Email : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,isset($me->pdf->hdr_data['email'])?$me->pdf->hdr_data['email']:$this->data_email);
        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->Write(0.5,' Website : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,'https://adywater.com');

        $me->pdf->SetY($row_first+$margins[1]);
        $me->pdf->SetX($margins[0]);
    }

    public static function my_header_recapt($me)
    {
        $width = $me->pdf->w - $me->pdf->lMargin - $me->pdf->rMargin;
        $me->pdf->SetFont('Arial', 'B', 13);

        $me->pdf->Image(base_url() . '/assets/images/logo-mph.png', $me->pdf->lMargin, $me->pdf->tMargin, 1.5);

        $me->pdf->SetY($me->pdf->tMargin);
        $me->pdf->SetFont('Arial', '', 18);
        $me->pdf->Cell($width, 0.5, $me->pdf->rpt_title, '', 1, 'R');
        
        $me->pdf->SetFont('Arial', '', 11);
        $me->pdf->Cell($width, 0.7, $me->pdf->rpt_subtitle, 'B', 1, 'R');
        $me->pdf->Ln(0.2);
    }

    public static function my_header_offer($me)
    {
        $width = $me->pdf->w - $me->pdf->lMargin - $me->pdf->rMargin;
        $me->pdf->SetFont('Arial', 'B', 13);
        $hdr_data = $me->pdf->hdr_data;

        $me->pdf->Image(base_url() . '/assets/images/logo-ady-water-divider.png', $me->pdf->lMargin, $me->pdf->tMargin, 4, 3.34);
        $me->pdf->Image(base_url() . '/assets/images/kop-01.png', ($me->pdf->w-6.4), 0, 6.4, 6);
        $me->pdf->RotatedImage(base_url() . '/assets/images/kop-01.png', 6.4, ($me->pdf->h), 6.4, 6, 180);

        // $me->pdf->SetY($me->pdf->tMargin);
        // $me->pdf->SetFont('Arial', '', 18);
        // $me->pdf->Cell($width, 0.5, $me->pdf->rpt_title, '', 1, 'R');
        
        // $me->pdf->SetFont('Arial', '', 11);
        // $me->pdf->Cell($width, 0.7, $me->pdf->rpt_subtitle, 'B', 1, 'R');
        // $me->pdf->Ln(0.2);

        $ltm = 4.5;
        $me->pdf->SetFont('Arial', 'B', 16);
        $me->pdf->SetY($me->pdf->tMargin);
        $me->pdf->SetX($me->pdf->lMargin+$ltm);
        $me->pdf->Cell($me->pdf->w-6, 0.5, 'CV. ADY WATER', '', 0, 'L');

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($me->pdf->tMargin+0.7);
        $me->pdf->SetX($me->pdf->lMargin+$ltm);       
        $me->pdf->Write(0.5,'Office : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,'Jl. Mande Raya No. 26 Cikadut Cicaheum Bandung');

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($me->pdf->tMargin+1.05);
        $me->pdf->SetX($me->pdf->lMargin+$ltm);       
        $me->pdf->Write(0.5,'Jakarta 1 : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,'Jl. Kemanggisan Pulo I No. 6 Palmerah Jakarta Barat');

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($me->pdf->tMargin+1.4);
        $me->pdf->SetX($me->pdf->lMargin+$ltm);       
        $me->pdf->Write(0.5,'Jakarta 2 : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,'Jl. Tanah Merdeka No. 80B RT 15 / RW 05 Rambutan, Ciracas Jakarta Timur');

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($me->pdf->tMargin+2);
        $me->pdf->SetX($me->pdf->lMargin+$ltm);       
        $me->pdf->Write(0.5,'Phone / Fax : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,'+62(22) 7238019');
        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->Write(0.5,' Mobile Phone : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,isset($hdr_data['phones'])?$hdr_data['phones']:'-');

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($me->pdf->tMargin+2.4);
        $me->pdf->SetX($me->pdf->lMargin+$ltm);       
        $me->pdf->Write(0.5,'Email : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5, isset($hdr_data['email'])?$hdr_data['email']:'adywater@gmail.com');

        $me->pdf->SetFont('Arial', 'B', 8);
        $me->pdf->SetY($me->pdf->tMargin+2.8);
        $me->pdf->SetX($me->pdf->lMargin+$ltm);
        $me->pdf->Write(0.5,'Website : ');
        $me->pdf->SetFont('Arial', '', 8);
        $me->pdf->Write(0.5,'https://adywater.com');

        $me->pdf->Image(base_url() . '/assets/images/logo-adywater-watermark.png', ($me->pdf->w-12)/2, ($me->pdf->h-7.4)/2, 12, 7.4);

        $me->pdf->SetX($me->pdf->lMargin);
        $me->pdf->SetY(4.5);

    }

    public static function my_footer($me)
    {
        $width = $me->pdf->w - $me->pdf->lMargin - $me->pdf->rMargin;
        $r_code = '';
        if (isset($me->report_code))
        $r_code = $me->report_code . ' | ';

        $me->pdf->SetY(-1);
        $me->pdf->SetFont('Arial', 'I', 8);
        $me->pdf->Cell($width/2, 1, $r_code . 'Printed on ' . date('d-m-Y H:i:s') . '', 'T', 0, 'L');
        $me->pdf->Cell($width/2, 1, "Page {$me->pdf->PageNo()} from {nb}", 'T', 1, 'R');
    }

    public static function my_footer_offer($me)
    {
        $width = $me->pdf->w - $me->pdf->lMargin - $me->pdf->rMargin;
        // $me->pdf->RotatedImage(base_url() . '/assets/images/kop-01.png', 6.4, ($me->pdf->h), 6.4, 6, 180);
    }

    public static function my_watermark($me)
    {
        $width = $me->pdf->w - $me->pdf->lMargin - $me->pdf->rMargin;
        // $me->pdf->Image(base_url() . '/assets/images/kop-02.png', ($me->pdf->w-4)/2, ($me->pdf->h-2.8)/2, 4, 2);
        $me->pdf->Image(base_url() . '/assets/images/kop-02.png', 5, 2, 4, 2);
    }
}


?>