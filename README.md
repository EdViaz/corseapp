# CorseApp - Funzionamento Tecnico e Utente

## Descrizione Generale
CorseApp è un'applicazione Flutter per la gestione e la consultazione di notizie, classifiche, piloti, team e gare di Formula 1. L'app è pensata per appassionati e amministratori, con funzionalità sia pubbliche che riservate.

---

## Funzionamento Tecnico (Flutter + Backend PHP)

### Architettura
- **Frontend:** Flutter (Dart)
- **Backend:** PHP (REST API)
- **Database:** MySQL (tramite Docker)

### Struttura Principale
- `/lib/screens/` - Schermate principali dell'app (Home, Classifiche, Dettaglio Pilota, Admin, ecc.)
- `/lib/models/` - Modelli dati (Driver, Constructor, News, ecc.)
- `/lib/services/` - Servizi per chiamate API, autenticazione, preferenze
- `/backend/api/` - Endpoint PHP per tutte le operazioni CRUD
- `/backend/database/` - Script SQL per la struttura e i dati iniziali

### Flusso Dati
1. **Lato utente:**
   - L'app Flutter effettua richieste HTTP alle API PHP per ottenere dati (piloti, team, news, gare).
   - I dati vengono mostrati tramite FutureBuilder e modelli Dart.
   - L'utente può consultare classifiche, dettagli, biografie, news e aggiungere piloti ai preferiti.
2. **Lato admin:**
   - Accesso tramite login amministratore.
   - Possibilità di aggiungere, modificare o eliminare piloti, team, news e gare.
   - Le modifiche vengono inviate tramite POST alle API PHP, che aggiornano il database.

### Autenticazione
- Gli utenti possono registrarsi e accedere per salvare preferiti e commenti.
- Gli admin accedono tramite credenziali dedicate e ricevono un token per le operazioni protette.

### Localizzazione
- Tutti i testi sono in italiano.

---

## Funzionamento Utente

### Utente Normale
- **Home:** Visualizza le ultime notizie.
- **Classifiche:** Consulta la classifica piloti e costruttori, accede ai dettagli di ogni pilota/team.
- **Gare:** Visualizza calendario e risultati delle gare.
- **Profilo:** Gestisce i piloti preferiti e i propri commenti.

### Amministratore
- **Pannello Admin:**
  - Gestisce piloti (aggiunta, modifica, eliminazione, biografia, team, punti, ecc.)
  - Gestisce team/costruttori.
  - Gestisce news.
  - Gestisce gare.

---

## Database
- **Tabelle principali:** `drivers`, `constructors`, `news`, `races`, `comments`, `users`
- **Relazioni:**
  - `drivers.team_id` → `constructors.id`
  - Commenti e preferiti collegati agli utenti



---

## Avvio rapido (sviluppo)
1. Avvia il backend con Docker (`docker-compose up`)
2. Avvia l'app Flutter (`flutter run`)
3. Accedi come admin per gestire i dati oppure usa l'app come utente normale

---

## Note
- Tutti i dati sono fittizi e aggiornabili da pannello admin.
- L'app è pensata per essere responsive e usabile sia su mobile che desktop.
