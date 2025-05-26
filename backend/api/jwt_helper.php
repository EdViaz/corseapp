<?php
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/../config/jwt_config.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JWTHelper {
    /**
     * Genera un access token JWT
     */
    public static function generateAccessToken($user_id, $username, $role = 'user') {
        $issued_at = time();
        $expiration_time = $issued_at + JWTConfig::ACCESS_TOKEN_EXPIRY;
        
        $payload = array(
            "iss" => JWTConfig::ISSUER, // issuer
            "aud" => JWTConfig::AUDIENCE, // audience
            "iat" => $issued_at, // issued at
            "exp" => $expiration_time, // expiration time
            "data" => array(
                "user_id" => $user_id,
                "username" => $username,
                "role" => $role
            )
        );

        return JWT::encode($payload, JWTConfig::SECRET_KEY, JWTConfig::ALGORITHM);
    }

    /**
     * Genera un refresh token JWT
     */
    public static function generateRefreshToken($user_id, $username, $role = 'user') {
        $issued_at = time();
        $expiration_time = $issued_at + JWTConfig::REFRESH_TOKEN_EXPIRY;
        
        $payload = array(
            "iss" => JWTConfig::ISSUER,
            "aud" => JWTConfig::AUDIENCE,
            "iat" => $issued_at,
            "exp" => $expiration_time,
            "type" => "refresh",
            "data" => array(
                "user_id" => $user_id,
                "username" => $username,
                "role" => $role
            )
        );

        return JWT::encode($payload, JWTConfig::SECRET_KEY, JWTConfig::ALGORITHM);
    }    /**
     * Decodifica e valida un token JWT
     */
    public static function validateToken($token) {
        try {
            $decoded = JWT::decode($token, new Key(JWTConfig::SECRET_KEY, JWTConfig::ALGORITHM));
            return array(
                "success" => true,
                "data" => $decoded
            );
        } catch (Exception $e) {
            return array(
                "success" => false,
                "message" => "Token non valido: " . $e->getMessage()
            );
        }
    }

    /**
     * Estrae il token dal header Authorization
     */
    public static function getBearerToken() {
        $headers = apache_request_headers();
        
        if (isset($headers['Authorization'])) {
            if (preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
                return $matches[1];
            }
        }
        
        return null;
    }

    /**
     * Middleware per verificare l'autenticazione
     */
    public static function requireAuth($required_role = null) {
        $token = self::getBearerToken();
        
        if (!$token) {
            http_response_code(401);
            echo json_encode(array(
                "success" => false,
                "message" => "Token di accesso richiesto"
            ));
            exit;
        }

        $validation = self::validateToken($token);
        
        if (!$validation['success']) {
            http_response_code(401);
            echo json_encode(array(
                "success" => false,
                "message" => $validation['message']
            ));
            exit;
        }

        $user_data = $validation['data']->data;

        // Verifica il ruolo se richiesto
        if ($required_role && $user_data->role !== $required_role) {
            http_response_code(403);
            echo json_encode(array(
                "success" => false,
                "message" => "Accesso negato: privilegi insufficienti"
            ));
            exit;
        }

        return $user_data;
    }

    /**
     * Genera nuovi token usando un refresh token
     */
    public static function refreshTokens($refresh_token) {
        $validation = self::validateToken($refresh_token);
        
        if (!$validation['success']) {
            return array(
                "success" => false,
                "message" => "Refresh token non valido"
            );
        }

        $token_data = $validation['data'];
        
        // Verifica che sia un refresh token
        if (!isset($token_data->type) || $token_data->type !== 'refresh') {
            return array(
                "success" => false,
                "message" => "Token non valido per il refresh"
            );
        }

        $user_data = $token_data->data;
        
        return array(
            "success" => true,
            "access_token" => self::generateAccessToken($user_data->user_id, $user_data->username, $user_data->role),
            "refresh_token" => self::generateRefreshToken($user_data->user_id, $user_data->username, $user_data->role)
        );
    }
}
