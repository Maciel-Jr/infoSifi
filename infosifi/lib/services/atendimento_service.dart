import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../configs/api_constants.dart';
import '../models/atendimento.dart';
import 'authService.dart';

class AtendimentoService {
  AtendimentoService({Authservice? authService})
    : _authService = authService ?? Authservice();

  final Authservice _authService;

  Future<List<Atendimento>> listar() async {
    final response = await _get(ApiConstants.atendimentos);
    final decoded = jsonDecode(response.body);
    final items = decoded is List
        ? decoded
        : decoded is Map && decoded['results'] is List
        ? decoded['results'] as List
        : <dynamic>[];
    return items
        .whereType<Map>()
        .map((item) => Atendimento.fromJson(item.cast<String, dynamic>()))
        .toList();
  }

  Future<Atendimento> buscarPorId(int id) async {
    final response = await _get(ApiConstants.atendimento(id));
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw Exception('A API retornou um atendimento inválido.');
    }
    return Atendimento.fromJson(decoded.cast<String, dynamic>());
  }

  Future<Map<String, dynamic>> dashboard() async {
    final response = await _get(ApiConstants.atendimentosDashboard);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw Exception('A API retornou um dashboard inválido.');
    }
    return decoded.cast<String, dynamic>();
  }

  Future<http.Response> _get(String endpoint) async {
    var token = await _authService.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw SessionExpiredException();
    }
    var response = await http.get(
      Uri.parse(endpoint),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 401) {
      token = await _authService.refreshAccessToken();
      if (token == null) throw SessionExpiredException();
      response = await http.get(
        Uri.parse(endpoint),
        headers: {'Authorization': 'Bearer $token'},
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Não foi possível carregar os atendimentos (${response.statusCode}).',
      );
    }
    return response;
  }

  Future<Atendimento> criar({
    required Atendimento atendimento,
    required File imagem,
  }) async {
    var token = await _authService.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw SessionExpiredException();
    }
    var response = await _enviar(atendimento, imagem, token);

    if (response.statusCode == 401) {
      token = await _authService.refreshAccessToken();
      if (token == null) {
        throw SessionExpiredException();
      }
      response = await _enviar(atendimento, imagem, token);
    }

    final responseBody = await response.stream.bytesToString();
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_mensagemErro(response.statusCode, responseBody));
    }

    final body = jsonDecode(responseBody);
    if (body is! Map<String, dynamic>) {
      throw Exception('A API retornou um atendimento inválido.');
    }
    return Atendimento.fromJson(body);
  }

  Future<http.StreamedResponse> _enviar(
    Atendimento atendimento,
    File imagem,
    String? token,
  ) async {
    if (!await imagem.exists() || await imagem.length() == 0) {
      throw Exception('A imagem selecionada não está disponível para envio.');
    }
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.atendimentosCreate),
    );
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields.addAll({
      'nomePaciente': atendimento.nomePaciente,
      'dataNascimento': _paraApi(atendimento.dataNascimento),
      'whatsapp': atendimento.whatsapp,
      'codigoAtendimento': atendimento.codigoAtendimento,
      'tipoTeste': atendimento.tipoTeste,
      'lote': atendimento.lote,
      'validade': _paraApi(atendimento.validade),
      'dataRealizacao': _paraApi(atendimento.dataRealizacao),
      'profissionalResponsavel': atendimento.profissionalResponsavel,
    });
    request.files.add(
      await http.MultipartFile.fromPath(
        'imagem',
        imagem.path,
        filename: imagem.uri.pathSegments.last,
        contentType: _tipoImagem(imagem.path),
      ),
    );
    return request.send();
  }

  MediaType _tipoImagem(String caminho) {
    final extensao = caminho.split('.').last.toLowerCase();
    if (extensao == 'png') return MediaType('image', 'png');
    if (extensao == 'webp') return MediaType('image', 'webp');
    return MediaType('image', 'jpeg');
  }

  String _paraApi(String data) {
    final partes = data.split('/');
    if (partes.length == 3 && partes[2].length == 4) {
      return '${partes[2]}-${partes[1]}-${partes[0]}';
    }
    return data;
  }

  String _mensagemErro(int statusCode, String responseBody) {
    var detalhe = responseBody.trim();
    if (detalhe.isEmpty) {
      detalhe = 'A API não enviou detalhes.';
    } else {
      try {
        final decoded = jsonDecode(detalhe);
        if (decoded is Map) {
          detalhe =
              decoded['mensagem']?.toString() ??
              decoded.entries
                  .map((entry) => '${entry.key}: ${entry.value}')
                  .join(' | ');
        }
      } catch (_) {
        // Mantém a resposta textual quando ela não é JSON.
      }
    }
    if (statusCode == 403) {
      return 'A API recusou o envio (403 - acesso proibido). Verifique se o usuário tem permissão para criar atendimentos e se o token está válido. Detalhes: $detalhe';
    }
    return 'Não foi possível salvar o atendimento ($statusCode). Detalhes: $detalhe';
  }
}

class SessionExpiredException implements Exception {
  @override
  String toString() => 'Sua sessão expirou. Entre novamente.';
}
