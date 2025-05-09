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

    // Check connection
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }

    // Query to get races
    $sql = "SELECT * FROM races ORDER BY date ASC";
    $result = $conn->query($sql);

    if ($result === false) {
        throw new Exception("Error executing query: " . $conn->error);
    }

    $races = array();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            // Add a flag to indicate if the race is in the past
            $row['is_past'] = (strtotime($row['date']) < time()) ? 1 : 0;
            $races[] = $row;
        }
    }

    // Return JSON response
    echo json_encode($races);
} catch (Exception $e) {
    // Return error as JSON
    echo json_encode(array('error' => $e->getMessage()));
} finally {
    // Close connection if it exists
    if (isset($conn)) {
        $conn->close();
    }
}
