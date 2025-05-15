<?php
class Database {
    private $host;
    private $database;
    private $username;
    private $password;
    private $conn;
    private $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
    ];
    
    public function __construct() {
        $this->host = getenv('MYSQL_HOST') ?: 'localhost:3306';
        $this->database = getenv('MYSQL_DATABASE') ?: 'f1_db';
        $this->username = getenv('MYSQL_USER') ?: 'root';
        $this->password = getenv('MYSQL_PASSWORD') ?: '';
    }

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