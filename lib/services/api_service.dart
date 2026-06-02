import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _envApiUrl =
      String.fromEnvironment('API_URL', defaultValue: '');

  static const String _defaultUrl =
      'https://uangjajantrackerproduction.up.railway.app/api/v1';

  static String get baseUrl {
    return _envApiUrl.isNotEmpty ? _envApiUrl : _defaultUrl;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('auth_user');
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> saveSession(
      String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_user', jsonEncode(user));
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        await saveSession(
            data['token'] as String, data['user'] as Map<String, dynamic>);
        return body;
      }

      throw Exception(_parseErrorMessage(body, fallback: 'Login gagal'));
    } on SocketException {
      throw Exception(
          'Tidak dapat terhubung ke server. Pastikan backend API berjalan atau set API_URL dengan alamat yang benar.');
    } on http.ClientException {
      throw Exception(
          'Tidak dapat terhubung ke server. Pastikan backend API berjalan atau set API_URL dengan alamat yang benar.');
    } on FormatException {
      throw Exception('Respon server tidak valid. Cek konfigurasi backend/API_URL.');
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {'name': name.trim(), 'email': email.trim(), 'password': password},
        ),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 201 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        await saveSession(
            data['token'] as String, data['user'] as Map<String, dynamic>);
        return body;
      }

      throw Exception(_parseErrorMessage(body, fallback: 'Registrasi gagal'));
    } on SocketException {
      throw Exception(
          'Tidak dapat terhubung ke server. Pastikan backend API berjalan atau set API_URL dengan alamat yang benar.');
    } on http.ClientException {
      throw Exception(
          'Tidak dapat terhubung ke server. Pastikan backend API berjalan atau set API_URL dengan alamat yang benar.');
    } on FormatException {
      throw Exception('Respon server tidak valid. Cek konfigurasi backend/API_URL.');
    }
  }

  static String _parseErrorMessage(Map<String, dynamic> body,
      {String fallback = 'Terjadi kesalahan'}) {
    if (body['message'] is String && (body['message'] as String).isNotEmpty) {
      return body['message'] as String;
    }

    if (body['errors'] is List) {
      final errors = (body['errors'] as List)
          .map((e) {
            if (e is Map<String, dynamic>) {
              return e['msg']?.toString() ?? e.toString();
            }
            return e.toString();
          })
          .where((msg) => msg.isNotEmpty)
          .toList();
      if (errors.isNotEmpty) return errors.join(', ');
    }

    return fallback;
  }

  static Future<Map<String, dynamic>> getSummary(
      {String month = '', String year = ''}) async {
    final token = await getToken();
    final uri =
        Uri.parse('$baseUrl/transactions/summary').replace(queryParameters: {
      if (month.isNotEmpty) 'month': month,
      if (year.isNotEmpty) 'year': year,
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      return body;
    }

    throw Exception(body['message'] ?? 'Gagal memuat ringkasan');
  }

  static Future<Map<String, dynamic>> createTransaction({
    required String type,
    required double amount,
    required String title,
    String? categoryId,
    String? note,
    required String date,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'type': type,
        'amount': amount,
        'title': title,
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,
        if (note != null && note.isNotEmpty) 'note': note,
        'date': date,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201 && body['success'] == true) {
      return body;
    }

    throw Exception(body['message'] ?? 'Gagal menambah transaksi');
  }
}
