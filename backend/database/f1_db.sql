-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Mag 14, 2025 alle 01:02
-- Versione del server: 10.4.32-MariaDB
-- Versione PHP: 8.2.12

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
  `id` int(50) NOT NULL,
  `username` varchar(900) NOT NULL,
  `password` varchar(900) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

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
  `id` int(11) NOT NULL,
  `news_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dump dei dati per la tabella `comments`
--

INSERT INTO `comments` (`id`, `news_id`, `user_id`, `content`, `date`) VALUES
(2, 1, 1, 'test', '2025-05-14');

-- --------------------------------------------------------

--
-- Struttura della tabella `constructors`
--

CREATE TABLE `constructors` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `points` int(11) NOT NULL DEFAULT 0,
  `logo_url` varchar(255) DEFAULT NULL,
  `position` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dump dei dati per la tabella `constructors`
--

INSERT INTO `constructors` (`id`, `name`, `points`, `logo_url`, `position`) VALUES
(1, 'Red Bull Racing', 600, 'https://media.formula1.com/content/dam/fom-website/teams/2025/red-bull-racing-logo.png', 1),
(2, 'Ferrari', 540, 'https://media.formula1.com/content/dam/fom-website/teams/2025/ferrari-logo.png', 2),
(3, 'Mercedes', 500, 'https://media.formula1.com/content/dam/fom-website/teams/2025/mercedes-logo.png', 3),
(4, 'McLaren', 400, 'https://media.formula1.com/content/dam/fom-website/teams/2025/mclaren-logo.png', 4),
(6, 'Williams', 0, 'https://media.formula1.com/content/dam/fom-website/teams/2025/williams-logo.png', 0),
(7, 'Haas', 0, 'https://media.formula1.com/content/dam/fom-website/teams/2025/haas-logo.png', 0),
(8, 'Aston Martin', 0, 'https://media.formula1.com/content/dam/fom-website/teams/2025/aston-martin-logo.png', 0),
(9, 'Racing Bulls', 0, 'https://media.formula1.com/content/dam/fom-website/teams/2025/racing-bulls-logo.png', 0),
(10, 'Alpine', 0, 'https://media.formula1.com/content/dam/fom-website/teams/2025/alpine-logo.png', 0),
(11, 'Kick Sauber', 0, 'https://media.formula1.com/content/dam/fom-website/teams/2025/kick-sauber-logo.png', 0);

-- --------------------------------------------------------

--
-- Struttura della tabella `drivers`
--

CREATE TABLE `drivers` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `surname` varchar(100) NOT NULL,
  `team` varchar(100) NOT NULL,
  `points` int(11) NOT NULL DEFAULT 0,
  `image_url` varchar(255) DEFAULT NULL,
  `position` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dump dei dati per la tabella `drivers`
--

INSERT INTO `drivers` (`id`, `name`, `surname`, `team`, `points`, `image_url`, `position`) VALUES
(1, 'Max', 'Verstappen', 'Red Bull Racing', 450, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/M/MAXVER01_Max_Verstappen/maxver01.png', 1),
(2, 'Lewis', 'Hamilton', 'Ferrari', 350, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LEWHAM01_Lewis_Hamilton/lewham01.png', 2),
(3, 'Charles', 'Leclerc', 'Ferrari', 300, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/C/CHALEC01_Charles_Leclerc/chalec01.png', 3),
(4, 'Lando', 'Norris', 'McLaren', 250, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LANNOR01_Lando_Norris/lannor01.png', 4),
(6, 'Oscar', 'Piastri', 'McLaren', 131, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/O/OSCPIA01_Oscar_Piastri/oscpia01.png', 0),
(7, 'George', 'Russel', 'Mercedes', 0, 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/G/GEORUS01_George_Russell/georus01.png', 0);

-- --------------------------------------------------------

--
-- Struttura della tabella `news`
--

CREATE TABLE `news` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `publish_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dump dei dati per la tabella `news`
--

INSERT INTO `news` (`id`, `title`, `content`, `image_url`, `publish_date`) VALUES
(1, 'Verstappen Wins Championship', 'Max Verstappen has secured his third world championship...', 'https://img.redbull.com/images/c_limit,w_1500,h_1000/f_auto,q_auto/redbullcom/2024/11/24/nrqoxx9as35r5ry8ashm/max-verstapen-2024-f1-world-champion-four', '2023-10-25 14:30:00'),
(2, 'Hamilton Signs New Contract', 'Lewis Hamilton has signed a new two-year contract with Mercedes...', 'https://example.com/news2.jpg', '2023-10-20 10:15:00'),
(3, 'Ferrari Unveils New Car', 'Ferrari has unveiled their new car for the upcoming season...', 'https://example.com/news3.jpg', '2023-10-15 09:00:00'),
(4, 'F1 Announces New Race', 'Formula 1 has announced a new race in Madrid starting from 2026...', 'https://example.com/news4.jpg', '2023-10-10 16:45:00'),
(5, 'McLaren Technical Update', 'McLaren has introduced a significant technical update to their car...', 'https://example.com/news5.jpg', '2023-10-05 11:30:00');

-- --------------------------------------------------------

--
-- Struttura della tabella `races`
--

CREATE TABLE `races` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `circuit` varchar(100) NOT NULL,
  `date` date NOT NULL,
  `country` varchar(100) NOT NULL,
  `flag_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dump dei dati per la tabella `races`
--

INSERT INTO `races` (`id`, `name`, `circuit`, `date`, `country`, `flag_url`) VALUES
(1, 'Bahrain Grand Prix', 'Bahrain International Circuit', '2023-03-05', 'Bahrain', 'https://example.com/bahrain.jpg'),
(2, 'Saudi Arabian Grand Prix', 'Jeddah Corniche Circuit', '2023-03-19', 'Saudi Arabia', 'https://example.com/saudi.jpg'),
(3, 'Australian Grand Prix', 'Albert Park Circuit', '2023-04-02', 'Australia', 'https://example.com/australia.jpg'),
(4, 'Miami Grand Prix', 'Miami International Autodrome', '2023-05-07', 'United States', 'https://example.com/usa.jpg'),
(5, 'Monaco Grand Prix', 'Circuit de Monaco', '2023-05-28', 'Monaco', 'https://example.com/monaco.jpg');

-- --------------------------------------------------------

--
-- Struttura della tabella `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `users`
--

INSERT INTO `users` (`id`, `username`, `password`) VALUES
(1, 'EdViaz', '$2y$10$SGkoS3/pFxpY6kRnut25Ce24UaQaE136XinFZOEBSjzcVFjW5zpRS');

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
  ADD PRIMARY KEY (`id`);

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
  MODIFY `id` int(50) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT per la tabella `comments`
--
ALTER TABLE `comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT per la tabella `constructors`
--
ALTER TABLE `constructors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT per la tabella `drivers`
--
ALTER TABLE `drivers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT per la tabella `news`
--
ALTER TABLE `news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT per la tabella `races`
--
ALTER TABLE `races`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT per la tabella `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`news_id`) REFERENCES `news` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
