const express = require('express');
const router = express.Router();
const twilio = require('twilio');
const VoiceResponse = twilio.twiml.VoiceResponse;

// Import middleware for Twilio request validation
const { validateRequest } = require('../middleware/twilioValidation');

/**
 * Handle incoming voice calls
 * This endpoint will be set as the webhook URL in your Twilio phone number configuration
 */
router.post('/incoming', validateRequest, (req, res) => {
  const twiml = new VoiceResponse();
  
  // Create a simple welcome message with options
  twiml.say(
    { voice: 'alice' },
    'Welcome to the Twilio Voice API demo. Press 1 for sales, press 2 for support, or press 3 to leave a message.'
  );

  // Gather the caller's input
  const gather = twiml.gather({
    numDigits: 1,
    action: '/api/voice/menu',
    method: 'POST',
  });

  // If the user doesn't input anything, try again
  twiml.redirect('/api/voice/incoming');

  res.type('text/xml');
  res.send(twiml.toString());
});

/**
 * Handle menu selection from gather
 */
router.post('/menu', validateRequest, (req, res) => {
  const twiml = new VoiceResponse();
  const digit = req.body.Digits;

  switch (digit) {
    case '1':
      // Transfer to sales department
      twiml.say({ voice: 'alice' }, 'Connecting you to our sales department.');
      twiml.dial(process.env.SALES_PHONE_NUMBER || '+15551234567');
      break;
    
    case '2':
      // Transfer to support department
      twiml.say({ voice: 'alice' }, 'Connecting you to our support team.');
      twiml.dial(process.env.SUPPORT_PHONE_NUMBER || '+15557654321');
      break;
    
    case '3':
      // Record a message
      twiml.say({ voice: 'alice' }, 'Please leave a message after the beep. Press pound when finished.');
      twiml.record({
        action: '/api/voice/recording',
        maxLength: 30,
        finishOnKey: '#',
      });
      break;
    
    default:
      // Invalid option
      twiml.say({ voice: 'alice' }, 'Sorry, I didn\'t understand your selection.');
      twiml.redirect('/api/voice/incoming');
      break;
  }

  res.type('text/xml');
  res.send(twiml.toString());
});

/**
 * Handle recording completion
 */
router.post('/recording', validateRequest, (req, res) => {
  const twiml = new VoiceResponse();
  
  // Thank the caller for their message
  twiml.say(
    { voice: 'alice' },
    'Thank you for your message. Our team will get back to you soon. Goodbye!'
  );

  // The recording URL will be available in req.body.RecordingUrl
  console.log(`Recording URL: ${req.body.RecordingUrl}`);
  
  // Here you would typically store the recording URL in your database
  // and potentially trigger a notification to your team

  res.type('text/xml');
  res.send(twiml.toString());
});

/**
 * Initiate an outbound call
 */
router.post('/call', async (req, res) => {
  try {
    const { to, from = process.env.TWILIO_PHONE_NUMBER } = req.body;
    
    if (!to) {
      return res.status(400).json({ error: 'The "to" phone number is required' });
    }

    // Initialize the Twilio client
    const client = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );

    // Make the call
    const call = await client.calls.create({
      to,
      from,
      url: `${process.env.BASE_URL}/api/voice/outbound-call`,
      method: 'POST',
    });

    res.json({ success: true, callSid: call.sid });
  } catch (error) {
    console.error('Error making outbound call:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * Handle TwiML for outbound calls
 */
router.post('/outbound-call', validateRequest, (req, res) => {
  const twiml = new VoiceResponse();
  
  twiml.say(
    { voice: 'alice' },
    'This is an automated call from our Twilio Voice API demo. Thank you for answering!'
  );

  res.type('text/xml');
  res.send(twiml.toString());
});

/**
 * Set up a conference call
 */
router.post('/conference', validateRequest, (req, res) => {
  const twiml = new VoiceResponse();
  
  // Greet the caller
  twiml.say(
    { voice: 'alice' },
    'You are joining the conference. Please wait for others to join.'
  );

  // Add the caller to the conference
  const dial = twiml.dial();
  dial.conference('MyConference', {
    startConferenceOnEnter: true,
    endConferenceOnExit: false,
    waitUrl: 'https://twimlets.com/holdmusic?Bucket=com.twilio.music.classical',
    waitMethod: 'GET',
  });

  res.type('text/xml');
  res.send(twiml.toString());
});

module.exports = router;