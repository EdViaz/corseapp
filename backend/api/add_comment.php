<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

// Connessione al database
$host = 'localhost';
$db_name = 'f1_db';
$username = 'root';
$password = '';

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode(["success" => false, "message" => "Errore di connessione: " . $e->getMessage()]);
    exit;
}

// Verifica che la richiesta sia POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Metodo non consentito"]);
    exit;
}

// Ottieni i dati dalla richiesta
$news_id = isset($_POST['news_id']) ? intval($_POST['news_id']) : 0;
$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
$content = isset($_POST['content']) ? trim($_POST['content']) : '';

// Validazione
if ($news_id <= 0 || $user_id <= 0 || empty($content)) {
    echo json_encode(["success" => false, "message" => "Dati mancanti o non validi"]);
    exit;
}

// Verifica che l'utente esista
$stmt = $conn->prepare("SELECT username FROM users WHERE id = ?");
$stmt->execute([$user_id]);

if ($stmt->rowCount() === 0) {
    echo json_encode(["success" => false, "message" => "Utente non trovato"]);
    exit;
}

$user = $stmt->fetch(PDO::FETCH_ASSOC);
$username = $user['username'];

// Verifica che la notizia esista
$stmt = $conn->prepare("SELECT id FROM news WHERE id = ?");
$stmt->execute([$news_id]);

if ($stmt->rowCount() === 0) {
    echo json_encode(["success" => false, "message" => "Notizia non trovata"]);
    exit;
}

// Inserisci il commento
try {
    $current_date = date('Y-m-d H:i:s');
    
    $stmt = $conn->prepare("INSERT INTO comments (news_id, user_id, content, date) VALUES (?, ?, ?, ?)");
    $stmt->execute([$news_id, $user_id, $content, $current_date]);
    
    $comment_id = $conn->lastInsertId();
    
    // Restituisci i dati del commento
    echo json_encode([
        "success" => true, 
        "message" => "Commento aggiunto con successo",
        "comment" => [
            "id" => $comment_id,
            "news_id" => $news_id,
            "user_id" => $user_id,
            "username" => $username,
            "content" => $content,
            "date" => $current_date
        ]
    ]);
} catch(PDOException $e) {
    echo json_encode(["success" => false, "message" => "Errore durante l'aggiunta del commento: " . $e->getMessage()]);
}
?>