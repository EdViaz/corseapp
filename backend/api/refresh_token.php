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
    // Get JSON data
    $data = json_decode(file_get_contents('php://input'), true);

    // Check if refresh token is provided
    if (!$data || !isset($data['refresh_token'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Refresh token required']);
        exit();
    }

    $refresh_token = $data['refresh_token'];

    // Generate new tokens
    $result = JWTHelper::refreshTokens($refresh_token);

    if ($result['success']) {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'access_token' => $result['access_token'],
            'refresh_token' => $result['refresh_token'],
            'token_type' => 'Bearer',
            'expires_in' => 3600 // 1 ora
        ]);
    } else {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'error' => $result['message']
        ]);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error']);
}
