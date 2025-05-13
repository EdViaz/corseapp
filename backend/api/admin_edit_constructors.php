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
    echo json_encode(['success' => false, 'error' => 'Metodo non consentito']);
    exit();
}

// Get JSON data
$data = json_decode(file_get_contents('php://input'), true);

// Check if data is valid
if (!$data || !isset($data['id']) || !isset($data['name']) || !isset($data['points']) || !isset($data['position'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Dati della richiesta non validi']);
    exit();
}

// Check for authorization token
$headers = getallheaders();
$auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';

if (empty($auth_header) || !preg_match('/Bearer\s+(\S+)/', $auth_header, $matches)) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Non autorizzato']);
    exit();
}

$token = $matches[1];

// In a real application, you would validate the token against a database
// For this example, we'll just check if it's not empty
if (empty($token)) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Token non valido']);
    exit();
}

// Include database connection
include_once '../config/config.php';

try {
    // Create database instance and get connection
    $database = new Database();
    $conn = $database->getConnection();
    
    // Sanitize inputs
    $id = intval($data['id']);
    $name = htmlspecialchars(trim($data['name']));
    $points = floatval($data['points']);
    $position = intval($data['position']);
    $country = isset($data['country']) ? htmlspecialchars(trim($data['country'])) : '';
    $image_url = isset($data['image_url']) ? htmlspecialchars(trim($data['image_url'])) : '';
    
    // Check if the constructor exists
    $check_sql = "SELECT id FROM constructors WHERE id = :id";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Costruttore non trovato']);
        exit();
    }
    
    // Update the constructor
    $sql = "UPDATE constructors SET name = :name, points = :points, position = :position, country = :country, image_url = :image_url WHERE id = :id";
    $stmt = $conn->prepare($sql);
    
    // Bind parameters
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $stmt->bindParam(':name', $name);
    $stmt->bindParam(':points', $points);
    $stmt->bindParam(':position', $position);
    $stmt->bindParam(':country', $country);
    $stmt->bindParam(':image_url', $image_url);
    
    // Execute the query
    if ($stmt->execute()) {
        // Return success response
        echo json_encode([
            'success' => true, 
            'message' => 'Costruttore aggiornato con successo',
            'id' => $id
        ]);
    } else {
        throw new PDOException("Impossibile aggiornare il costruttore");
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}