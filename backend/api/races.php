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

    // Query to get races using prepared statement
    $sql = "SELECT * FROM races ORDER BY date ASC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    
    $races = [];
    $currentTime = time();
    
    // Fetch all races and process them
    $results = $stmt->fetchAll();
    foreach ($results as $row) {
        // Add a flag to indicate if the race is in the past
        $row['is_past'] = (strtotime($row['date']) < $currentTime) ? 1 : 0;
        $races[] = $row;
    }
    
    // Return JSON response
    echo json_encode($races);
} catch (PDOException $e) {
    // Return error as JSON
    echo json_encode(['error' => $e->getMessage()]);
}
