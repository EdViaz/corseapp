# Configurazione Docker per corseapp

Questo documento spiega come configurare e avviare l'ambiente di sviluppo per corseapp utilizzando Docker.

## Prerequisiti

- [Docker](https://www.docker.com/products/docker-desktop/) installato sul tuo sistema
- [Docker Compose](https://docs.docker.com/compose/install/) installato sul tuo sistema

## Struttura dell'ambiente

L'ambiente Docker è composto da tre servizi principali:

1. **PHP con Apache**: Serve l'applicazione backend PHP
2. **MySQL**: Database per memorizzare i dati dell'applicazione
3. **phpMyAdmin**: Interfaccia web per gestire il database (opzionale)

## Configurazione

Tutti i file di configurazione necessari sono già presenti nel repository:

- `docker-compose.yml`: Definisce i servizi, le reti e i volumi
- `backend/Dockerfile`: Configura l'immagine PHP con le estensioni necessarie
- `backend/config/php.ini`: Configurazione personalizzata di PHP
- `backend/config/config.php`: Configurazione del database (aggiornata per utilizzare variabili d'ambiente)

## Avvio dell'ambiente

Per avviare l'ambiente Docker, segui questi passaggi:

1. Apri un terminale nella directory principale del progetto (dove si trova il file `docker-compose.yml`)
2. Esegui il comando:

```bash
docker-compose up -d
```

Questo comando avvierà tutti i servizi in modalità detached (in background).

## Accesso ai servizi

Dopo l'avvio, puoi accedere ai servizi tramite i seguenti URL:

- **Backend PHP**: http://localhost/backend/api/
- **phpMyAdmin**: http://localhost:8080/
  - Username: corseapp_user
  - Password: corseapp_password

## Configurazione dell'app Flutter

Per configurare l'app Flutter per utilizzare il backend Docker:

1. Assicurati che l'app Flutter utilizzi `http://localhost/backend/api` come URL base per le chiamate API
2. Se stai testando su un dispositivo fisico, potresti dover utilizzare l'indirizzo IP del tuo computer invece di `localhost`

## Arresto dell'ambiente

Per arrestare l'ambiente Docker, esegui:

```bash
docker-compose down
```

Se desideri eliminare anche i volumi (e quindi i dati del database), aggiungi l'opzione `-v`:

```bash
docker-compose down -v
```

## Risoluzione dei problemi

### Problemi di connessione al database

Se l'app non riesce a connettersi al database, verifica che:

1. I container Docker siano in esecuzione (`docker ps`)
2. Le credenziali del database nel file `docker-compose.yml` corrispondano a quelle utilizzate nell'app
3. Il database sia stato inizializzato correttamente (puoi verificarlo tramite phpMyAdmin)

### Problemi di permessi

Se riscontri problemi di permessi nei file, puoi eseguire:

```bash
docker-compose exec php chown -R www-data:www-data /var/www/html
```

## Note per lo sviluppo

- I file nella directory `backend` sono montati come volume nel container PHP, quindi le modifiche ai file PHP saranno immediatamente disponibili senza dover riavviare i container
- Il database viene inizializzato con lo schema presente in `backend/database/f1_db.sql`
- Per accedere al pannello di amministrazione, utilizza le credenziali predefinite (username: admin, password: admin)