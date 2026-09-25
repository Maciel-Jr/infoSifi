import 'package:flutter/material.dart';
import '../services/authService.dart';
import 'redefinir_senha.dart';

class EsqueciSenhaView extends StatefulWidget {
  const EsqueciSenhaView({super.key});

  @override
  State<EsqueciSenhaView> createState() => _EsqueciSenhaViewState();
}

class _EsqueciSenhaViewState extends State<EsqueciSenhaView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _authService = Authservice();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final message = await _authService.forgotPassword(_email.text);
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
      appBar: AppBar(title: const Text('Esqueci minha senha')),
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
                      Icons.mark_email_unread_outlined,
                      size: 64,
                      color: Color(0xFF4B168C),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Recuperar acesso',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Informe seu e-mail para receber as instruções de redefinição.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 20),
                    if (_message != null)
                      Text(_message!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('ENVIAR INSTRUÇÕES'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RedefinirSenhaView(),
                        ),
                      ),
                      child: const Text('Já tenho um token'),
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
}
