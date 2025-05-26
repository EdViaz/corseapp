<?php
// sync_f1_data_clean.php
// Script che restituisce solo JSON per l'interfaccia admin
require_once __DIR__ . '/../config/config.php';

function fetch_jolpica_api($endpoint)
{
    $baseUrl = 'http://api.jolpi.ca/ergast/f1';
    $url = $baseUrl . $endpoint;

    $opts = [
        "http" => [
            "header" => "User-Agent: corseapp/1.0\r\n",
            "timeout" => 15
        ]
    ];
    $context = stream_context_create($opts);
    $json = @file_get_contents($url, false, $context);

    if ($json === false) {
        throw new Exception("Errore nella connessione a Jolpica API: $endpoint");
    }

    $data = json_decode($json, true);
    if ($data === null) {
        throw new Exception("Errore nel parsing JSON da Jolpica API: $endpoint");
    }

    return $data;
}

try {
    $database = new Database();
    $conn = $database->getConnection();

    // 1. Aggiorna piloti
    $driversData = fetch_jolpica_api('/current/drivers.json');
    $drivers = $driversData['MRData']['DriverTable']['Drivers'] ?? [];    $driversUpdated = 0;
    foreach ($drivers as $driver) {
        $id = $driver['driverId'];
        $name = $driver['givenName'];
        $surname = $driver['familyName'];
        $nationality = $driver['nationality'];
        $number = isset($driver['permanentNumber']) ? $driver['permanentNumber'] : null;
        $url = $driver['url'] ?? '';

        // Inserisci o aggiorna solo con le colonne esistenti
        $stmt = $conn->prepare('INSERT INTO drivers (external_id, name, surname, nationality, number, url, year)
            VALUES (?, ?, ?, ?, ?, ?, 2025)
            ON DUPLICATE KEY UPDATE name=VALUES(name), surname=VALUES(surname), nationality=VALUES(nationality), number=VALUES(number), url=VALUES(url)');
        $stmt->execute([$id, $name, $surname, $nationality, $number, $url]);
        $driversUpdated++;
    }

    // 1b. Aggiorna punti piloti da Jolpica Standings
    $standingsData = fetch_jolpica_api('/current/driverStandings.json');
    $standings = $standingsData['MRData']['StandingsTable']['StandingsLists'][0]['DriverStandings'] ?? [];    $pointsUpdated = 0;
    foreach ($standings as $standing) {
        $driverId = $standing['Driver']['driverId'];
        $points = $standing['points'];
        $position = $standing['position'];
        $stmt = $conn->prepare('UPDATE drivers SET points = ?, position = ? WHERE external_id = ? AND year = 2025');
        $stmt->execute([$points, $position, $driverId]);
        $pointsUpdated++;
    }

    // 2. Aggiorna team
    $constructorsData = fetch_jolpica_api('/current/constructors.json');
    $constructors = $constructorsData['MRData']['ConstructorTable']['Constructors'] ?? [];    $teamsUpdated = 0;
    foreach ($constructors as $team) {
        $id = $team['constructorId'];
        $name = $team['name'];
        $nationality = $team['nationality'];
        $url = $team['url'] ?? '';
        
        // Inserisci o aggiorna solo con le colonne esistenti
        $stmt = $conn->prepare('INSERT INTO constructors (external_id, name, url, year)
            VALUES (?, ?, ?, 2025)
            ON DUPLICATE KEY UPDATE name=VALUES(name), url=VALUES(url)');
        $stmt->execute([$id, $name, $url]);
        $teamsUpdated++;
    }

    // 2b. Aggiorna punti team da Jolpica Constructor Standings
    $constructorStandingsData = fetch_jolpica_api('/current/constructorStandings.json');
    $constructorStandings = $constructorStandingsData['MRData']['StandingsTable']['StandingsLists'][0]['ConstructorStandings'] ?? [];    $teamPointsUpdated = 0;
    foreach ($constructorStandings as $standing) {
        $constructorId = $standing['Constructor']['constructorId'];
        $points = $standing['points'];
        $stmt = $conn->prepare('UPDATE constructors SET points = ? WHERE external_id = ? AND year = 2025');
        $stmt->execute([$points, $constructorId]);
        $teamPointsUpdated++;
    }

    // Restituisci solo JSON
    echo json_encode([
        "success" => true,
        "message" => "Aggiornamento completato con Jolpica API",
        "stats" => [
            "drivers_updated" => $driversUpdated,
            "driver_points_updated" => $pointsUpdated,
            "teams_updated" => $teamsUpdated,
            "team_points_updated" => $teamPointsUpdated
        ]
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
