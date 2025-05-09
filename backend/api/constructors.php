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

    // Query to get constructor standings
    $sql = "SELECT * FROM constructors ORDER BY position ASC";
    $result = $conn->query($sql);

    if ($result === false) {
        throw new Exception("Error executing query: " . $conn->error);
    }

    $constructors = array();
    
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $constructors[] = $row;
        }
    }
    
    // Return JSON response
    echo json_encode($constructors);
    
} catch (Exception $e) {
    // Return error as JSON
    echo json_encode(array('error' => $e->getMessage()));
} finally {
    // Close connection if it exists
    if (isset($conn)) {
        $conn->close();
    }
}
?>