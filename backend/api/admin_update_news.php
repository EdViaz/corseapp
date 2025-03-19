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
if (!$data || !isset($data['title']) || !isset($data['content'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid request data']);
    exit();
}

// Check for authorization token
$headers = getallheaders();
$auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';

if (empty($auth_header) || !preg_match('/Bearer\s+(\S+)/', $auth_header, $matches)) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Unauthorized']);
    exit();
}

$token = $matches[1];

// In a real application, you would validate the token against a database
// For this example, we'll just check if it's not empty
if (empty($token)) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Invalid token']);
    exit();
}

// Include database connection
require_once '../config/database.php';

try {
    $db = new Database();
    $conn = $db->getConnection();

    // Check if we're updating an existing news item or creating a new one
    if (isset($data['id']) && $data['id'] > 0) {
        // Update existing news
        $stmt = $conn->prepare("UPDATE news SET title = ?, content = ?, image_url = ?, publish_date = ? WHERE id = ?");
        $stmt->bind_param("ssssi", $data['title'], $data['content'], $data['image_url'], $data['publish_date'], $data['id']);
        $stmt->execute();

        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'News updated successfully', 'id' => $data['id']]);
        } else {
            echo json_encode(['success' => false, 'error' => 'No changes made or news not found']);
        }
    } else {
        // Create new news
        $stmt = $conn->prepare("INSERT INTO news (title, content, image_url, publish_date, additional_images) VALUES (?, ?, ?, ?, ?)");
        $additional_images = isset($data['additional_images']) ? $data['additional_images'] : '';
        $stmt->bind_param("sssss", $data['title'], $data['content'], $data['image_url'], $data['publish_date'], $additional_images);
        $stmt->execute();

        if ($stmt->affected_rows > 0) {
            $new_id = $stmt->insert_id;
            echo json_encode(['success' => true, 'message' => 'News created successfully', 'id' => $new_id]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Failed to create news']);
        }
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
}
