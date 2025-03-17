<?php
// Set headers for JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Include database connection
include_once '../config/database.php';

try {
    // Create connection
    $conn = new mysqli($host, $username, $password, $database);

    // Check connection
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }

    // Query to get news
    $sql = "SELECT * FROM news ORDER BY publish_date DESC";
    $result = $conn->query($sql);

    if ($result === false) {
        throw new Exception("Error executing query: " . $conn->error);
    }

    $news = array();
    
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $news[] = $row;
        }
    }
    
    // Return JSON response
    echo json_encode($news);
    
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