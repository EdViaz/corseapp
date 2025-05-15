<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

// Connessione al database
include_once '../config/config.php';
try {
    $database = new Database();
    $conn = $database->getConnection();


    // Verifica che la richiesta sia GET
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        echo json_encode([]);
        exit;
    }

    // Ottieni l'ID della notizia dalla query string
    $news_id = isset($_GET['news_id']) ? intval($_GET['news_id']) : 0;

    if ($news_id <= 0) {
        echo json_encode([]);
        exit;
    }

    // Ottieni i commenti per la notizia specificata
    try {
        $stmt = $conn->prepare(
            "SELECT c.id, c.news_id, c.user_id, u.username, c.content, c.date 
         FROM comments c 
         JOIN users u ON c.user_id = u.id 
         WHERE c.news_id = ? 
         ORDER BY c.date DESC"
        );
        $stmt->execute([$news_id]);

        $comments = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode($comments);
    } catch (PDOException $e) {
        echo json_encode([]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Errore di connessione al database: " . $e->getMessage()]);
    exit;
}
