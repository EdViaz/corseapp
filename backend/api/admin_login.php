<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit();
}

// Get JSON data
$data = json_decode(file_get_contents('php://input'), true);

// Check if data is valid
if (!$data || !isset($data['username']) || !isset($data['password'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid request data']);
    exit();
}
include_once '../config/config.php';
include_once 'jwt_helper.php';

try {
    $database = new Database();
    $conn = $database->getConnection();

    // Estrai username e password dai dati ricevuti
    $username = $data['username'];
    $password = $data['password'];

    // Recupera l'utente dal database
    $stmt = $conn->prepare("SELECT id, username, password FROM admin WHERE username = :username LIMIT 1");
    $stmt->bindParam(':username', $username);
    $stmt->execute();
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($admin && password_verify($password, $admin['password'])) {
        // Genera i token JWT per admin
        $access_token = JWTHelper::generateAccessToken($admin['id'], $admin['username'], 'admin');
        $refresh_token = JWTHelper::generateRefreshToken($admin['id'], $admin['username'], 'admin');

        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Login successful',
            'user' => [
                'id' => $admin['id'],
                'username' => $admin['username'],
                'role' => 'admin'
            ],
            'access_token' => $access_token,
            'refresh_token' => $refresh_token,
            'token_type' => 'Bearer',
            'expires_in' => 3600 // 1 ora
        ]);
    } else {
        http_response_code(401);
        echo json_encode(['success' => false, 'error' => 'Invalid credentials']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error']);
}
