# F1 App

A Flutter application for Formula 1 fans that displays news, driver and constructor standings, and race schedules.

## Features

- News section with latest F1 news
- Driver standings
- Constructor standings
- Race calendar with upcoming and past races

## Setup Instructions

### Prerequisites

- Flutter SDK
- XAMPP (for PHP and MySQL)
- Android Studio or VS Code

### Backend Setup

1. Start XAMPP and ensure Apache and MySQL services are running
2. Open phpMyAdmin (http://localhost/phpmyadmin)
3. Import the SQL file from `backend/database/f1_db.sql` to create the database and tables
4. Copy the `backend` folder to your XAMPP htdocs directory (usually `C:\xampp\htdocs\f1_api`)

### Flutter App Setup

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Update the API base URL in `lib/services/api_service.dart` if needed
   - For Android emulator: `http://10.0.2.2/f1_api`
   - For physical device: `http://YOUR_COMPUTER_IP/f1_api`
4. Run the app with `flutter run`

## Project Structure

- `lib/models`: Data models for the app
- `lib/screens`: UI screens for different sections
- `lib/services`: API service for backend communication
- `backend/api`: PHP API endpoints
- `backend/config`: Database configuration
- `backend/database`: SQL schema and sample data
