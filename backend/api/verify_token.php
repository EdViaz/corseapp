<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit();
}

// Include JWT helper
include_once 'jwt_helper.php';

try {
    // Verifica l'autenticazione senza richiedere un ruolo specifico
    $user_data = JWTHelper::requireAuth();

    // Se arriviamo qui, il token è valido
    echo json_encode([
        'success' => true,
        'user' => [
            'id' => $user_data->user_id,
            'username' => $user_data->username,
            'role' => $user_data->role
        ],
        'message' => 'Token valid'
    ]);

} catch (Exception $e) {
    // L'errore viene già gestito da requireAuth()
    // Questo catch è per eventuali altri errori imprevisti
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error']);
}
?>
