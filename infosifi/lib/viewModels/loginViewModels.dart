import 'package:flutter/foundation.dart';
import '../services/authService.dart';
class LoginViewModel extends ChangeNotifier {
  final Authservice _authService;

  LoginViewModel({Authservice? authService})
      : _authService = authService ?? Authservice();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final success = await _authService.login(username.trim(), password);

      if (success) {
        _isSuccess = true;
        return true;
      } else {
        _errorMessage = 'Usuário ou senha inválidos';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao conectar ao servidor. Verifique a rede.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}