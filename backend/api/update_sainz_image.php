<?php
// Set headers for JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Include database connection
include_once __DIR__ . '/../config/config.php';

try {
    // Create database instance and get connection
    $database = new Database();
    $conn = $database->getConnection();

    // Check connection
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }

    // Query to update Carlos Sainz's image URL
    $sql = "UPDATE drivers SET image_url = 'https://www.formula1.com/content/dam/fom-website/drivers/C/CARSAI01_Carlos_Sainz/carsai01.png' WHERE id = 55";
    $result = $conn->query($sql);

    if ($result === false) {
        throw new Exception("Error executing query: " . $conn->error);
    }

    // Return success response
    echo json_encode(array('success' => true, 'message' => 'Immagine di Carlos Sainz aggiornata con successo'));
} catch (Exception $e) {
    // Return error as JSON
    echo json_encode(array('error' => $e->getMessage()));
} finally {
    // Close connection if it exists
    if (isset($conn)) {
        $conn->close();
    }
}