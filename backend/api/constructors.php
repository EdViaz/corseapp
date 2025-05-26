<?php
// Set headers for JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Include database connection
include_once '../config/config.php';

try {
    // Create database instance and get connection
    $database = new Database();
    $conn = $database->getConnection();    // Query to get constructor standings using prepared statement
    // Prendi l'anno dalla query string, default anno corrente
    $year = isset($_GET['year']) ? intval($_GET['year']) : intval(date('Y'));
    // Mostra solo team importati (external_id valorizzato), ordinati per punti discendenti
    $sql = "SELECT *, ROW_NUMBER() OVER (ORDER BY points DESC) as position FROM constructors WHERE year = :year AND external_id IS NOT NULL AND external_id != '' ORDER BY points DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute(['year' => $year]);
    
    $constructors = $stmt->fetchAll();
    
    // Return JSON response
    echo json_encode($constructors);
} catch (PDOException $e) {
    // Return error as JSON
    echo json_encode(['error' => $e->getMessage()]);
}