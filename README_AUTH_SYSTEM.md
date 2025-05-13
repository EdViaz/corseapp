# Sistema di Login e Commenti per F1 App

Questo documento descrive come configurare e utilizzare il sistema di login opzionale e commenti implementato nell'applicazione F1.

## Configurazione del Database

1. Assicurati di avere un server MySQL in esecuzione (ad esempio tramite XAMPP o WAMP)
2. Crea un database chiamato `f1app` se non esiste già
3. Esegui lo script SQL presente in `backend/database/setup.sql` per creare le tabelle necessarie:
   - `users`: per memorizzare gli utenti registrati
   - `comments`: per memorizzare i commenti alle notizie

## Configurazione del Backend

1. Posiziona la cartella `backend` in una directory accessibile dal tuo server web (es. `htdocs` per XAMPP)
2. Verifica che i file PHP possano essere eseguiti correttamente
3. Se necessario, modifica i parametri di connessione al database nei file PHP:
   - `register.php`
   - `login.php`
   - `comments.php`
   - `add_comment.php`

## Funzionalità Implementate

### Lato Client (Flutter)

1. **Modelli di dati**:
   - `User`: rappresenta un utente registrato
   - `Comment`: rappresenta un commento a una notizia

2. **Servizi**:
   - `AuthService`: gestisce l'autenticazione e i commenti

3. **Schermate**:
   - `AuthScreen`: permette login e registrazione
   - `NewsDetailScreen`: modificata per mostrare e aggiungere commenti

### Lato Server (PHP)

1. **API Endpoints**:
   - `/register.php`: registrazione nuovo utente
   - `/login.php`: autenticazione utente
   - `/comments.php`: recupero commenti per una notizia
   - `/add_comment.php`: aggiunta di un nuovo commento

## Come Utilizzare il Sistema

### Per gli Utenti

1. Nella schermata di dettaglio di una notizia, gli utenti vedranno la sezione "Commenti"
2. Gli utenti non autenticati vedranno un pulsante "Accedi per commentare"
3. Dopo aver effettuato l'accesso, potranno scrivere e pubblicare commenti
4. L'autenticazione è opzionale: gli utenti possono comunque leggere le notizie senza accedere

### Per gli Sviluppatori

1. Il sistema utilizza `SharedPreferences` per mantenere la sessione dell'utente
2. I dati sensibili come le password vengono hashati prima di essere salvati nel database
3. Il sistema è progettato per essere facilmente estendibile con funzionalità aggiuntive

## Possibili Miglioramenti Futuri

- Aggiungere la possibilità di modificare/eliminare i propri commenti
- Implementare un sistema di moderazione per gli amministratori
- Aggiungere funzionalità di "Mi piace" ai commenti
- Implementare notifiche per le risposte ai commenti
- Aggiungere avatar personalizzati per gli utenti