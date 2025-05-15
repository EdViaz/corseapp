<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

// Connessione al database
include_once '../config/config.php';

// Istanzia il database
$database = new Database();
$db = $database->getConnection();

// Verifica se è stato fornito l'ID utente
if (!isset($_GET['user_id']) || empty($_GET['user_id'])) {
    echo json_encode([]);
    exit;
}

$user_id = intval($_GET['user_id']);

// Query per ottenere i commenti dell'utente
$query = "SELECT c.id, c.news_id, c.user_id, u.username, c.content, c.date 
          FROM comments c 
          JOIN users u ON c.user_id = u.id 
          WHERE c.user_id = ? 
          ORDER BY c.date DESC";

// Prepara la query
$stmt = $db->prepare($query);

// Bind del parametro
$stmt->bindParam(1, $user_id);

// Esegui la query
$stmt->execute();

// Verifica se ci sono risultati
if ($stmt->rowCount() > 0) {
    // Array di commenti
    $comments_arr = [];
    
    // Recupera i risultati
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $comment_item = [
            'id' => $row['id'],
            'news_id' => $row['news_id'],
            'user_id' => $row['user_id'],
            'username' => $row['username'],
            'content' => $row['content'],
            'date' => $row['date']
        ];
        
        array_push($comments_arr, $comment_item);
    }
    
    // Restituisci i commenti in formato JSON
    echo json_encode($comments_arr);
} else {
    // Nessun commento trovato
    echo json_encode([]);
}