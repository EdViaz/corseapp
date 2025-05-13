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
if (!$data || !isset($data['id']) || !isset($data['name']) || !isset($data['location']) || !isset($data['date'])) {
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
    $location = htmlspecialchars(trim($data['location']));
    $date = $data['date'];
    $circuit_image = isset($data['circuit_image']) ? htmlspecialchars(trim($data['circuit_image'])) : '';
    $country = isset($data['country']) ? htmlspecialchars(trim($data['country'])) : '';
    
    // Check if the race exists
    $check_sql = "SELECT id FROM races WHERE id = :id";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Gara non trovata']);
        exit();
    }
    
    // Update the race
    $sql = "UPDATE races SET name = :name, location = :location, date = :date, circuit_image = :circuit_image, country = :country WHERE id = :id";
    $stmt = $conn->prepare($sql);
    
    // Bind parameters
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $stmt->bindParam(':name', $name);
    $stmt->bindParam(':location', $location);
    $stmt->bindParam(':date', $date);
    $stmt->bindParam(':circuit_image', $circuit_image);
    $stmt->bindParam(':country', $country);
    
    // Execute the query
    if ($stmt->execute()) {
        // Return success response
        echo json_encode([
            'success' => true, 
            'message' => 'Gara aggiornata con successo',
            'id' => $id
        ]);
    } else {
        throw new PDOException("Impossibile aggiornare la gara");
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}