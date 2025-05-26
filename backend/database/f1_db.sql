-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: mysql
-- Creato il: Mag 26, 2025 alle 20:26
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
  `nationality` varchar(100) DEFAULT NULL,
  `points` int NOT NULL DEFAULT '0',
  `logo_url` varchar(255) DEFAULT NULL,
  `year` int NOT NULL DEFAULT '2025',
  `external_id` varchar(32) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dump dei dati per la tabella `constructors`
--

INSERT INTO `constructors` (`id`, `name`, `nationality`, `points`, `logo_url`, `year`, `external_id`, `url`) VALUES
(1, 'Alpine F1 Team', 'French', 7, 'https://media.formula1.com/content/dam/fom-website/teams/2025/alpine-logo.png', 2025, 'alpine', 'http://en.wikipedia.org/wiki/Alpine_F1_Team'),
(2, 'Aston Martin', 'British', 14, 'https://media.formula1.com/content/dam/fom-website/teams/2025/aston-martin-logo.png', 2025, 'aston_martin', 'http://en.wikipedia.org/wiki/Aston_Martin_in_Formula_One'),
(3, 'Ferrari', 'Italian', 142, 'https://media.formula1.com/content/dam/fom-website/teams/2025/ferrari-logo.png', 2025, 'ferrari', 'http://en.wikipedia.org/wiki/Scuderia_Ferrari'),
(4, 'Haas F1 Team', 'American', 26, 'https://media.formula1.com/content/dam/fom-website/teams/2025/haas-logo.png', 2025, 'haas', 'http://en.wikipedia.org/wiki/Haas_F1_Team'),
(5, 'McLaren', 'British', 319, 'https://media.formula1.com/content/dam/fom-website/teams/2025/mclaren-logo.png', 2025, 'mclaren', 'http://en.wikipedia.org/wiki/McLaren'),
(6, 'Mercedes', 'German', 147, 'https://media.formula1.com/content/dam/fom-website/teams/2025/mercedes-logo.png', 2025, 'mercedes', 'http://en.wikipedia.org/wiki/Mercedes-Benz_in_Formula_One'),
(7, 'RB F1 Team', 'Italian', 22, 'https://media.formula1.com/content/dam/fom-website/teams/2025/racing-bulls-logo.png', 2025, 'rb', 'http://en.wikipedia.org/wiki/RB_Formula_One_Team'),
(8, 'Red Bull', 'Austrian', 143, 'https://media.formula1.com/content/dam/fom-website/teams/2025/red-bull-racing-logo.png', 2025, 'red_bull', 'http://en.wikipedia.org/wiki/Red_Bull_Racing'),
(9, 'Sauber', 'Swiss', 6, 'https://media.formula1.com/content/dam/fom-website/teams/2025/kick-sauber-logo.png', 2025, 'sauber', 'http://en.wikipedia.org/wiki/Sauber_Motorsport'),
(10, 'Williams', 'British', 54, 'https://media.formula1.com/content/dam/fom-website/teams/2025/williams-logo.png', 2025, 'williams', 'http://en.wikipedia.org/wiki/Williams_Grand_Prix_Engineering');

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
  `position` int NOT NULL DEFAULT '0',
  `nationality` varchar(100) DEFAULT '',
  `number` int DEFAULT '0',
  `date_of_birth` date DEFAULT NULL,
  `code` varchar(8) DEFAULT NULL,
  `team_id` int DEFAULT NULL,
  `description` text,
  `year` int NOT NULL DEFAULT '2025',
  `external_id` varchar(32) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dump dei dati per la tabella `drivers`
--

INSERT INTO `drivers` (`id`, `name`, `surname`, `points`, `image_url`, `position`, `nationality`, `number`, `date_of_birth`, `code`, `team_id`, `description`, `year`, `external_id`, `url`) VALUES
(1, 'Alexander', 'Albon', 42, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/A/ALEALB01_Alexander_Albon/alealb01.png', 8, 'Thai', 23, '1996-03-23', 'ALB', 10, '', 2025, 'albon', 'http://en.wikipedia.org/wiki/Alexander_Albon'),
(2, 'Fernando', 'Alonso', 0, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/F/FERALO01_Fernando_Alonso/feralo01.png', 18, 'Spanish', 14, '1981-07-29', 'ALO', 2, '', 2025, 'alonso', 'http://en.wikipedia.org/wiki/Fernando_Alonso'),
(3, 'Oliver', 'Bearman', 6, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/O/OLIBEA01_Oliver_Bearman/olibea01.png', 16, 'British', 87, '2005-05-08', 'BEA', 4, '', 2025, 'bearman', 'http://en.wikipedia.org/wiki/Oliver_Bearman'),
(4, 'Franco', 'Colapinto', 0, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/F/FRACOL01_Franco_Colapinto/fracol01.png', 20, 'Argentine', 43, '2003-05-27', 'COL', 1, '', 2025, 'colapinto', 'http://en.wikipedia.org/wiki/Franco_Colapinto'),
(6, 'Pierre', 'Gasly', 7, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/P/PIEGAS01_Pierre_Gasly/piegas01.png', 14, 'French', 10, '1996-02-07', 'GAS', 1, '', 2025, 'gasly', 'http://en.wikipedia.org/wiki/Pierre_Gasly'),
(7, 'Lewis', 'Hamilton', 63, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LEWHAM01_Lewis_Hamilton/lewham01.png', 6, 'British', 44, '1985-01-07', 'HAM', 3, '', 2025, 'hamilton', 'http://en.wikipedia.org/wiki/Lewis_Hamilton'),
(8, 'Nico', 'Hülkenberg', 6, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/N/NICHUL01_Nico_Hulkenberg/nichul01.png', 15, 'German', 27, '1987-08-19', 'HUL', 9, '', 2025, 'hulkenberg', 'http://en.wikipedia.org/wiki/Nico_H%C3%BClkenberg'),
(9, 'Liam', 'Lawson', 4, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LIALAW01_Liam_Lawson/lialaw01.png', 17, 'New Zealander', 30, '2002-02-11', 'LAW', 7, '', 2025, 'lawson', 'http://en.wikipedia.org/wiki/Liam_Lawson'),
(10, 'Charles', 'Leclerc', 79, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/C/CHALEC01_Charles_Leclerc/chalec01.png', 5, 'Monegasque', 16, '1997-10-16', 'LEC', 3, '', 2025, 'leclerc', 'http://en.wikipedia.org/wiki/Charles_Leclerc'),
(12, 'Lando', 'Norris', 158, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LANNOR01_Lando_Norris/lannor01.png', 2, 'British', 4, '1999-11-13', 'NOR', 5, '', 2025, 'norris', 'http://en.wikipedia.org/wiki/Lando_Norris'),
(13, 'Esteban', 'Ocon', 20, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/E/ESTOCO01_Esteban_Ocon/estoco01.png', 9, 'French', 31, '1996-09-17', 'OCO', 4, '', 2025, 'ocon', 'http://en.wikipedia.org/wiki/Esteban_Ocon'),
(14, 'Oscar', 'Piastri', 161, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/O/OSCPIA01_Oscar_Piastri/oscpia01.png', 1, 'Australian', 81, '2001-04-06', 'PIA', 5, '', 2025, 'piastri', 'http://en.wikipedia.org/wiki/Oscar_Piastri'),
(15, 'George', 'Russell', 99, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/G/GEORUS01_George_Russell/georus01.png', 4, 'British', 63, '1998-02-15', 'RUS', 6, '', 2025, 'russell', 'http://en.wikipedia.org/wiki/George_Russell_(racing_driver)'),
(16, 'Carlos', 'Sainz', 12, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/C/CARSAI01_Carlos_Sainz/carsai01.png', 12, 'Spanish', 55, '1994-09-01', 'SAI', 10, '', 2025, 'sainz', 'http://en.wikipedia.org/wiki/Carlos_Sainz_Jr.'),
(17, 'Lance', 'Stroll', 14, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LANSTR01_Lance_Stroll/lanstr01.png', 11, 'Canadian', 18, '1998-10-29', 'STR', 2, '', 2025, 'stroll', 'http://en.wikipedia.org/wiki/Lance_Stroll'),
(18, 'Yuki', 'Tsunoda', 10, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/Y/YUKTSU01_Yuki_Tsunoda/yuktsu01.png', 13, 'Japanese', 22, '2000-05-11', 'TSU', 8, '', 2025, 'tsunoda', 'http://en.wikipedia.org/wiki/Yuki_Tsunoda'),
(19, 'Max', 'Verstappen', 136, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/M/MAXVER01_Max_Verstappen/maxver01.png', 3, 'Dutch', 33, '1997-09-30', 'VER', 8, '', 2025, 'max_verstappen', 'http://en.wikipedia.org/wiki/Max_Verstappen'),
(274, 'Andrea Kimi', 'Antonelli', 48, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/K/ANDANT01_Kimi_Antonelli/andant01.png', 7, 'Italian', 12, '2006-08-25', 'ANT', 6, '', 2025, 'antonelli', 'https://en.wikipedia.org/wiki/Andrea_Kimi_Antonelli'),
(276, 'Gabriel', 'Bortoleto', 0, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/G/GABBOR01_Gabriel_Bortoleto/gabbor01.png', 21, 'Brazilian', 5, '2004-10-14', 'BOR', 9, '', 2025, 'bortoleto', 'https://en.wikipedia.org/wiki/Gabriel_Bortoleto'),
(280, 'Isack', 'Hadjar', 15, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/I/ISAHAD01_Isack_Hadjar/isahad01.png', 10, 'French', 6, '2004-09-28', 'HAD', 7, '', 2025, 'hadjar', 'https://en.wikipedia.org/wiki/Isack_Hadjar'),
(425, 'Jack', 'Doohan', 0, NULL, 19, 'Australian', 7, '2003-01-20', 'DOO', NULL, NULL, 2025, 'doohan', 'http://en.wikipedia.org/wiki/Jack_Doohan');

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
  `isPast` tinyint(1) NOT NULL DEFAULT '0',
  `year` int NOT NULL DEFAULT '2025'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dump dei dati per la tabella `races`
--

INSERT INTO `races` (`id`, `name`, `circuit`, `date`, `country`, `flag_url`, `isPast`, `year`) VALUES
(1, 'Bahrain Grand Prix', 'Bahrain International Circuit', '2026-03-05', '', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flag_of_Bahrain.svg/1024px-Flag_of_Bahrain.svg.png', 0, 2025),
(2, 'Saudi Arabian Grand Prix', 'Jeddah Corniche Circuit', '2023-03-19', '', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Flag_of_Saudi_Arabia.svg/1200px-Flag_of_Saudi_Arabia.svg.png', 1, 2025),
(3, 'Australian Grand Prix', 'Albert Park Circuit', '2023-04-02', '', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Flag_of_Australia.svg/1200px-Flag_of_Australia.svg.png', 1, 2025),
(4, 'Miami Grand Prix', 'Miami International Autodrome', '2023-05-07', '', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Flag_of_the_United_States.svg/1235px-Flag_of_the_United_States.svg.png', 1, 2025),
(5, 'Monaco Grand Prix', 'Circuit de Monaco', '2023-05-28', '', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Flag_of_Monaco.svg/1200px-Flag_of_Monaco.svg.png', 1, 2025);

-- --------------------------------------------------------

--
-- Struttura della tabella `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `users`
--

INSERT INTO `users` (`id`, `username`, `password`) VALUES
(1, 'EdViaz', '$2y$10$SGkoS3/pFxpY6kRnut25Ce24UaQaE136XinFZOEBSjzcVFjW5zpRS'),
(2, 'user1', '$2y$10$xjKLVjX19XlcG7wyo7CXB.zvMArHGZ94pkIB2oWYwQvIgRITKGTxy'),
(3, 'user2', '$2y$10$Y4DXxBsQWdMiKt70ZAmgIeiuIamxvyLjaL5foFP8J5l1YM6nvRQim'),
(4, 'user3', '$2y$10$pomvwhk0.UZmTHewQQoBje2QQACvlEvNJpttZKDSjVzDNJSdc1FUK'),
(5, 'testicolo', '$2y$10$vhCjue3I/UH6NFjHq9zD5u.cqS6080xgwGayMw5S5Wxw2UAS3r5mW');

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
  ADD PRIMARY KEY (`id`,`year`),
  ADD UNIQUE KEY `external_id_UNIQUE` (`external_id`,`year`);

--
-- Indici per le tabelle `drivers`
--
ALTER TABLE `drivers`
  ADD PRIMARY KEY (`id`,`year`),
  ADD UNIQUE KEY `external_id_UNIQUE` (`external_id`,`year`),
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
  ADD PRIMARY KEY (`id`,`year`);

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=342;

--
-- AUTO_INCREMENT per la tabella `drivers`
--
ALTER TABLE `drivers`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=650;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
