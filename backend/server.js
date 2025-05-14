require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

// Import routes
const voiceRoutes = require('./routes/voice');

// Initialize express app
const app = express();

// Apply middleware
app.use(helmet()); // Security headers
app.use(bodyParser.urlencoded({ extended: false })); // For parsing Twilio webhook requests
app.use(bodyParser.json()); // For parsing JSON requests
app.use(cors()); // Enable CORS
app.use(morgan('combined')); // Logging

// Routes
app.use('/api/voice', voiceRoutes);

// Basic route for testing
app.get('/', (req, res) => {
  res.send('Twilio Voice API Backend is running!');
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});