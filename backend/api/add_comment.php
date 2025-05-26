<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Connessione al database e JWT helper
include_once '../config/config.php';
include_once 'jwt_helper.php';

// Verifica autenticazione (sia admin che user possono commentare)
try {
    $user_data = JWTHelper::requireAuth();
} catch (Exception $e) {
    exit();
}

try {
    $database = new Database();
    $conn = $database->getConnection();
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Errore di connessione al database: " . $e->getMessage()]);
    exit;
}

// Verifica che la richiesta sia POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Metodo non consentito"]);
    exit;
}

// Ottieni i dati dalla richiesta (supporta sia POST che JSON)
$data = json_decode(file_get_contents('php://input'), true);
if (!$data) {
    $data = $_POST;
}

$news_id = isset($data['news_id']) ? intval($data['news_id']) : 0;
$content = isset($data['content']) ? trim($data['content']) : '';

// Usa l'ID utente dal token JWT invece che dai dati POST
$user_id = $user_data->user_id;

// Validazione
if ($news_id <= 0 || empty($content)) {
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
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Errore durante l'aggiunta del commento: " . $e->getMessage()]);
}
