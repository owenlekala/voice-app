const twilio = require('twilio');

/**
 * Middleware to validate that requests are coming from Twilio
 * This helps prevent unauthorized access to your webhook endpoints
 */
const validateRequest = (req, res, next) => {
  // Skip validation in development mode if configured
  if (process.env.NODE_ENV === 'development' && process.env.SKIP_TWILIO_VALIDATION === 'true') {
    return next();
  }

  const twilioSignature = req.headers['x-twilio-signature'];
  const url = `${process.env.BASE_URL}${req.originalUrl}`;
  const params = req.body;

  // Validate the request using Twilio's validateRequest function
  const isValid = twilio.validateRequest(
    process.env.TWILIO_AUTH_TOKEN,
    twilioSignature,
    url,
    params
  );

  if (isValid) {
    return next();
  } else {
    console.error('Invalid Twilio request signature');
    return res.status(403).send('Forbidden: Invalid Twilio signature');
  }
};

module.exports = { validateRequest };