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

// Include JWT helper
include_once 'jwt_helper.php';

try {
    // Verifica l'autenticazione
    $user_data = JWTHelper::requireAuth();

    // In una implementazione completa, qui dovresti:
    // 1. Aggiungere il token a una blacklist nel database
    // 2. O invalidare tutti i token dell'utente aggiornando un campo nel database
    
    // Per ora, restituiamo semplicemente successo
    // Il client dovrebbe rimuovere i token dal suo storage
    echo json_encode([
        'success' => true,
        'message' => 'Logout effettuato con successo'
    ]);

} catch (Exception $e) {
    // L'errore viene già gestito da requireAuth()
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error']);
}
?>
