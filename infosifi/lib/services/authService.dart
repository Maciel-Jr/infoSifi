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


    ////////////////////////////////////////////////
    final Map<String, dynamic> requestPayload = {
      'username': username,
      'password': password,
    };

    final String jsonBody = jsonEncode(requestPayload);

    debugPrint('--- [REQUISIÇÃO LOGIN] ---');
    debugPrint('URL: ${ApiConstants.login}');
    debugPrint('Payload enviado: $jsonBody');
    debugPrint('--------------------------');
    ////////////////////////////////////////////////

    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      final auth = AuthResponse.fromJson(data);

      //Gravar os dois tokens com criptografia local

      await _storage.write(key: _accessTokenKey, value: auth.accessToken);
      await _storage.write(key: _refreshTokenKey, value: auth.refreshToken); 

      return true; 
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