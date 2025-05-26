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

try {
    $database = new Database();
    $conn = $database->getConnection();    // Verifica che la richiesta sia POST
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        echo json_encode(["success" => false, "message" => "Metodo non consentito"]);
        exit;
    }

    // Ottieni i dati dalla richiesta (supporta sia POST che JSON)
    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        $data = $_POST;
    }

    $username = isset($data['username']) ? trim($data['username']) : '';
    $password = isset($data['password']) ? trim($data['password']) : '';

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
        }        // Rimuovi la password dai dati da restituire
        unset($user['password']);

        // Genera i token JWT
        $access_token = JWTHelper::generateAccessToken($user['id'], $user['username'], 'user');
        $refresh_token = JWTHelper::generateRefreshToken($user['id'], $user['username'], 'user');

        // Login riuscito
        echo json_encode([
            "success" => true,
            "message" => "Login effettuato con successo",
            "user" => $user,
            "access_token" => $access_token,
            "refresh_token" => $refresh_token,
            "token_type" => "Bearer",
            "expires_in" => 3600 // 1 ora
        ]);
    } catch (PDOException $e) {
        echo json_encode(["success" => false, "message" => "Errore durante il login: " . $e->getMessage()]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Errore di connessione al database: " . $e->getMessage()]);
    exit;
}
