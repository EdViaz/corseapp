<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Authorization, Content-Type');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
class Database
{
    private $host;
    private $database;
    private $username;
    private $password;
    private $conn;
    private $options;

    public function __construct()
    {
        $this->host = '16.16.211.121';
        $this->database = getenv('MYSQL_DATABASE') ?: 'f1_db';
        $this->username = getenv('MYSQL_USER') ?: 'corseuser';
        $this->password = getenv('MYSQL_PASSWORD') ?: 'edviaz';

        // Configura le opzioni PDO based su estensioni disponibili
        $this->options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];

        // Aggiungi opzioni MySQL solo se l'estensione è disponibile
        if (defined('PDO::MYSQL_ATTR_INIT_COMMAND')) {
            $this->options[PDO::MYSQL_ATTR_INIT_COMMAND] = "SET NAMES utf8";
        }
    }

    public function getConnection()
    {
        $this->conn = null;

        try {
            $dsn = "mysql:host={$this->host};dbname={$this->database};charset=utf8";
            $this->conn = new PDO($dsn, $this->username, $this->password, $this->options);
        } catch (PDOException $e) {
            echo json_encode(["error" => "Database connection error: " . $e->getMessage()]);
            exit;
        }

        return $this->conn;
    }
}
