<?php
class Database {
    private $host = 'localhost';
    private $database = 'f1_db';
    private $username = 'root';
    private $password = '';
    private $conn;
    private $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
    ];

    public function getConnection() {
        $this->conn = null;

        try {
            $dsn = "mysql:host={$this->host};dbname={$this->database};charset=utf8";
            $this->conn = new PDO($dsn, $this->username, $this->password, $this->options);
        } catch(PDOException $e) {
            echo json_encode(["error" => "Database connection error: " . $e->getMessage()]);
            exit;
        }

        return $this->conn;
    }
}