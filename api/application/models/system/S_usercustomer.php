<?php

class S_usercustomer extends MY_Model
{
    public $pattern;

    function __construct()
    {
        parent::__construct();

        $this->table_name = "s_usercustomer";
        $this->table_key = "S_UserCustomerID";
        $this->pattern = [
            "%f%s","%f.%s","%s%f","%s.%f","%f%t","%s%t","%t%f","%t%s","%f.%t","%s.%t","%t.%f","%t.%s","%f%c","%f.%c","%s%c","%s.%c","%t%c","%t.%c","%c%f","%c.%f","%f%y","%f%s%y","%f.%y","%f%s.%y","%f.%s.%y","%s%y","%s.%y","%f%c.%y","%f.%c.%y","%f.%y.%c"
        ];
    }

    function gen_user ($name, $city)
    {
        $name = strtolower($name);
        $names = explode(' ', $name);
        $n = sizeof($names);

        $namess = [];
        foreach ($this->pattern as $k => $v)
        {
            $second = isset($names[1])?$names[1]:'';
            $third = isset($names[2])?$names[2]:'';
            $v = preg_replace(["/(\%f)/","/(\%s)/","/(\%t)/","/(\%c)/","/(\%y)/"], [$names[0],$second,$third,$city,date('Y')], $v);
            
            if (substr($v, -1) == '.' || substr($v, 0, 1) == '.')
                continue;
            if ($v ==$city || $v == date('Y'))
                continue;
            if (!in_array($v, $namess))
                $namess[] = $v;
        }
        
        return $namess;
    }

    function grant_user($customer_id, $name, $city, $pwdx = '', $email = false, $email_addr = '')
    {
        if ($pwdx == '')
            $pwdx = $this->gen_pwd();

        $username = json_encode($this->gen_user($name, $city));
        $pwd = md5($this->pass_prefix . $pwdx . $this->pass_suffix);

        $x = $this->db->query("CALL sp_system_user_customer_create_2(?, ?, ?)", [$customer_id, $username, $pwd])
                ->row();
        $this->clean_mysqli_connection($this->db->conn_id);

        if ($x->status == "OK")
        {
            $data = json_decode($x->data);

            // INSERT INTO EMAIL ZALFA
            if ($email)
            {
                $this->load->model('system/s_emailschedule');
                $vw = $this->load->view('mail/usercustomer', ['user'=>$data->user_name,'password'=>$pwdx], true);
                $this->s_emailschedule->save([
                            'type'=>'USERCUSTOMER',
                            'address'=> $email_addr == '' ? 'heriabunizar@gmail.com' : $email_addr,
                            'subject'=>"Username Untuk Akun Zalfa Anda",
                            // 'content'=>"Username : {$data->user_name}<br>Password : {$pwdx}"
                            'content'=>$vw
                            ]);
            }
        }

        return $x;
    }

    function gen_pwd() 
    {
        $alphabet = "abcdefghijkm#@nopqrstuwx!!yzABCDEFG2HJKL34MNPQR56STUWXYZ23456789#!@";
        $pass = array(); //remember to declare $pass as an array
        $alphaLength = strlen($alphabet) - 1; //put the length -1 in cache
        for ($i = 0; $i < 8; $i++) {
            $n = rand(0, $alphaLength);
            $pass[] = $alphabet[$n];
        }

        return implode($pass); //turn the array into a string
    }
}

?>