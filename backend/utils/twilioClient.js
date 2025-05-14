/**
 * Utility functions for working with the Twilio client
 */
const twilio = require('twilio');

/**
 * Get an authenticated Twilio client instance
 * @returns {import('twilio').Twilio} Authenticated Twilio client
 */
const getTwilioClient = () => {
  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;
  
  if (!accountSid || !authToken) {
    throw new Error('Twilio credentials not found in environment variables');
  }
  
  return twilio(accountSid, authToken);
};

/**
 * Get call details by SID
 * @param {string} callSid - The SID of the call to retrieve
 * @returns {Promise<import('twilio/lib/rest/api/v2010/account/call').CallInstance>} Call details
 */
const getCallDetails = async (callSid) => {
  const client = getTwilioClient();
  return client.calls(callSid).fetch();
};

/**
 * Get recordings for a specific call
 * @param {string} callSid - The SID of the call
 * @returns {Promise<import('twilio/lib/rest/api/v2010/account/recording').RecordingListInstance>} List of recordings
 */
const getCallRecordings = async (callSid) => {
  const client = getTwilioClient();
  return client.recordings.list({ callSid });
};

/**
 * Get transcription for a recording
 * @param {string} recordingSid - The SID of the recording
 * @returns {Promise<import('twilio/lib/rest/api/v2010/account/recording/transcription').TranscriptionListInstance>} List of transcriptions
 */
const getRecordingTranscriptions = async (recordingSid) => {
  const client = getTwilioClient();
  return client.recordings(recordingSid).transcriptions.list();
};

module.exports = {
  getTwilioClient,
  getCallDetails,
  getCallRecordings,
  getRecordingTranscriptions
};