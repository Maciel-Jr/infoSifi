import 'package:flutter/material.dart';
import '../services/authService.dart';

class CadastroAcessoView extends StatefulWidget {
  const CadastroAcessoView({super.key});

  @override
  State<CadastroAcessoView> createState() => _CadastroAcessoViewState();
}

class _CadastroAcessoViewState extends State<CadastroAcessoView> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _authService = Authservice();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final message = await _authService.register(
        username: _username.text,
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      setState(() {
        _success = true;
        _message = message;
      });
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        _success = false;
        _message = exception.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar acesso')),
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
                    const Icon(
                      Icons.person_add_alt_1,
                      size: 64,
                      color: Color(0xFF4B168C),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cadastro de acesso',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use um e-mail válido. Enviaremos um link para verificar seu acesso.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _username,
                      maxLength: 150,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o usuário';
                        }
                        if (!RegExp(r'^[\w.@+\-]+$').hasMatch(value.trim())) {
                          return 'Use apenas letras, números e @ . + - _';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o e-mail';
                        }
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(value.trim())) {
                          return 'Informe um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: _passwordDecoration('Senha'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a senha';
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
                      decoration: _passwordDecoration('Confirmar senha'),
                      validator: (value) => value != _password.text
                          ? 'As senhas não conferem'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    if (_message != null)
                      Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _success ? Colors.green : Colors.red,
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading || _success ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('CRIAR ACESSO'),
                    ),
                    if (_success) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('VOLTAR PARA O LOGIN'),
                      ),
                    ],
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
