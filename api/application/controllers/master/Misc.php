<?php

class Misc extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('master/m_misc');
    }

    function search_dd()
    {
        $r = $this->m_misc->search_dd($this->sys_input['misc_code']);

        $this->sys_ok($r);
    }

    function save_by_key()
    {
        $d = $this->sys_input;
        $r = $this->m_misc->save_by_key($d['misc_code'], $d['misc_key'], $d['misc_value']);

        $this->sys_ok($r);
    }

    function add_workdays() {

        $d = $this->sys_input;
        $start_date = $d['sdate']; 
        $workdays_to_add = $d['addition'];

        // search holidays
        $this->load->model('master/m_holiday');
        $holidays = $this->m_holiday->search(['limit'=>$workdays_to_add+1,'page'=>1,'min_date'=>$start_date,'search'=>'%','year'=>""], true);

        // search workday
        $this->load->model('master/m_workday');
        $workdays = $this->m_workday->search([], true);
        
        $current_date = DateTime::createFromFormat('Y-m-d', $start_date);
        $added_days = 0;
    
        // Convert holidays array to DateTime objects for easier comparison
        $holiday_dates = array_map(function($holiday) {
            return DateTime::createFromFormat('Y-m-d', $holiday);
        }, $holidays);
        
        while ($added_days < $workdays_to_add) {
            // Increment the current date by one day
            $current_date->modify('+1 day');
            
            // Check if the current date is a weekend (Saturday=6, Sunday=0) or a holiday
            if ($this->is_workday($current_date, $workdays) && !$this->is_holiday($current_date, $holiday_dates)) {
            // if ($current_date->format('N') < 6 && !$this->is_holiday($current_date, $holiday_dates)) {
                $added_days++;
            }
        }
    
        $this->sys_ok($current_date->format('Y-m-d'));
    }
    
    function diff_workday()
    {
        $d = $this->sys_input;
        $start_date = new DateTime($d['sdate']);
        $end_date = new DateTime($d['edate']);
        $diff = 0;

        // search holidays
        $this->load->model('master/m_holiday');
        $holidays = $this->m_holiday->search(['limit'=>100,'page'=>1,'min_date'=>$start_date->format('Y-m-d'),'search'=>'%','year'=>""], true);

        // search workday
        $this->load->model('master/m_workday');
        $workdays = $this->m_workday->search([], true);

        // Convert holidays array to DateTime objects for easier comparison
        $holiday_dates = array_map(function($holiday) {
            return DateTime::createFromFormat('Y-m-d', $holiday);
        }, $holidays);

        if ($start_date < $end_date) {
            while ($start_date < $end_date) {
                $start_date->modify('+1 day');
    
                // Check if the current date is a weekend (Saturday=6, Sunday=0) or a holiday
                if ($start_date == $end_date) $diff++;
                else if ($this->is_workday($start_date, $workdays) && !$this->is_holiday($start_date, $holiday_dates)) {
                    $diff++;
                }
            }
        } else if ($start_date > $end_date) {
            while ($start_date > $end_date) {
                $start_date->modify('-1 day');
    
                // Check if the current date is a weekend (Saturday=6, Sunday=0) or a holiday
                if ($start_date == $end_date) $diff--;
                else if ($this->is_workday($start_date, $workdays) && !$this->is_holiday($start_date, $holiday_dates)) {
                    $diff--;
                }
            }
        }
        

        $this->sys_ok($diff);
    }

    function is_holiday($date, $holiday_dates) {
        foreach ($holiday_dates as $holiday) {
            if ($date->format('Y-m-d') === $holiday->format('Y-m-d')) {
                return true;
            }
        }
        return false;
    }

    function is_workday($date, $workdays) {
        $day = $date->format('N');
        if (array_search($day, $workdays)===false)
            return false;

        return true;
    }
}