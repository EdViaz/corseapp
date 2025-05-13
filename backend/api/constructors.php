<?php
// Set headers for JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Include database connection
include_once '../config/config.php';

try {
    // Create database instance and get connection
    $database = new Database();
    $conn = $database->getConnection();

    // Query to get constructor standings using prepared statement
    $sql = "SELECT * FROM constructors ORDER BY position ASC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    
    $constructors = $stmt->fetchAll();
    
    // Return JSON response
    echo json_encode($constructors);
} catch (PDOException $e) {
    // Return error as JSON
    echo json_encode(['error' => $e->getMessage()]);
}