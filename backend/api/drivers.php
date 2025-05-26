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

    // Prendi l'anno dalla query string, default anno corrente
    $year = isset($_GET['year']) ? intval($_GET['year']) : intval(date('Y'));
    
    // Check if team_id is provided to filter by team
    $team_id = isset($_GET['team_id']) ? intval($_GET['team_id']) : null;
    
    if ($team_id) {
        // Get drivers for a specific team
        $sql = "SELECT * FROM drivers WHERE year = :year AND team_id = :team_id AND external_id IS NOT NULL AND external_id != '' ORDER BY position ASC";
        $stmt = $conn->prepare($sql);
        $stmt->execute(['year' => $year, 'team_id' => $team_id]);
    } else {
        // Get all drivers (existing behavior)
        $sql = "SELECT * FROM drivers WHERE year = :year AND external_id IS NOT NULL AND external_id != '' ORDER BY position ASC";
        $stmt = $conn->prepare($sql);
        $stmt->execute(['year' => $year]);
    }
    
    $drivers = $stmt->fetchAll();
    
    // Return JSON response
    echo json_encode($drivers);
} catch (PDOException $e) {
    // Return error as JSON
    echo json_encode(['error' => $e->getMessage()]);
}
