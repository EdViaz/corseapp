<?php
// Script di test per verificare il funzionamento del sistema JWT
header('Content-Type: text/html; charset=utf-8');

echo "<h1>Test JWT System - CorseApp</h1>";

// Include dependencies
require_once __DIR__ . '/api/jwt_helper.php';

echo "<h2>1. Test Generazione Token</h2>";

try {
    // Test generazione access token
    $access_token = JWTHelper::generateAccessToken(1, 'test_user', 'user');
    echo "<p>✅ Access Token generato: " . substr($access_token, 0, 50) . "...</p>";
    
    // Test generazione refresh token
    $refresh_token = JWTHelper::generateRefreshToken(1, 'test_user', 'user');
    echo "<p>✅ Refresh Token generato: " . substr($refresh_token, 0, 50) . "...</p>";
    
    echo "<h2>2. Test Validazione Token</h2>";
    
    // Test validazione access token
    $validation = JWTHelper::validateToken($access_token);
    if ($validation['success']) {
        echo "<p>✅ Access Token validato con successo</p>";
        echo "<p>Dati: " . json_encode($validation['data']->data) . "</p>";
    } else {
        echo "<p>❌ Errore validazione Access Token: " . $validation['message'] . "</p>";
    }
    
    // Test validazione refresh token
    $validation = JWTHelper::validateToken($refresh_token);
    if ($validation['success']) {
        echo "<p>✅ Refresh Token validato con successo</p>";
        echo "<p>Tipo: " . ($validation['data']->type ?? 'access') . "</p>";
    } else {
        echo "<p>❌ Errore validazione Refresh Token: " . $validation['message'] . "</p>";
    }
    
    echo "<h2>3. Test Refresh Token</h2>";
    
    // Test refresh tokens
    $refresh_result = JWTHelper::refreshTokens($refresh_token);
    if ($refresh_result['success']) {
        echo "<p>✅ Refresh completato con successo</p>";
        echo "<p>Nuovo Access Token: " . substr($refresh_result['access_token'], 0, 50) . "...</p>";
    } else {
        echo "<p>❌ Errore refresh: " . $refresh_result['message'] . "</p>";
    }
    
    echo "<h2>4. Test Token Scaduto</h2>";
    
    // Simula un token scaduto modificando manualmente la data
    $expired_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjb3JzZWFwcCIsImF1ZCI6ImNvcnNlYXBwLXVzZXJzIiwiaWF0IjoxNjQwOTk1MjAwLCJleHAiOjE2NDA5OTUyMDAsImRhdGEiOnsidXNlcl9pZCI6MSwidXNlcm5hbWUiOiJ0ZXN0X3VzZXIiLCJyb2xlIjoidXNlciJ9fQ.invalid";
    $validation = JWTHelper::validateToken($expired_token);
    if (!$validation['success']) {
        echo "<p>✅ Token scaduto correttamente rilevato: " . $validation['message'] . "</p>";
    } else {
        echo "<p>❌ Token scaduto non rilevato correttamente</p>";
    }
    
    echo "<h2>5. Test Configurazione</h2>";
    
    // Verifica configurazione
    echo "<p>Algoritmo: " . JWTConfig::ALGORITHM . "</p>";
    echo "<p>Durata Access Token: " . JWTConfig::ACCESS_TOKEN_EXPIRY . " secondi</p>";
    echo "<p>Durata Refresh Token: " . JWTConfig::REFRESH_TOKEN_EXPIRY . " secondi</p>";
    echo "<p>Issuer: " . JWTConfig::ISSUER . "</p>";
    echo "<p>Audience: " . JWTConfig::AUDIENCE . "</p>";
    
    if (JWTConfig::SECRET_KEY === 'your_super_secret_jwt_key_change_in_production_minimum_32_characters_long') {
        echo "<p>⚠️ <strong>ATTENZIONE:</strong> Stai usando la chiave segreta di default! Cambiala in produzione!</p>";
    } else {
        echo "<p>✅ Chiave segreta personalizzata configurata</p>";
    }
    
} catch (Exception $e) {
    echo "<p>❌ Errore durante i test: " . $e->getMessage() . "</p>";
}

echo "<h2>6. Endpoint Disponibili</h2>";
echo "<ul>";
echo "<li><strong>POST</strong> /api/login.php - Login utenti</li>";
echo "<li><strong>POST</strong> /api/admin_login.php - Login admin</li>";
echo "<li><strong>POST</strong> /api/refresh_token.php - Refresh token</li>";
echo "<li><strong>GET</strong> /api/verify_token.php - Verifica token</li>";
echo "<li><strong>POST</strong> /api/logout.php - Logout</li>";
echo "<li><strong>POST</strong> /api/add_comment.php - Aggiungere commenti (richiede auth)</li>";
echo "<li><strong>POST/DELETE</strong> /api/admin_api.php - Operazioni admin (richiede auth admin)</li>";
echo "</ul>";

echo "<h2>7. Come Testare</h2>";
echo "<ol>";
echo "<li>Fai login con POST a /api/login.php o /api/admin_login.php</li>";
echo "<li>Salva il token ricevuto</li>";
echo "<li>Usa il token nell'header Authorization: Bearer [token]</li>";
echo "<li>Testa gli endpoint protetti</li>";
echo "</ol>";

echo "<hr>";
echo "<p><em>Test completato - " . date('Y-m-d H:i:s') . "</em></p>";
?>
