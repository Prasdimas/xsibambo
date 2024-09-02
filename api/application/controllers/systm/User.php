<?php

class User extends MY_Controller
{
    public $pattern;

    function __construct()
    {
        parent::__construct();

        $this->load->model('system/s_user');
        $this->pattern = [
            "%f%s", "%f.%s", "%s%f", "%s.%f", "%f%t", "%s%t", "%t%f", "%t%s", "%f.%t", "%s.%t", "%t.%f", "%t.%s", "%f%c", "%f.%c", "%s%c", "%s.%c", "%t%c", "%t.%c", "%c%f", "%c.%f", "%f%y", "%f%s%y", "%f.%y", "%f%s.%y", "%f.%s.%y", "%s%y", "%s.%y", "%f%c.%y", "%f.%c.%y", "%f.%y.%c"
        ];
    }

    function index()
    {
        return;
    }
    function search()
    {
        $r = $this->s_user->search(['search' => '%', 'gid' => $this->sys_input['group_id']]);
        $this->sys_ok($r);
    }
    function get_users()
    {
        $r = $this->s_user->get_user([
            'search' => '%' . $this->sys_input['search'] . '%',
            'limit' => 99999,
            'page' => 1
        ]);
        $this->sys_ok($r);
    }

    function search_by_group_code()
    {
        $this->load->model('system/s_usergroup');
        $g = $this->s_usergroup->get_by_code($this->sys_input['group_code']);

        $r = $this->s_user->search(['search' => '%', 'gid' => $g->S_UserGroupID]);
        $this->sys_ok($r);
    }

    function login()
    {
        $r = $this->s_user->login(
            $this->sys_input['username'],
            $this->sys_input['password']
        );

        if ($r->status == "OK") {
            $user = (array) json_decode($r->data);
            $user['ip'] = $_SERVER['REMOTE_ADDR'];
            $user['agent'] = $_SERVER['HTTP_USER_AGENT'];
            $token  = JWT::encode($user, $this->SECRET_KEY);

            $data = array(
                "user" => $user,
                "token" => $token
            );

            $this->sys_ok($data);
        } else {
            $this->sys_error($r->message);
        }
    }

    function logout()
    {
        $prm = $this->sys_input;
        try {
            $this->s_user->logout($this->sys_user['user_id']);
            $this->sys_ok("OK");
        } catch (Exception $exc) {
            $message = $exc->getMessage();
            $this->sys_error($message);
        }
    }

    function save_profile()
    {
        $r = $this->s_user->save_profile($this->sys_input, $this->sys_user['user_id']);
        echo json_encode($r);
    }

    function get_profile()
    {
        $r = $this->s_user->get_profile($this->sys_user['user_id']);
        $this->sys_ok($r);
    }

    function save_password()
    {
        $d = $this->sys_input;
        // $d['user_name'] = $this->sys_user['user_name'];
        $r = $this->s_user->save_password($this->sys_user['user_id'], $d);

        if ($r->status == 'OK')
            $this->sys_ok($r->data);
        else
            $this->sys_error($r->message);
    }

    function save()
    {
        $d = $this->sys_input;
        $r = $this->s_user->save($d);

        if ($r->status == 'OK')
            $this->sys_ok(true);
        else
            $this->sys_error($r->message);
    }

    function check()
    {
        $d = $this->sys_input;
        $r = $this->s_user->check($d);

        if ($r->status == 'OK')
            $this->sys_ok(true);
        else
            $this->sys_error($r->message);
    }

    function del()
    {
        $d = $this->sys_input;
        $r = $this->s_user->del($d);

        $this->sys_ok(true);
    }

    function gen_user()
    {
        $name = strtolower($this->sys_input['name']);
        $names = explode(' ', $name);
        $n = sizeof($names);
        $city = 'bogor';

        $namess = [];
        foreach ($this->pattern as $k => $v) {
            $second = isset($names[1]) ? $names[1] : '';
            $third = isset($names[2]) ? $names[2] : '';
            $v = preg_replace(["/(\%f)/", "/(\%s)/", "/(\%t)/", "/(\%c)/", "/(\%y)/"], [$names[0], $second, $third, $city, date('Y')], $v);

            if (substr($v, -1) == '.' || substr($v, 0, 1) == '.')
                continue;
            if ($v == $city || $v == date('Y'))
                continue;
            if (!in_array($v, $namess))
                $namess[] = $v;
        }

        foreach ($namess as $k => $v) {
            echo $v . '<br>';
        }
        return;
        foreach ($this->p[$n] as $k => $v) {
            $e = str_split($v);
            $tmp = [];
            foreach ($e as $l => $w) {
                $tmp[] = $names[$w];
            }

            foreach ($dels as $kd => $del) {
                $tmpx = join($del, $tmp);
                if (!in_array($tmpx, $this->restricted))
                    $namess[] = $tmpx;
            }
        }


        foreach ($namess as $k => $v)
            echo $v . '<br>';
        // if ($n > 1)
        // {
        //     if ($n >= 2)
        //     {
        //         $names2 = array_slice($names, 0, 2);
        //         $n2 = sizeof($names2);

        //         $r = $this->permutes(2, $names);
        //     }
        // }

        // print_r($r);
        // for ($i=n-1;$i>=0;$i--)
        // {

        // }

    }

    /** 
     * permutation function 
     * @param str string to  
     *  calculate permutation for 
     * @param l starting index 
     * @param r end index 
     */
    function permute($str, $l, $r)
    {
        if ($l == $r) {
            echo $str . "\n";
            $this->permutex[] = $str;
        } else {
            for ($i = $l; $i <= $r; $i++) {
                $str = $this->swap($str, $l, $i);
                $this->permute($str, $l + 1, $r);
                $str = $this->swap($str, $l, $i);
            }
        }
    }

    /** 
     * Swap Characters at position 
     * @param a string value 
     * @param i position 1 
     * @param j position 2 
     * @return swapped string 
     */
    function swap($a, $i, $j)
    {
        $temp;
        $charArray = str_split($a);
        $temp = $charArray[$i];
        $charArray[$i] = $charArray[$j];
        $charArray[$j] = $temp;
        return implode($charArray);
    }

    function permutes($x, $arr_name, $del = '')
    {
        $arr = [];
        $namess = [];
        for ($i = 0; $i < $x; $i++) {
            $arr[] = $i;
        }
        // $this->permute(join('', $arr), 0, $x-1);
        $this->permute("012", 0, 1);

        foreach ($this->permutex as $k => $v) {
            $e = str_split($v);
            $names = [];
            foreach ($e as $kk => $vv)
                $names[] = $arr_name[$vv];
            $namess[] = implode($del, $names);
        }

        return $namess;
    }
}
