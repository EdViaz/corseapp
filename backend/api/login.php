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
$username = isset($_POST['username']) ? trim($_POST['username']) : '';
$password = isset($_POST['password']) ? trim($_POST['password']) : '';

// Validazione
if (empty($username) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Username e password sono obbligatori"]);
    exit;
}

// Verifica le credenziali
try {
    $stmt = $conn->prepare("SELECT id, username, password FROM users WHERE username = ?");
    $stmt->execute([$username]);
    
    if ($stmt->rowCount() === 0) {
        echo json_encode(["success" => false, "message" => "Credenziali non valide"]);
        exit;
    }
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Verifica la password
    if (!password_verify($password, $user['password'])) {
        echo json_encode(["success" => false, "message" => "Credenziali non valide"]);
        exit;
    }
    
    // Rimuovi la password dai dati da restituire
    unset($user['password']);
    
    // Login riuscito
    echo json_encode([
        "success" => true, 
        "message" => "Login effettuato con successo",
        "user" => $user
    ]);
} catch(PDOException $e) {
    echo json_encode(["success" => false, "message" => "Errore durante il login: " . $e->getMessage()]);
}
?>