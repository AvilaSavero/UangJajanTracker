import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _envApiUrl =
      String.fromEnvironment('API_URL', defaultValue: '');
  
  // Railway remote URL
  static const String _remoteUrl = 'https://uangjajantracker-production.up.railway.app/api/v1'; // Pastikan domain ini sesuai dashboard Railway

  static String get baseUrl {
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl;
    }

    return _remoteUrl;
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
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 500) { // 502 sudah termasuk di >= 500
        throw Exception('Server Railway sedang bermasalah (Error ${response.statusCode}). '
            'Silakan cek logs di Dashboard Railway.');
      }

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        await saveSession(
            data['token'] as String, data['user'] as Map<String, dynamic>);
        return body;
      }

      throw Exception(body['message'] ?? 'Login gagal');
    } on http.ClientException {
      throw Exception(
          'Tidak dapat terhubung ke server. Periksa koneksi internet atau status backend Railway.');
    } on FormatException {
      throw Exception('Respon server tidak valid. Cek backend API.');
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      debugPrint('Mencoba registrasi ke: $baseUrl/auth/register');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint('Status Response: ${response.statusCode}');
      debugPrint('Body Response: ${response.body}');

      if (response.statusCode >= 500) { // 502 sudah termasuk di >= 500
        throw Exception('Server Railway sedang bermasalah (Error ${response.statusCode}). '
            'Silakan cek logs di Dashboard Railway.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 201 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        await saveSession(
            data['token'] as String, data['user'] as Map<String, dynamic>);
        return body;
      }

      throw Exception(body['message'] ?? 'Registrasi gagal');
    } on http.ClientException {
      throw Exception(
          'Tidak dapat terhubung ke server. Periksa koneksi internet atau status backend Railway.');
    } on FormatException {
      throw Exception('Respon server tidak valid. Cek backend API.');
    }
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

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? avatarUrl,
    String? currency,
    String? language,
  }) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (currency != null) 'currency': currency,
        if (language != null) 'language': language,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      final updatedUser = body['data'] as Map<String, dynamic>;
      await prefs.setString('auth_user', jsonEncode(updatedUser));
      return body;
    }

    throw Exception(body['message'] ?? 'Gagal memperbarui profil');
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/auth/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      return body;
    }

    throw Exception(body['message'] ?? 'Gagal mengubah password');
  }

  static Future<Map<String, dynamic>> updateLimit({
    required double monthlyLimit,
    double dailyLimit = 0,
    double alertThreshold = 80,
  }) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/limits'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'monthly_limit': monthlyLimit,
        'daily_limit': dailyLimit,
        'alert_threshold': alertThreshold,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      return body;
    }

    throw Exception(body['message'] ?? 'Gagal memperbarui limit');
  }
}
