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

// Verifica se l'username esiste già
$stmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
$stmt->execute([$username]);

if ($stmt->rowCount() > 0) {
    echo json_encode(["success" => false, "message" => "Username già in uso"]);
    exit;
}

// Hash della password
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Inserisci il nuovo utente
try {
    $stmt = $conn->prepare("INSERT INTO users (username, password) VALUES (?, ?)");
    $stmt->execute([$username, $hashed_password]);
    
    $user_id = $conn->lastInsertId();
    
    // Restituisci i dati dell'utente (senza la password)
    echo json_encode([
        "success" => true, 
        "message" => "Registrazione completata con successo",
        "user" => [
            "id" => $user_id,
            "username" => $username
        ]
    ]);
} catch(PDOException $e) {
    echo json_encode(["success" => false, "message" => "Errore durante la registrazione: " . $e->getMessage()]);
}
?>