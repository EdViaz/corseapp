<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS, DELETE');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow POST and DELETE requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit();
}

// Include dependencies
include_once '../config/config.php';
include_once 'jwt_helper.php';

// Verifica autenticazione admin
try {
    $user_data = JWTHelper::requireAuth('admin');
} catch (Exception $e) {
    // L'errore viene già gestito da requireAuth()
    exit();
}

// Get JSON data
$data = json_decode(file_get_contents('php://input'), true);

// Check if data is valid
if (!$data || !isset($data['entity_type']) || !isset($data['action'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid request data']);
    exit();
}

$entity_type = $data['entity_type']; // news, drivers, constructors, races
$action = $data['action']; // create, update, delete

// Process the request based on entity type and action
try {
    // Create database instance and get connection
    $database = new Database();
    $conn = $database->getConnection();

    switch ($entity_type) {
        case 'news':
            handleNews($conn, $action, $data);
            break;
        case 'drivers':
            handleDrivers($conn, $action, $data);
            break;
        case 'constructors':
            handleConstructors($conn, $action, $data);
            break;
        case 'races':
            handleRaces($conn, $action, $data);
            break;
        // AGGIUNTA: endpoint per aggiornamento automatico dati F1
        case 'sync':
            if ($action === 'update') {
                try {
                    // Includi direttamente lo script invece di usare exec
                    ob_start();
                    include_once __DIR__ . '/sync_f1_data.php';
                    $output = ob_get_clean();

                    // Prova a decodificare la risposta JSON
                    $response = @json_decode($output, true);

                    if ($response && isset($response['success']) && $response['success']) {
                        echo json_encode(['success' => true, 'message' => 'Dati F1 aggiornati con successo']);
                    } else {
                        $errorMsg = $response['error'] ?? 'Errore durante la sincronizzazione dati F1';
                        echo json_encode(['success' => false, 'error' => $errorMsg]);
                    }
                } catch (Exception $e) {
                    echo json_encode(['success' => false, 'error' => 'Errore interno: ' . $e->getMessage()]);
                }
                exit();
            }
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid action for sync']);
            exit();
        default:
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid entity type']);
            exit();
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}

// Handle News operations
function handleNews($conn, $action, $data)
{
    switch ($action) {
        case 'create':
        case 'update':
            if (!isset($data['title']) || !isset($data['content'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Missing required fields for news']);
                exit();
            }

            // Sanitize inputs
            $title = htmlspecialchars(trim($data['title']));
            $content = htmlspecialchars(trim($data['content']));
            $image_url = isset($data['image_url']) ? htmlspecialchars(trim($data['image_url'])) : '';
            $publish_date = isset($data['publish_date']) ? $data['publish_date'] : date('Y-m-d H:i:s');
            $additional_images = isset($data['additional_images']) ? json_encode($data['additional_images']) : null;

            // Check if we're updating an existing record or creating a new one
            if (isset($data['id']) && $data['id'] > 0) {
                // Update existing news
                $sql = "UPDATE news SET title = :title, content = :content, image_url = :image_url, publish_date = :publish_date WHERE id = :id";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':id', $data['id'], PDO::PARAM_INT);
            } else {
                // Insert new news
                $sql = "INSERT INTO news (title, content, image_url, publish_date) VALUES (:title, :content, :image_url, :publish_date)";
                $stmt = $conn->prepare($sql);
            }

            // Bind parameters
            $stmt->bindParam(':title', $title);
            $stmt->bindParam(':content', $content);
            $stmt->bindParam(':image_url', $image_url);
            $stmt->bindParam(':publish_date', $publish_date);

            // Execute the query
            if ($stmt->execute()) {
                // Get the ID of the inserted/updated news
                $news_id = isset($data['id']) ? $data['id'] : $conn->lastInsertId();

                // Return success response
                echo json_encode([
                    'success' => true,
                    'message' => 'News ' . (isset($data['id']) ? 'updated' : 'added') . ' successfully',
                    'id' => $news_id
                ]);
            } else {
                throw new PDOException("Failed to add news");
            }
            break;

        case 'delete':
            if (!isset($data['id'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Missing ID for delete operation']);
                exit();
            }

            // Sanitize input
            $id = intval($data['id']);

            // Check if the news exists
            $check_sql = "SELECT id FROM news WHERE id = :id";
            $check_stmt = $conn->prepare($check_sql);
            $check_stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $check_stmt->execute();

            if ($check_stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['success' => false, 'error' => 'News non trovata']);
                exit();
            }

            // Delete the news
            $sql = "DELETE FROM news WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);

            // Execute the query
            if ($stmt->execute()) {
                // Return success response
                echo json_encode([
                    'success' => true,
                    'message' => 'News eliminata con successo'
                ]);
            } else {
                throw new PDOException("Impossibile eliminare la news");
            }
            break;

        default:
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid action for news']);
            exit();
    }
}

// Handle Drivers operations
function handleDrivers($conn, $action, $data)
{
    switch ($action) {
        case 'create':
        case 'update':
            if (!isset($data['name']) || !isset($data['surname']) || !isset($data['team_id']) || !isset($data['points']) || !isset($data['position'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Campi obbligatori mancanti per il pilota']);
                exit();
            }

            // Sanitize inputs
            $name = htmlspecialchars(trim($data['name']));
            $surname = htmlspecialchars(trim($data['surname']));
            $team_id = intval($data['team_id']);
            $points = (float)$data['points'];
            $position = (int)$data['position'];
            $image_url = isset($data['image_url']) ? htmlspecialchars(trim($data['image_url'])) : '';
            $nationality = isset($data['nationality']) ? htmlspecialchars(trim($data['nationality'])) : '';
            $number = isset($data['number']) ? intval($data['number']) : 0;
            $description = isset($data['description']) ? htmlspecialchars(trim($data['description'])) : '';

            // Check if we're updating an existing record or creating a new one
            if (isset($data['id']) && $data['id'] > 0) {
                // Update existing driver
                $sql = "UPDATE drivers SET name = :name, surname = :surname, team_id = :team_id, points = :points, position = :position, image_url = :image_url, nationality = :nationality, number = :number, description = :description WHERE id = :id";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':id', $data['id'], PDO::PARAM_INT);
            } else {
                // Insert new driver
                $sql = "INSERT INTO drivers (name, surname, team_id, points, position, image_url, nationality, number, description) VALUES (:name, :surname, :team_id, :points, :position, :image_url, :nationality, :number, :description)";
                $stmt = $conn->prepare($sql);
            }

            // Bind parameters
            $stmt->bindParam(':name', $name);
            $stmt->bindParam(':surname', $surname);
            $stmt->bindParam(':team_id', $team_id);
            $stmt->bindParam(':points', $points);
            $stmt->bindParam(':position', $position);
            $stmt->bindParam(':image_url', $image_url);
            $stmt->bindParam(':nationality', $nationality);
            $stmt->bindParam(':number', $number);
            $stmt->bindParam(':description', $description);

            // Execute the query
            if ($stmt->execute()) {
                // Get the ID of the inserted/updated driver
                $driver_id = isset($data['id']) ? $data['id'] : $conn->lastInsertId();

                // Return success response
                echo json_encode([
                    'success' => true,
                    'message' => 'Pilota ' . (isset($data['id']) ? 'aggiornato' : 'aggiunto') . ' con successo',
                    'id' => $driver_id
                ]);
            } else {
                throw new PDOException("Impossibile aggiungere il pilota");
            }
            break;

        case 'delete':
            if (!isset($data['id'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'ID mancante per l\'eliminazione']);
                exit();
            }

            // Sanitize input
            $id = intval($data['id']);

            // Check if the driver exists
            $check_sql = "SELECT id FROM drivers WHERE id = :id";
            $check_stmt = $conn->prepare($check_sql);
            $check_stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $check_stmt->execute();

            if ($check_stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['success' => false, 'error' => 'Pilota non trovato']);
                exit();
            }

            // Delete the driver
            $sql = "DELETE FROM drivers WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);

            // Execute the query
            if ($stmt->execute()) {
                // Return success response
                echo json_encode([
                    'success' => true,
                    'message' => 'Pilota eliminato con successo'
                ]);
            } else {
                throw new PDOException("Impossibile eliminare il pilota");
            }
            break;

        default:
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Azione non valida per i piloti']);
            exit();
    }
}

// Handle Constructors operations
function handleConstructors($conn, $action, $data)
{
    switch ($action) {
        case 'create':
        case 'update':
            if (!isset($data['name']) || !isset($data['points'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Missing required fields for constructor']);
                exit();
            }

            // Sanitize inputs
            $name = htmlspecialchars(trim($data['name']));
            $points = (float)$data['points'];
            $logo_url = isset($data['logo_url']) ? htmlspecialchars(trim($data['logo_url'])) : '';

            // Check if we're updating an existing record or creating a new one
            if (isset($data['id']) && $data['id'] > 0) {
                // Update existing constructor
                $sql = "UPDATE constructors SET name = :name, points = :points, logo_url = :logo_url WHERE id = :id";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':id', $data['id'], PDO::PARAM_INT);
            } else {
                // Insert new constructor
                $sql = "INSERT INTO constructors (name, points, logo_url) VALUES (:name, :points, :logo_url)";
                $stmt = $conn->prepare($sql);
            }

            // Bind parameters
            $stmt->bindParam(':name', $name);
            $stmt->bindParam(':points', $points);
            $stmt->bindParam(':logo_url', $logo_url);

            // Execute the query
            if ($stmt->execute()) {
                // Get the ID of the inserted/updated constructor
                $constructor_id = isset($data['id']) ? $data['id'] : $conn->lastInsertId();

                // Return success response
                echo json_encode([
                    'success' => true,
                    'message' => 'Constructor ' . (isset($data['id']) ? 'updated' : 'added') . ' successfully',
                    'id' => $constructor_id
                ]);
            } else {
                throw new PDOException("Failed to add constructor");
            }
            break;

        case 'delete':
            if (!isset($data['id'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Missing ID for delete operation']);
                exit();
            }

            // Sanitize input
            $id = intval($data['id']);

            // Check if the constructor exists
            $check_sql = "SELECT id FROM constructors WHERE id = :id";
            $check_stmt = $conn->prepare($check_sql);
            $check_stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $check_stmt->execute();

            if ($check_stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['success' => false, 'error' => 'Constructor non trovato']);
                exit();
            }

            // Delete the constructor
            $sql = "DELETE FROM constructors WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);

            // Execute the query
            if ($stmt->execute()) {
                // Return success response
                echo json_encode([
                    'success' => true,
                    'message' => 'Constructor eliminato con successo'
                ]);
            } else {
                throw new PDOException("Impossibile eliminare il constructor");
            }
            break;

        default:
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid action for constructors']);
            exit();
    }
}

// Handle Races operations
function handleRaces($conn, $action, $data)
{
    // Mappa i parametri dal frontend Flutter
    $name = isset($data['name']) ? htmlspecialchars(trim($data['name'])) : '';
    $circuit = isset($data['circuit']) ? htmlspecialchars(trim($data['circuit'])) : '';
    $date = isset($data['date']) ? $data['date'] : '';
    $flag_url = isset($data['flagUrl']) ? htmlspecialchars(trim($data['flagUrl'])) : (isset($data['flag_url']) ? htmlspecialchars(trim($data['flag_url'])) : '');
    $isPast = isset($data['isPast']) ? intval($data['isPast']) : 0;
    // Per compatibilità, se manca country, metti stringa vuota
    $country = isset($data['country']) ? htmlspecialchars(trim($data['country'])) : '';

    switch ($action) {
        case 'add':
        case 'create':
            if (empty($name) || empty($circuit) || empty($date)) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Missing required fields for race']);
                exit();
            }
            $sql = "INSERT INTO races (name, circuit, date, flag_url, isPast, country) VALUES (:name, :circuit, :date, :flag_url, :isPast, :country)";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':name', $name);
            $stmt->bindParam(':circuit', $circuit);
            $stmt->bindParam(':date', $date);
            $stmt->bindParam(':flag_url', $flag_url);
            $stmt->bindParam(':isPast', $isPast);
            $stmt->bindParam(':country', $country);
            if ($stmt->execute()) {
                $race_id = $conn->lastInsertId();
                echo json_encode([
                    'success' => true,
                    'message' => 'Race added successfully',
                    'id' => $race_id
                ]);
            } else {
                throw new PDOException("Failed to add race");
            }
            break;
        case 'edit':
        case 'update':
            if (!isset($data['id']) || empty($name) || empty($circuit) || empty($date)) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Missing required fields for race update']);
                exit();
            }
            $id = intval($data['id']);
            $sql = "UPDATE races SET name = :name, circuit = :circuit, date = :date, flag_url = :flag_url, isPast = :isPast, country = :country WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->bindParam(':name', $name);
            $stmt->bindParam(':circuit', $circuit);
            $stmt->bindParam(':date', $date);
            $stmt->bindParam(':flag_url', $flag_url);
            $stmt->bindParam(':isPast', $isPast);
            $stmt->bindParam(':country', $country);
            if ($stmt->execute()) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Race updated successfully',
                    'id' => $id
                ]);
            } else {
                throw new PDOException("Failed to update race");
            }
            break;
        case 'delete':
            if (!isset($data['id'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Missing ID for delete operation']);
                exit();
            }
            $id = intval($data['id']);
            $check_sql = "SELECT id FROM races WHERE id = :id";
            $check_stmt = $conn->prepare($check_sql);
            $check_stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $check_stmt->execute();
            if ($check_stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['success' => false, 'error' => 'Race non trovata']);
                exit();
            }
            $sql = "DELETE FROM races WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            if ($stmt->execute()) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Race eliminata con successo'
                ]);
            } else {
                throw new PDOException("Impossibile eliminare la race");
            }
            break;
        default:
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid action for races']);
            exit();
    }
}
