import 'dart:convert';
import 'package:http/http.dart' as http;
import 'authService.dart';
import '../configs/api_constants.dart';


class ApiService {
  final Authservice _authService = Authservice();

  Future <List<dynamic>> getProtectData() async {
    String? token = await _authService.getAcessToken();

    //primeira tentativa com token atual

    var response = await http.get(
      Uri.parse(ApiConstants.tokenRefresh),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

    );

    if (response.statusCode == 401) {
      token = await _authService.refreshAccessToken();


      if (token != null){
        response = await http.get(
          Uri.parse(ApiConstants.tokenRefresh),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
      else {
        throw Exception('Não foi possível renovar o token de acesso.');
      }

    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar dados: ${response.statusCode}');
    }


  }


}

