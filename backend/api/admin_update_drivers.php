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
if (!$data || !isset($data['name']) || !isset($data['team']) || !isset($data['points']) || !isset($data['position'])) {
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
include_once '../config/config.php';

try {
    // Create database instance and get connection
    $database = new Database();
    $conn = $database->getConnection();
    
    // Sanitize inputs
    $name = htmlspecialchars(trim($data['name']));
    $team = htmlspecialchars(trim($data['team']));
    $points = (float)$data['points'];
    $position = (int)$data['position'];
    $image_url = isset($data['image_url']) ? htmlspecialchars(trim($data['image_url'])) : '';
    
    // Check if we're updating an existing record or creating a new one
    if (isset($data['id']) && $data['id'] > 0) {
        // Update existing driver
        $sql = "UPDATE drivers SET name = :name, team = :team, points = :points, position = :position, image_url = :image_url WHERE id = :id";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':id', $data['id'], PDO::PARAM_INT);
    } else {
        // Insert new driver
        $sql = "INSERT INTO drivers (name, team, points, position, image_url) VALUES (:name, :team, :points, :position, :image_url)";
        $stmt = $conn->prepare($sql);
    }
    
    // Bind parameters
    $stmt->bindParam(':name', $name);
    $stmt->bindParam(':team', $team);
    $stmt->bindParam(':points', $points);
    $stmt->bindParam(':position', $position);
    $stmt->bindParam(':image_url', $image_url);
    
    // Execute the query
    if ($stmt->execute()) {
        // Get the ID of the inserted/updated driver
        $driver_id = isset($data['id']) ? $data['id'] : $conn->lastInsertId();
        
        // Return success response
        echo json_encode([
            'success' => true, 
            'message' => 'Driver ' . (isset($data['id']) ? 'updated' : 'added') . ' successfully',
            'id' => $driver_id
        ]);
    } else {
        throw new PDOException("Failed to " . (isset($data['id']) ? 'update' : 'add') . " driver");
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}