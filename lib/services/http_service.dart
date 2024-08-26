import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpService {
  static HttpService? _instance;

  // String prodUrl = "https://prod-platform.follocare.com"; // production url is changed
  String _baseUrl = "https://sandbox-be-poc.iiithcanvas.com";
  String currentUrl = '';

  // Private constructor
  HttpService._() {
    currentUrl = _baseUrl;

    _loadToken();
  }

  // Factory constructor for singleton instance
  factory HttpService() {
    if (_instance == null) {
      _instance = HttpService._();
    }
    return _instance!;
  }

  String? _authToken;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = await prefs.getString('authToken');
    print("auth token" + _authToken.toString());
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    _authToken = token;
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    _authToken = null;
  }

  Future<dynamic> get(String endpoint) async {
    return _request(endpoint, method: 'GET');
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(endpoint, method: 'POST', body: body);
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(endpoint, method: 'PUT', body: body);
  }

  Future<dynamic> delete(String endpoint) async {
    return _request(endpoint, method: 'DELETE');
  }

  Future<dynamic> _request(String endpoint, {required String method, Map<String, dynamic>? body}) async {
    await _loadToken();
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true", // Required for cookies, authorization headers with HTTPS
      "Access-Control-Allow-Headers": "Origin,C ontent-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
      "Access-Control-Allow-Methods": "POST, OPTIONS, GET",
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };

    http.Response response;

    // Print request details
    print('Request URL: $url');
    print('Request Method: $method');
    if (body != null) {
      print('Request Body: ${json.encode(body)}');
    }
    print('Request Headers: $headers');

    try {
      switch (method) {
        case 'POST':
          response = await http.post(url, headers: headers, body: json.encode(body));
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: json.encode(body));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        case 'GET':
        default:
          response = await http.get(url, headers: headers);
      }

      // Print response details
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      return _handleResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on FormatException {
      throw BadResponseFormatException('Bad response format');
    } on HttpException {
      throw FetchDataException('Unexpected HTTP error');
    } on Exception {
      throw FetchDataException('Unexpected error occurred');
    }
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(response.body);
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        // Handle token expiration or invalid token scenarios
        _clearToken(); // Clear the token if unauthorized
        throw UnauthorizedException(response.body.toString());
      case 404:
        throw NotFoundException(response.body.toString());
      case 500:
      default:
        throw FetchDataException('Error occurred with status code: ${response.statusCode}');
    }
  }

  // Method to set the auth token (e.g., after login)
  Future<void> setAuthToken(String token) async {
    await _saveToken(token);
  }

  // Method to clear the auth token (e.g., after logout)
  Future<void> clearAuthToken() async {
    await _clearToken();
  }

  Future<dynamic> registerUser(String email, String password, String name) async {
    final endpoint = '/register';
    final body = {
      'email': email,
      'password': password,
      'name': name,
    };
    return post(endpoint, body: body);
  }

  Future<dynamic> requestModelAccess(String modelId) async {
    final endpoint = '/models/access_request';
    final body = {
      'model_id': modelId,
    };
    return post(endpoint, body: body);
  }
}

// Custom Exceptions
class FetchDataException implements Exception {
  final String message;
  FetchDataException(this.message);

  @override
  String toString() => 'FetchDataException: $message';
}

class BadRequestException extends FetchDataException {
  BadRequestException(String message) : super(message);
}

class UnauthorizedException extends FetchDataException {
  UnauthorizedException(String message) : super(message);
}

class NotFoundException extends FetchDataException {
  NotFoundException(String message) : super(message);
}

class BadResponseFormatException extends FetchDataException {
  BadResponseFormatException(String message) : super(message);
}
