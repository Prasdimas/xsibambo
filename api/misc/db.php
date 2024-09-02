<?php

include_once "config.php";

class db
{
    private $host;
    private $db;
    private $username;
    private $password;

    function __construct()
    {
        $this->host = $GLOBALS['host'];
        $this->db = $GLOBALS['db'];
        $this->username = $GLOBALS['username'];
        $this->password = $GLOBALS['password'];
    }

    function connect()
    {
        $conn = false;

        try
        {
            $conn = new PDO("mysql:host={$this->host};dbname={$this->db}", $this->username, $this->password);
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        }
        catch(PDOException $e)
        {
            echo "Connection failed: " . $e->getMessage();
        }

        return $conn;
    }

    function fetch_all($stmt)
    {
        $stmt->execute();
        $stmt->setFetchMode(PDO::FETCH_ASSOC);

        return $stmt->fetchAll();
    } 

    function fetch_single($stmt)
    {
        $stmt->execute();
        $stmt->setFetchMode(PDO::FETCH_ASSOC);

        return $stmt->fetch();
    }

    function set_db($db)
    {
        $this->db = $db;
    }
}
?>