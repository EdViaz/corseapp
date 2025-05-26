<?php
// Configurazione JWT per l'applicazione
class JWTConfig {
    // IMPORTANTE: Cambia questa chiave in produzione!
    // Usa una chiave lunga e casuale, ad esempio generata con:
    // openssl rand -base64 64
    const SECRET_KEY = 'your_super_secret_jwt_key_change_in_production_minimum_32_characters_long';
    
    // Algoritmo di firma
    const ALGORITHM = 'HS256';
    
    // Durata dei token in secondi
    const ACCESS_TOKEN_EXPIRY = 3600;     // 1 ora
    const REFRESH_TOKEN_EXPIRY = 604800;  // 7 giorni
    
    // Issuer e audience
    const ISSUER = 'corseapp';
    const AUDIENCE = 'corseapp-users';
    
    // Per maggiore sicurezza in produzione:
    // 1. Usa variabili d'ambiente per le chiavi segrete
    // 2. Implementa una blacklist per i token invalidati
    // 3. Considera l'uso di HTTPS obbligatorio
    // 4. Implementa rate limiting sui login
}
?>
