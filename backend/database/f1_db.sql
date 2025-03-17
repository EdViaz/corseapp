-- F1 Database Schema

-- Create database
CREATE DATABASE IF NOT EXISTS f1_db;
USE f1_db;

-- Create tables
CREATE TABLE IF NOT EXISTS drivers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  team VARCHAR(100) NOT NULL,
  points INT NOT NULL DEFAULT 0,
  image_url VARCHAR(255),
  position INT NOT NULL
);

CREATE TABLE IF NOT EXISTS constructors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  points INT NOT NULL DEFAULT 0,
  logo_url VARCHAR(255),
  position INT NOT NULL
);

CREATE TABLE IF NOT EXISTS races (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  circuit VARCHAR(100) NOT NULL,
  date DATE NOT NULL,
  country VARCHAR(100) NOT NULL,
  flag_url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS news (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  image_url VARCHAR(255),
  publish_date DATETIME NOT NULL
);

-- Insert sample data
-- Drivers
INSERT INTO drivers (name, team, points, image_url, position) VALUES
('Max Verstappen', 'Red Bull Racing', 400, 'https://example.com/verstappen.jpg', 1),
('Lewis Hamilton', 'Mercedes', 350, 'https://example.com/hamilton.jpg', 2),
('Charles Leclerc', 'Ferrari', 300, 'https://example.com/leclerc.jpg', 3),
('Lando Norris', 'McLaren', 250, 'https://example.com/norris.jpg', 4),
('Carlos Sainz', 'Ferrari', 240, 'https://example.com/sainz.jpg', 5);

-- Constructors
INSERT INTO constructors (name, points, logo_url, position) VALUES
('Red Bull Racing', 600, 'https://example.com/redbull.jpg', 1),
('Ferrari', 540, 'https://example.com/ferrari.jpg', 2),
('Mercedes', 500, 'https://example.com/mercedes.jpg', 3),
('McLaren', 400, 'https://example.com/mclaren.jpg', 4),
('Aston Martin', 250, 'https://example.com/astonmartin.jpg', 5);

-- Races
INSERT INTO races (name, circuit, date, country, flag_url) VALUES
('Bahrain Grand Prix', 'Bahrain International Circuit', '2023-03-05', 'Bahrain', 'https://example.com/bahrain.jpg'),
('Saudi Arabian Grand Prix', 'Jeddah Corniche Circuit', '2023-03-19', 'Saudi Arabia', 'https://example.com/saudi.jpg'),
('Australian Grand Prix', 'Albert Park Circuit', '2023-04-02', 'Australia', 'https://example.com/australia.jpg'),
('Miami Grand Prix', 'Miami International Autodrome', '2023-05-07', 'United States', 'https://example.com/usa.jpg'),
('Monaco Grand Prix', 'Circuit de Monaco', '2023-05-28', 'Monaco', 'https://example.com/monaco.jpg');

-- News
INSERT INTO news (title, content, image_url, publish_date) VALUES
('Verstappen Wins Championship', 'Max Verstappen has secured his third world championship...', 'https://example.com/news1.jpg', '2023-10-25 14:30:00'),
('Hamilton Signs New Contract', 'Lewis Hamilton has signed a new two-year contract with Mercedes...', 'https://example.com/news2.jpg', '2023-10-20 10:15:00'),
('Ferrari Unveils New Car', 'Ferrari has unveiled their new car for the upcoming season...', 'https://example.com/news3.jpg', '2023-10-15 09:00:00'),
('F1 Announces New Race', 'Formula 1 has announced a new race in Madrid starting from 2026...', 'https://example.com/news4.jpg', '2023-10-10 16:45:00'),
('McLaren Technical Update', 'McLaren has introduced a significant technical update to their car...', 'https://example.com/news5.jpg', '2023-10-05 11:30:00');