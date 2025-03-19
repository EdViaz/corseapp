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

// Get JSON data and handle potential errors
$jsonInput = file_get_contents('php://input');
if ($jsonInput === false) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Failed to read request body']);
    exit();
}

$data = json_decode($jsonInput, true);

// Check if data is valid
if (!$data || !isset($data['username']) || !isset($data['password'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid request data']);
    exit();
}

// Trim and sanitize inputs
$username = htmlspecialchars(trim($data['username']));
$password = trim($data['password']);

// In a real application, you would validate against a database
// For this example, we'll use hardcoded credentials
$valid_username = 'admin';
$valid_password = 'password123'; // In production, use hashed passwords

if (hash_equals($valid_username, $username) && hash_equals($valid_password, $password)) {
    try {
        // Generate a secure token
        $token = bin2hex(random_bytes(32));

        echo json_encode([
            'success' => true,
            'message' => 'Login successful',
            'token' => $token,
            'username' => $username
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => 'Internal server error']);
    }
} else {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Invalid credentials']);
}
