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

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

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
              if (key == 'access' ||
                  key == 'access_token' ||
                  key == 'token' ||
                  key.contains('access')) {
                accessToken = v?.toString();
              }
            }
            if (refreshToken == null) {
              if (key == 'refresh' ||
                  key == 'refresh_token' ||
                  key.contains('refresh')) {
                refreshToken = v?.toString();
              }
            }
          });
        }

        if (data is Map) {
          extractFromMap(data.cast<String, dynamic>());

          // common case: tokens inside a `data` key
          if ((accessToken == null || refreshToken == null) &&
              data['data'] is Map) {
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
          debugPrint(
            '[AuthService] Tokens não encontrados na resposta de login.',
          );
          debugPrint('[AuthService] Body recebido: ${response.body}');
          return false;
        }
      } catch (e, st) {
        debugPrint(
          '[AuthService] Erro ao parsear JSON da resposta de login: $e',
        );
        debugPrint(st.toString());
        debugPrint('[AuthService] Body recebido: ${response.body}');
        return false;
      }
    }

    return false;
  }

  Future<String> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final body = <String, dynamic>{
      'username': username.trim(),
      'email': email.trim(),
      'password': password,
    };
    return _postMessage(ApiConstants.register, body, 201);
  }

  Future<String> forgotPassword(String email) async {
    return _postMessage(ApiConstants.forgotPassword, {
      'email': email.trim(),
    }, 200);
  }

  Future<String> resetPassword({
    required String token,
    required String password,
  }) async {
    return _postMessage(ApiConstants.resetPassword, {
      'token': token.trim(),
      'password': password,
    }, 200);
  }

  Future<String> _postMessage(
    String endpoint,
    Map<String, dynamic> body,
    int expectedStatus,
  ) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final decoded = _decodeResponse(response.body);
    if (response.statusCode != expectedStatus) {
      throw Exception(_responseMessage(decoded, response.statusCode));
    }
    if (decoded is Map && decoded['mensagem'] != null) {
      return decoded['mensagem'].toString();
    }
    if (decoded is Map && decoded['message'] != null) {
      return decoded['message'].toString();
    }
    return response.body.trim().isEmpty
        ? 'Operação realizada com sucesso.'
        : response.body.trim();
  }

  dynamic _decodeResponse(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body.trim();
    }
  }

  String _responseMessage(dynamic decoded, int statusCode) {
    if (decoded is Map) {
      final message =
          decoded['mensagem'] ?? decoded['message'] ?? decoded['detail'];
      if (message != null) return message.toString();
      return decoded.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(' | ');
    }
    if (decoded is String && decoded.isNotEmpty) return decoded;
    return 'Não foi possível concluir a operação ($statusCode).';
  }
  // 2. Recuperar tokens Salvos no Storage

  Future<String?> getAcessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getValidAccessToken() async {
    final token = await getAcessToken();
    if (token == null || token.isEmpty) return null;
    if (!_tokenExpirou(token)) return token;
    return refreshAccessToken();
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
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final auth = AuthResponse.fromJson(
        data is Map<String, dynamic> ? data : <String, dynamic>{},
      );

      if (auth.accessToken.isEmpty) {
        await logout();
        return null;
      }

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

  Future<bool> isAuthenticated() async {
    return await getValidAccessToken() != null;
  }

  bool _tokenExpirou(String token) {
    final partes = token.split('.');
    if (partes.length != 3) return false;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(partes[1]))),
      );
      final exp = payload is Map ? payload['exp'] : null;
      return exp is num && exp <= DateTime.now().millisecondsSinceEpoch / 1000;
    } catch (_) {
      return false;
    }
  }
}

/*
Future<bool> uploadImage(File imageFile, String token) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('http://192.168.x.x:8000/api/upload/'),
  );

  request.headers['Authorization'] = 'Bearer $token';
  request.files.add(
    await http.MultipartFile.fromPath('foto', imageFile.path),
  );

  final response = await request.send();
  return response.statusCode == 201 || response.statusCode == 200;
}
*/
