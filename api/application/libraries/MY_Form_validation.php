<?php
class MY_Form_validation extends CI_Form_validation
{
     function __construct($config = array())
     {
          parent::__construct($config);
     }
 
    /**
     * Error Array
     *
     * Returns the error messages as an array
     *
     * @return  array
     */
    function error_array()
    {
        if (count($this->_error_array) === 0)
        {
                return FALSE;
        }
        else
            return $this->_error_array;
 
    }
    
    /**
     * Is Date, not Is Dead
     * 
     * @param   string  $str 
     * @return  boolean
     */
    function is_date($str) 
    {           
            $CI =& get_instance();
            $CI->form_validation->set_message('is_date', 'Wrong date format !<br />The correct one is yyyy-mm-dd.<br />Ex : 1984-10-07');
            
            return ( preg_match('/(([1-9][0-9]{3}\-(0[1-9]|1[0-2]|[1-9])\-([0][0-9]|[1-2][0-9]|[3][0-1]|[1-9])$))/', $str) > 0 ) ? true : false;
    } 
    
    /**
     * Being dropdown is'nt easy, right?
     * 
     * @param   string  $str
     * @return  boolean 
     */
    function valid_dropdown($str)
    {
            $CI =& get_instance();
            $CI->form_validation->set_message('valid_dropdown', 'Please select one option on the %s field.');
            
            if ( ! $this->is_numeric($str)) 
            {
                if ( ! $this->required($str)) 
                {
                    return FALSE;

                }
            }
            else 
            {
                if ( ! $this->greater_than($str, 0))
                {
                    return FALSE;
                }
            }
                
            return TRUE;
    }
    
    /**
     * Extending Is_Numeric
     * 
     * @param type $str
     * @return type 
     */
    function is_numeric2($str) {
            $CI =& get_instance();
            $CI->form_validation->set_message('is_numeric2', 'The %s field must contain only numericss characters.');
            
            $str = trim( preg_replace('/\,/', '', $str) );

            return parent::is_numeric($str);
    }
    
    function greater_than2($str, $min) {
            $CI =& get_instance();
            $CI->form_validation->set_message('greater_than2', 'The %s field must contain only numeric characters.');
            
            $str = trim( preg_replace('/\,/', '', $str) );
        
            return parent::greater_than($str, $min);
    }
    
    function is_numeric($str) {
        $str = ltrim(rtrim($str));
        
        return parent::is_numeric($str);
    }
    
    function is_id($str) 
    {
            $CI =& get_instance();
            $CI->form_validation->set_message('is_id', 'The %s field must not be empty.');

            return parent::is_numeric($str);
    }
}