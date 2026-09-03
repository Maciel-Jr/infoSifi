import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:infosifi/models/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../configs/api_constants.dart';

import 'package:flutter/foundation.dart';

class Authservice {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  //chaves para storage

  static const String _refreshTokenKey = 'refreshToken';
  static const String _accessTokenKey = 'accessToken';

  //1. fazer login e salvar tokens no storage

  Future<bool> login (String username, String password) async {
    final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
    );

    // Log básico da requisição/ resposta para debug
    final Map<String, dynamic> requestPayload = {
      'username': username,
      'password': password,
    };

    final String jsonBody = jsonEncode(requestPayload);

 
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        String? accessToken;
        String? refreshToken;

        // helper to try extract tokens from a map (checks common key names and substring matches)
        void extractFromMap(Map map) {
          map.forEach((k, v) {
            final key = k.toString().toLowerCase();
            if (accessToken == null) {
              if (key == 'access' || key == 'access_token' || key == 'token' || key.contains('access')) {
                accessToken = v?.toString();
              }
            }
            if (refreshToken == null) {
              if (key == 'refresh' || key == 'refresh_token' || key.contains('refresh')) {
                refreshToken = v?.toString();
              }
            }
          });
        }

        if (data is Map) {
          extractFromMap(data.cast<String, dynamic>());

          // common case: tokens inside a `data` key
          if ((accessToken == null || refreshToken == null) && data['data'] is Map) {
            extractFromMap((data['data'] as Map).cast<String, dynamic>());
          }

          // try to find nested map containing tokens
          if ((accessToken == null || refreshToken == null)) {
            for (final v in data.values) {
              if (v is Map) {
                extractFromMap(v.cast<String, dynamic>());
                if (accessToken != null && refreshToken != null) break;
              }
            }
          }
        }

        if (accessToken != null && refreshToken != null) {
          // Gravar os dois tokens com criptografia local
          await _storage.write(key: _accessTokenKey, value: accessToken);
          await _storage.write(key: _refreshTokenKey, value: refreshToken);

          return true;
        } else {
          debugPrint('[AuthService] Tokens não encontrados na resposta de login.');
          debugPrint('[AuthService] Body recebido: ${response.body}');
          return false;
        }
      } catch (e, st) {
        debugPrint('[AuthService] Erro ao parsear JSON da resposta de login: $e');
        debugPrint(st.toString());
        debugPrint('[AuthService] Body recebido: ${response.body}');
        return false;
      }
    }

    return false;
  }
  // 2. Recuperar tokens Salvos no Storage

  Future<String?> getAcessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // 3. renovar o access token usando o refresh token salvo no storage

  Future<String?> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);

    if (refreshToken == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse(ApiConstants.refresh),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final auth = AuthResponse.fromJson(data);

      // Atualizar o access token no storage
      await _storage.write(key: _accessTokenKey, value: auth.accessToken);

      return auth.accessToken;
    }

    await logout();
    return null;
  }

  // 4. Logout - Limpar tokens do storage
  Future<void> logout() async {
    await _storage.deleteAll();
  }

}