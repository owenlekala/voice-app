# Twilio Voice API Integration Project

This project integrates Twilio's Voice API with a Node.js backend and Flutter mobile application.

## Project Structure

```
/twilio
├── backend/               # Node.js backend for Twilio integration
│   ├── config/            # Configuration files
│   ├── controllers/       # Route controllers
│   ├── middleware/        # Express middleware
│   ├── routes/            # API routes
│   ├── services/          # Business logic
│   ├── utils/             # Utility functions
│   ├── .env               # Environment variables (gitignored)
│   ├── .env.example       # Example environment variables
│   ├── package.json       # Node.js dependencies
│   └── server.js          # Entry point
└── mobile/                # Flutter mobile application
    ├── android/           # Android-specific code
    ├── ios/               # iOS-specific code
    ├── lib/               # Flutter application code
    ├── pubspec.yaml       # Flutter dependencies
    └── README.md          # Flutter app documentation
```

## Setup Instructions

### Backend Setup

1. Navigate to the backend directory
2. Install dependencies: `npm install`
3. Copy `.env.example` to `.env` and fill in your Twilio credentials
4. Start the server: `npm start`

### Mobile Setup

1. Navigate to the mobile directory
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`

## Features

- Incoming call handling with TwiML responses
- Call routing and forwarding
- Interactive Voice Response (IVR) menus
- Conference calling
- Call transcription
- Voice recognition
- Flutter mobile interface for call management

## Security Considerations

- Twilio request validation
- Secure credential storage
- Data encryption
- User privacy protection