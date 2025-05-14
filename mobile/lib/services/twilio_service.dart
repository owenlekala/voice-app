import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TwilioService {
  static final TwilioService _instance = TwilioService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Singleton pattern
  factory TwilioService() {
    return _instance;
  }

  TwilioService._internal();

  // Keys for secure storage
  static const String accountSidKey = 'TWILIO_ACCOUNT_SID';
  static const String authTokenKey = 'TWILIO_AUTH_TOKEN';
  static const String phoneNumberKey = 'TWILIO_PHONE_NUMBER';

  // Get credentials
  Future<String?> getAccountSid() async {
    return await _storage.read(key: accountSidKey);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: authTokenKey);
  }

  Future<String?> getPhoneNumber() async {
    return await _storage.read(key: phoneNumberKey);
  }

  // Save credentials
  Future<void> saveCredentials({
    required String accountSid,
    required String authToken,
    required String phoneNumber,
  }) async {
    await _storage.write(key: accountSidKey, value: accountSid);
    await _storage.write(key: authTokenKey, value: authToken);
    await _storage.write(key: phoneNumberKey, value: phoneNumber);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accountSid = await getAccountSid();
    final authToken = await getAuthToken();
    return accountSid != null && authToken != null;
  }

  // Clear credentials (logout)
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // Update backend URL with credentials
  Future<bool> updateBackendCredentials(String backendUrl) async {
    try {
      final accountSid = await getAccountSid();
      final authToken = await getAuthToken();
      final phoneNumber = await getPhoneNumber();
      
      if (accountSid == null || authToken == null || phoneNumber == null) {
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$backendUrl/api/config/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'accountSid': accountSid,
          'authToken': authToken,
          'phoneNumber': phoneNumber,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}