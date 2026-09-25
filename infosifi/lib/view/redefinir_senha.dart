import 'package:flutter/material.dart';
import '../services/authService.dart';

class RedefinirSenhaView extends StatefulWidget {
  const RedefinirSenhaView({super.key});

  @override
  State<RedefinirSenhaView> createState() => _RedefinirSenhaViewState();
}

class _RedefinirSenhaViewState extends State<RedefinirSenhaView> {
  final _formKey = GlobalKey<FormState>();
  final _token = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _authService = Authservice();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _message;

  @override
  void dispose() {
    _token.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final message = await _authService.resetPassword(
        token: _token.text,
        password: _password.text,
      );
      if (mounted) setState(() => _message = message);
    } catch (exception) {
      if (mounted) {
        setState(
          () => _message = exception.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redefinir senha')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _token,
                      decoration: const InputDecoration(
                        labelText: 'Token recebido',
                        prefixIcon: Icon(Icons.key_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Informe o token'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: _passwordDecoration('Nova senha'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a nova senha';
                        }
                        if (value.length < 8) {
                          return 'A senha deve ter pelo menos 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPassword,
                      obscureText: _obscurePassword,
                      decoration: _passwordDecoration('Confirmar nova senha'),
                      validator: (value) => value != _password.text
                          ? 'As senhas não conferem'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    if (_message != null)
                      Text(_message!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('ALTERAR SENHA'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _passwordDecoration(String label) => InputDecoration(
    labelText: label,
    prefixIcon: const Icon(Icons.lock_outline),
    border: const OutlineInputBorder(),
    suffixIcon: IconButton(
      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
    ),
  );
}
