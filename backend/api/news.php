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

    // Query to get news using prepared statement
    $sql = "SELECT * FROM news ORDER BY publish_date DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    
    $news = $stmt->fetchAll();
    
    // Return JSON response
    echo json_encode($news);
} catch (PDOException $e) {
    // Return error as JSON
    echo json_encode(['error' => $e->getMessage()]);
}
