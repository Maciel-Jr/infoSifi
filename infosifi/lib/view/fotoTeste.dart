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
          tooltip: '',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            '/dadosDoTeste',
          ),
        ),
      ),
        body: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Fotografe o teste',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF4A148C),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Posicione o teste dentro da área indicada.',
                            textAlign: TextAlign.center,
                          ),

              const SizedBox(height: 20),

              Stack(
                children: [
                  Container(
                    width: 320,
                    height: 180,
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
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Nenhuma foto capturada',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFF6A1B9A),
                            width: 2,
                          ),
                          top: BorderSide(
                            color: Color(0xFF6A1B9A),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(0xFF6A1B9A),
                            width: 2,
                          ),
                          top: BorderSide(
                            color: Color(0xFF6A1B9A),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFF6A1B9A),
                            width: 2,
                          ),
                          bottom: BorderSide(
                            color: Color(0xFF6A1B9A),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(0xFF6A1B9A),
                            width: 2,
                          ),
                          bottom: BorderSide(
                            color: Color(0xFF6A1B9A),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              //const Text(
                //'Mantenha o teste na posição horizontal.',
                //textAlign: TextAlign.center,
                //style: TextStyle(
                  //color: Colors.grey,
                  //fontSize: 14,
                //),
              //),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.purple,
                    size: 22,
                  ),

                  const SizedBox(width: 6),

                  const Text(
                    'Boa iluminação, sem sombra e fundo escuro.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ),
    ),
  ),

              Container(
                width: double.infinity,
                height: 75,
                color: const Color(0xFF4A148C),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: ElevatedButton(
                        onPressed: _takePhoto,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(
                            side: const BorderSide(
                              color: Color(0xFF4A148C),
                              width: 3,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 32,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 24,
                      child: IconButton(
                        onPressed: _pickFromGallery,
                        icon: const Icon(
                          Icons.photo_library,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ),
      ),
    );
  }
}