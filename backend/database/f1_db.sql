-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: mysql
-- Creato il: Mag 23, 2025 alle 00:50
-- Versione del server: 8.0.42
-- Versione PHP: 8.2.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `f1_db`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `admin`
--

CREATE TABLE `admin` (
  `id` int NOT NULL,
  `username` varchar(900) NOT NULL,
  `password` varchar(900) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dump dei dati per la tabella `admin`
--

INSERT INTO `admin` (`id`, `username`, `password`) VALUES
(1, 'admin', '$2y$10$h769Emb.EiSnETKTYsC29uRWFosuZuxoYT8VlFunVlpAXtkt4hSLK');

-- --------------------------------------------------------

--
-- Struttura della tabella `comments`
--

CREATE TABLE `comments` (
  `id` int NOT NULL,
  `news_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text NOT NULL,
  `date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dump dei dati per la tabella `comments`
--

INSERT INTO `comments` (`id`, `news_id`, `user_id`, `content`, `date`) VALUES
(2, 1, 1, 'test', '2025-05-14'),
(4, 1, 2, 'tung tung', '2025-05-15'),
(5, 1, 2, 'test', '2025-05-15'),
(6, 3, 3, 'ciao', '2025-05-23'),
(7, 4, 3, 'suca', '2025-05-23'),
(8, 5, 2, 'wow', '2025-05-23');

-- --------------------------------------------------------

--
-- Struttura della tabella `constructors`
--

CREATE TABLE `constructors` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `points` int NOT NULL DEFAULT '0',
  `logo_url` varchar(255) DEFAULT NULL,
  `position` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dump dei dati per la tabella `constructors`
--

INSERT INTO `constructors` (`id`, `name`, `points`, `logo_url`, `position`) VALUES
(1, 'Red Bull Racing', 105, 'https://media.formula1.com/content/dam/fom-website/teams/2025/red-bull-racing-logo.png', 1),
(2, 'Ferrari', 94, 'https://media.formula1.com/content/dam/fom-website/teams/2025/ferrari-logo.png', 2),
(3, 'Mercedes', 141, 'https://media.formula1.com/content/dam/fom-website/teams/2025/mercedes-logo.png', 3),
(4, 'McLaren', 246, 'https://media.formula1.com/content/dam/fom-website/teams/2025/mclaren-logo.png', 4),
(6, 'Williams', 37, 'https://media.formula1.com/content/dam/fom-website/teams/2025/williams-logo.png', 0),
(7, 'Haas', 20, 'https://media.formula1.com/content/dam/fom-website/teams/2025/haas-logo.png', 0),
(8, 'Aston Martin', 14, 'https://media.formula1.com/content/dam/fom-website/teams/2025/aston-martin-logo.png', 0),
(9, 'Racing Bulls', 8, 'https://media.formula1.com/content/dam/fom-website/teams/2025/racing-bulls-logo.png', 0),
(10, 'Alpine', 7, 'https://media.formula1.com/content/dam/fom-website/teams/2025/alpine-logo.png', 0),
(11, 'Stake Kick Sauber', 6, 'https://media.formula1.com/content/dam/fom-website/teams/2025/kick-sauber-logo.png', 0);

-- --------------------------------------------------------

--
-- Struttura della tabella `drivers`
--

CREATE TABLE `drivers` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `surname` varchar(100) NOT NULL,
  `points` int NOT NULL DEFAULT '0',
  `image_url` varchar(255) DEFAULT NULL,
  `position` int NOT NULL,
  `nationality` varchar(100) DEFAULT '',
  `number` int DEFAULT '0',
  `team_id` int DEFAULT NULL,
  `description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dump dei dati per la tabella `drivers`
--

INSERT INTO `drivers` (`id`, `name`, `surname`, `points`, `image_url`, `position`, `nationality`, `number`, `team_id`, `description`) VALUES
(1, 'Max', 'Verstappen', 450, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/M/MAXVER01_Max_Verstappen/maxver01.png', 1, 'Dutch', 33, 1, NULL),
(2, 'Lewis', 'Hamilton', 350, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LEWHAM01_Lewis_Hamilton/lewham01.png', 2, 'British', 44, 2, NULL),
(3, 'Charles', 'Leclerc', 300, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/C/CHALEC01_Charles_Leclerc/chalec01.png', 3, '', 16, 2, NULL),
(4, 'Lando', 'Norris', 250, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LANNOR01_Lando_Norris/lannor01.png', 4, '', 4, 4, NULL),
(6, 'Oscar', 'Piastri', 131, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/O/OSCPIA01_Oscar_Piastri/oscpia01.png', 0, '', 12, 4, NULL),
(7, 'George', 'Russel', 9, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/G/GEORUS01_George_Russell/georus01.png', 6, '', 63, 3, NULL);

-- --------------------------------------------------------

--
-- Struttura della tabella `news`
--

CREATE TABLE `news` (
  `id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `publish_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dump dei dati per la tabella `news`
--

INSERT INTO `news` (`id`, `title`, `content`, `image_url`, `publish_date`) VALUES
(1, 'Verstappen vince il mondiale', 'Max Verstappen è riuscito a vincere il terzo mondiale', 'https://img.redbull.com/images/c_limit,w_1500,h_1000/f_auto,q_auto/redbullcom/2024/11/24/nrqoxx9as35r5ry8ashm/max-verstapen-2024-f1-world-champion-four', '2023-10-25 14:30:00'),
(2, 'Hamilton firma con la Ferrari', 'Lewis Hamilton ha firmato un contratto di più anni con la Scuderia di Maranello', 'https://media.formula1.com/image/upload/f_auto,c_limit,w_960,q_auto/t_16by9Centre/f_auto/q_auto/fom-website/2025/Emilia-Romagna/Formula%201%20header%20templates%20-%202025-05-16T191520.197', '2025-05-22 23:46:32'),
(3, 'Ferrari delude le aspettative a Miami', 'Ferrari data la scarsa prestazione ottenuta, delude i propri Tifosi', 'https://media.formula1.com/image/upload/f_auto,c_limit,w_960,q_auto/t_16by9Centre/f_auto/q_auto/fom-website/2025/Emilia-Romagna/Leclerc%20Hamilton%20header%20image%20Imola%20Saturday', '2025-05-22 23:47:10'),
(4, 'La F1 annuncia nuove piste: il nuovo granpremio di Spagna', 'nuovo gp di Madrid che sostituirà quello di Barcellona a partire dal 2027', 'https://media.formula1.com/image/upload/f_auto,c_limit,w_960,q_auto/f_auto/q_auto/fom-website/2025/Miscellaneous/Plano%20MADRING%20-%20@%20IFEMA%20MADRID', '2025-05-23 01:53:15'),
(5, 'McLaren Update tecnico', 'Nuovo pacchetto di aggiornamenti per McLaren', 'https://img.stcrm.it/images/44186968/HOR_WIDE/800x/grfrv78wyaanxi9.jpeg', '2023-10-05 11:30:00');

-- --------------------------------------------------------

--
-- Struttura della tabella `races`
--

CREATE TABLE `races` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `circuit` varchar(100) NOT NULL,
  `date` date NOT NULL,
  `country` varchar(100) NOT NULL,
  `flag_url` varchar(255) DEFAULT NULL,
  `isPast` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dump dei dati per la tabella `races`
--

INSERT INTO `races` (`id`, `name`, `circuit`, `date`, `country`, `flag_url`, `isPast`) VALUES
(1, 'Bahrain Grand Prix', 'Bahrain International Circuit', '2026-03-05', '', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flag_of_Bahrain.svg/1024px-Flag_of_Bahrain.svg.png', 0),
(2, 'Saudi Arabian Grand Prix', 'Jeddah Corniche Circuit', '2023-03-19', '', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Flag_of_Saudi_Arabia.svg/1200px-Flag_of_Saudi_Arabia.svg.png', 1),
(3, 'Australian Grand Prix', 'Albert Park Circuit', '2023-04-02', '', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Flag_of_Australia.svg/1200px-Flag_of_Australia.svg.png', 1),
(4, 'Miami Grand Prix', 'Miami International Autodrome', '2023-05-07', '', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Flag_of_the_United_States.svg/1235px-Flag_of_the_United_States.svg.png', 1),
(5, 'Monaco Grand Prix', 'Circuit de Monaco', '2023-05-28', '', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Flag_of_Monaco.svg/1200px-Flag_of_Monaco.svg.png', 1);

-- --------------------------------------------------------

--
-- Struttura della tabella `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(100) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `users`
--

INSERT INTO `users` (`id`, `username`, `password`) VALUES
(1, 'EdViaz', '$2y$10$SGkoS3/pFxpY6kRnut25Ce24UaQaE136XinFZOEBSjzcVFjW5zpRS'),
(2, 'user1', '$2y$10$xjKLVjX19XlcG7wyo7CXB.zvMArHGZ94pkIB2oWYwQvIgRITKGTxy'),
(3, 'user2', '$2y$10$Y4DXxBsQWdMiKt70ZAmgIeiuIamxvyLjaL5foFP8J5l1YM6nvRQim');

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `comments_ibfk_1` (`news_id`),
  ADD KEY `comments_ibfk_2` (`user_id`);

--
-- Indici per le tabelle `constructors`
--
ALTER TABLE `constructors`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `drivers`
--
ALTER TABLE `drivers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_team` (`team_id`);

--
-- Indici per le tabelle `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `races`
--
ALTER TABLE `races`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT per la tabella `comments`
--
ALTER TABLE `comments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT per la tabella `constructors`
--
ALTER TABLE `constructors`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT per la tabella `drivers`
--
ALTER TABLE `drivers`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT per la tabella `news`
--
ALTER TABLE `news`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT per la tabella `races`
--
ALTER TABLE `races`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT per la tabella `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`news_id`) REFERENCES `news` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Limiti per la tabella `drivers`
--
ALTER TABLE `drivers`
  ADD CONSTRAINT `fk_team` FOREIGN KEY (`team_id`) REFERENCES `constructors` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
