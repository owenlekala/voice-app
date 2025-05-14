# Twilio Voice API Integration - Setup Guide

## 1. Twilio Account Setup

### Creating a Twilio Account
1. Visit [Twilio's website](https://www.twilio.com/) and sign up for a free account
2. Verify your email address and phone number
3. Complete the account verification process

### Obtaining Credentials
1. After logging in, navigate to the [Twilio Console](https://console.twilio.com/)
2. Find your **Account SID** and **Auth Token** on the dashboard
   - These credentials will be used to authenticate your application with Twilio's API
   - Keep these credentials secure and never commit them to version control

### Purchasing a Twilio Phone Number
1. In the Twilio Console, navigate to "Phone Numbers" > "Manage" > "Buy a Number"
2. Search for a phone number with voice capabilities
   - Ensure the number has "Voice" capability checked
3. Purchase the number (free trial accounts include credit for this)
4. After purchasing, you'll be able to configure the number's settings

## 2. Environment Configuration

### Backend Configuration
1. Navigate to the backend directory of your project
   ```bash
   cd /Users/user/Work/twilio/backend
   ```

2. Create a `.env` file based on the provided `.env.example`
   ```bash
   cp .env.example .env
   ```

3. Edit the `.env` file with your Twilio credentials and configuration
   ```
   # Twilio Configuration
   TWILIO_ACCOUNT_SID=your_account_sid_here
   TWILIO_AUTH_TOKEN=your_auth_token_here
   TWILIO_PHONE_NUMBER=your_twilio_phone_number_here

   # Application Configuration
   PORT=3000
   BASE_URL=https://your-ngrok-url.ngrok.io
   NODE_ENV=development

   # Optional: Skip Twilio validation in development (set to 'true' or 'false')
   SKIP_TWILIO_VALIDATION=false

   # Phone Numbers for Departments
   SALES_PHONE_NUMBER=+15551234567
   SUPPORT_PHONE_NUMBER=+15557654321
   ```

### Setting Up Public URL with ngrok
Twilio requires a publicly accessible URL for webhooks. During development, you can use ngrok:

1. Install ngrok if you haven't already
   ```bash
   brew install ngrok
   ```

2. Start ngrok to create a tunnel to your local server
   ```bash
   ngrok http 3000
   ```

3. Copy the HTTPS URL provided by ngrok (e.g., `https://a1b2c3d4.ngrok.io`)
4. Update the `BASE_URL` in your `.env` file with this URL
5. Configure your Twilio phone number's voice webhook:
   - In the Twilio Console, go to "Phone Numbers" > "Manage" > "Active Numbers"
   - Click on your number and scroll to the "Voice & Fax" section
   - Set the webhook for "A Call Comes In" to: `https://your-ngrok-url.ngrok.io/api/voice/incoming`
   - Set the HTTP method to POST

## 3. Installing Dependencies

### Backend Dependencies
```bash
cd /Users/user/Work/twilio/backend
npm install
```

### Mobile App Dependencies
```bash
cd /Users/user/Work/twilio/mobile
flutter pub get
```

## 4. Running the Application

### Starting the Backend Server
```bash
cd /Users/user/Work/twilio/backend
node server.js
```

### Running the Flutter App
```bash
cd /Users/user/Work/twilio/mobile
flutter run
```

## 5. Testing Your Twilio Integration

### Testing Incoming Calls
1. Ensure your backend server is running
2. Ensure ngrok is running and your Twilio phone number's webhook is configured
3. Call your Twilio phone number from any phone
4. You should hear the welcome message and be able to interact with the IVR menu

### Testing Outgoing Calls
1. Open the Flutter app on your device or emulator
2. Enter a valid phone number in the input field
3. Tap "Make Call"
4. The recipient should receive a call from your Twilio number

### Testing Conference Calls
1. Open the Flutter app
2. Enter a phone number
3. Tap "Join Conference"
4. The recipient will be added to the conference
5. Repeat with additional phone numbers to add more participants

## 6. Security Best Practices

1. **Never commit your .env file** to version control
2. Use environment variables for all sensitive credentials
3. Implement request validation (already set up in the middleware)
4. Use HTTPS for all communications
5. Regularly rotate your Twilio Auth Token
6. Implement proper access controls for your application
7. Sanitize and validate all user inputs

## 7. Troubleshooting

### Common Issues

1. **Webhook errors**:
   - Verify your ngrok tunnel is running
   - Ensure the BASE_URL in .env matches your ngrok URL
   - Check that your Twilio phone number is configured with the correct webhook URL

2. **Authentication errors**:
   - Verify your TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN are correct
   - Ensure you're not using test credentials in production or vice versa

3. **Call failures**:
   - Check your Twilio account balance
   - Verify the phone numbers are in the correct format (E.164: +1XXXXXXXXXX)
   - Review Twilio logs in the console for specific error messages

### Debugging Tools

1. **Twilio Console Debugger**:
   - Navigate to "Runtime" > "Debugger" in the Twilio Console
   - Review logs for detailed error information

2. **Backend Logs**:
   - Check your server console for error messages
   - Enable more verbose logging if needed

3. **TwiML Bin for Testing**:
   - Use Twilio's TwiML Bins to test TwiML responses without your server
   - Helpful for isolating issues between Twilio and your application

## 8. Additional Resources

- [Twilio Voice API Documentation](https://www.twilio.com/docs/voice)
- [TwiML Documentation](https://www.twilio.com/docs/voice/twiml)
- [Twilio Node.js SDK Documentation](https://www.twilio.com/docs/libraries/node)
- [Flutter HTTP Package Documentation](https://pub.dev/packages/http)