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
    } catch (PDOException $e) {
        echo json_encode(["success" => false, "message" => "Errore durante il login: " . $e->getMessage()]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Errore di connessione al database: " . $e->getMessage()]);
    exit;
}
