# EZ Train - Flutter Authentication App

A complete Flutter mobile application that implements user authentication with registration and login functionality. This app was developed as part of a Flutter Developer Interview Task.

## Features

- ✅ User Registration with validation
- ✅ User Login with token-based authentication  
- ✅ Persistent login session using SharedPreferences
- ✅ Password visibility toggle
- ✅ Form validation with error messages
- ✅ Loading indicators for API calls
- ✅ Clean Material Design UI
- ✅ Provider state management
- ✅ Logout functionality
- ✅ Automatic session persistence

## API Integration

The app integrates with the provided backend API:

- **Base URL:** `https://ez-train.vercel.app`
- **Endpoints Used:**
  - `POST /auth/register` - User registration
  - `POST /auth/login` - User login  
  - `POST /auth/logout` - User logout
  - `GET /auth/me` - Get current user info

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | UI Framework |
| Dart | Programming Language |
| Provider | State Management |
| Dio | HTTP Client |
| SharedPreferences | Local Storage |

