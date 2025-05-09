<?php
class Database {
    private $host = 'localhost';
    private $database = 'f1_db';
    private $username = 'root';
    private $password = '';
    private $conn;

    public function getConnection() {
        $this->conn = null;

        try {
            $this->conn = new mysqli($this->host, $this->username, $this->password, $this->database);
            $this->conn->set_charset("utf8");
            
            if ($this->conn->connect_error) {
                throw new Exception("Connection failed: " . $this->conn->connect_error);
            }
        } catch(Exception $e) {
            echo "Database connection error: " . $e->getMessage();
        }

        return $this->conn;
    }
}