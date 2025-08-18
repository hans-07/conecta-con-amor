import 'package:flutter/material.dart';
import '../services/voice_service.dart';
import '../widgets/big_button.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final VoiceService _voiceService = VoiceService();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _voiceService.speak("Pantalla de ayuda. Aquí puedes aprender a usar la aplicación.");
    });
  }

  void _startCallTutorial() {
    _voiceService.speak("Tutorial de llamadas. Toca el botón verde de llamar en la pantalla principal para abrir el marcador telefónico.");
    Navigator.pop(context);
  }

  void _startWhatsAppTutorial() {
    _voiceService.speak("Tutorial de WhatsApp. Toca el botón verde de WhatsApp para abrir la aplicación de mensajería.");
    Navigator.pop(context);
  }

  void _startContactsTutorial() {
    _voiceService.speak("Tutorial de contactos. Toca el botón azul de contactos para ver tus contactos favoritos.");
    Navigator.pop(context);
  }

  void _startPhotosTutorial() {
    _voiceService.speak("Tutorial de fotos. Toca el botón morado de fotos para abrir la galería de imágenes.");
    Navigator.pop(context);
  }

  void _startEmergencyTutorial() {
    _voiceService.speak("Tutorial de emergencia. Toca el botón rojo de emergencia para enviar un mensaje de ayuda a tus contactos de emergencia.");
    Navigator.pop(context);
  }

  void _showGeneralHelp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Ayuda General',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cómo usar Conecta con Amor:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  '• Toca cualquier botón para escuchar instrucciones\n'
                  '• Los botones vibran cuando los tocas\n'
                  '• La aplicación habla en español\n'
                  '• Todos los botones son grandes y fáciles de tocar\n'
                  '• No necesitas dar permisos especiales',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                Text(
                  'Botones principales:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '🟢 Llamar: Abre el marcador\n'
                  '🟢 WhatsApp: Abre mensajería\n'
                  '🔵 Contactos: Tus contactos favoritos\n'
                  '🟣 Fotos: Galería de imágenes\n'
                  '🔴 Emergencia: Envía mensaje de ayuda\n'
                  '🟠 Ayuda: Esta pantalla',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Entendido',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _voiceService.speak("Ayuda cerrada");
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Ayuda y Tutoriales',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Selecciona un tutorial:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  BigButton(
                    icon: Icons.phone,
                    color: Colors.green,
                    label: "Cómo Llamar",
                    onTap: _startCallTutorial,
                  ),
                  BigButton(
                    icon: Icons.chat,
                    color: const Color(0xFF25D366),
                    label: "Cómo usar WhatsApp",
                    onTap: _startWhatsAppTutorial,
                  ),
                  BigButton(
                    icon: Icons.contacts,
                    color: Colors.blue,
                    label: "Cómo ver Contactos",
                    onTap: _startContactsTutorial,
                  ),
                  BigButton(
                    icon: Icons.photo_library,
                    color: Colors.purple,
                    label: "Cómo ver Fotos",
                    onTap: _startPhotosTutorial,
                  ),
                  BigButton(
                    icon: Icons.emergency,
                    color: Colors.red,
                    label: "Cómo usar Emergencia",
                    onTap: _startEmergencyTutorial,
                  ),
                  BigButton(
                    icon: Icons.info,
                    color: Colors.teal,
                    label: "Ayuda General",
                    onTap: _showGeneralHelp,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.blue,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Consejo: Toca cualquier botón para escuchar las instrucciones por voz',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
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
