<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

// Connessione al database
include_once '../config/config.php';

try {
    $database = new Database();
    $conn = $database->getConnection();
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
    } catch (PDOException $e) {
        echo json_encode(["success" => false, "message" => "Errore durante la registrazione: " . $e->getMessage()]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Errore di connessione al database: " . $e->getMessage()]);
    exit;
}
