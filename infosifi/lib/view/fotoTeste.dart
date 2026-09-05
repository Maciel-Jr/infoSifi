import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Fototeste extends StatefulWidget {
  const Fototeste({super.key});

  @override
  State<Fototeste> createState() => _CameraViewState();
}

class _CameraViewState extends State<Fototeste> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  void _voltarParadadosDoTeste(BuildContext context) {
    // Redireciona e limpa a pilha até a rota desejada
    Navigator.of(context).pushNamedAndRemoveUntil('/dadosDoTeste', (route) => false); 
  } 

  // Função para abrir a câmera nativa
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080, // Reduz dimensões para otimizar envio à API
      maxHeight: 1080,
      imageQuality: 85, // Compressão em % para economizar banda
    );

    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  // (Opcional) Função para escolher da galeria
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Bloqueia o fechamento padrão da tela
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Executa a navegação personalizada quando o usuário aperta <
        _voltarParadadosDoTeste(context);
      },
      
      child: 
    
      Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            '/dadosDoTeste',
          ),
        ),
        title: const Text('Capturar Foto'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Área de exibição da imagem
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Nenhuma foto capturada', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
              const SizedBox(height: 32),

              // Botão para tirar foto
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Tirar Foto com a Câmera'),
                ),
              ),
              const SizedBox(height: 12),

              // Botão alternativo para galeria
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Escolher da Galeria'),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}