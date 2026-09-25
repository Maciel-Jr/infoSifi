import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../viewModels/novoTesteViewModels.dart';
import 'analiseTeste.dart';

class Fototeste extends StatefulWidget {
  const Fototeste({super.key, required this.viewModel});
  final NovoTesteViewModel viewModel;

  @override
  State<Fototeste> createState() => _FototesteState();
}

class _FototesteState extends State<Fototeste> {
  final _picker = ImagePicker();
  File? _imagem;

  Future<void> _capturar(ImageSource source) async {
    final foto = await _picker.pickImage(source: source, maxWidth: 1080, maxHeight: 1080, imageQuality: 85);
    if (foto == null) return;
    setState(() => _imagem = File(foto.path));
    widget.viewModel.definirImagem(File(foto.path));
  }

  void _enviar() {
    if (_imagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capture ou selecione uma foto.')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AnaliseTeste(viewModel: widget.viewModel)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => Navigator.pop(context))),
      body: Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Fotografe o teste', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF4A148C), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Posicione o teste dentro da área indicada.', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(height: 280, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF6A1B9A), width: 2)), child: _imagem == null ? const Icon(Icons.camera_alt_outlined, size: 72, color: Colors.grey) : ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(_imagem!, fit: BoxFit.cover))),
          const SizedBox(height: 16),
          const Text('Boa iluminação, sem sombra e fundo escuro.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6A1B9A))),
          const SizedBox(height: 20),
          OutlinedButton.icon(onPressed: () => _capturar(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('Escolher da galeria')),
        ])),
        Container(width: double.infinity, color: const Color(0xFF4A148C), padding: const EdgeInsets.all(14), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FloatingActionButton(onPressed: () => _capturar(ImageSource.camera), child: const Icon(Icons.camera_alt)),
          const SizedBox(width: 20),
          ElevatedButton(onPressed: _enviar, child: const Text('ENVIAR PARA ANÁLISE')),
        ])),
      ]),
    );
  }
}
