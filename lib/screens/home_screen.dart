import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:image_picker/image_picker.dart';
import '../services/voice_service.dart';
import '../services/emergency_service.dart';
import 'help_screen.dart';
import 'call_tutorial_screen.dart';
import 'whatsapp_tutorial_screen.dart';
import 'contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoiceService _voiceService = VoiceService();
  final EmergencyService _emergencyService = EmergencyService();
  final ImagePicker _imagePicker = ImagePicker();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    // Saludo inicial
    Future.delayed(const Duration(seconds: 1), () {
      _voiceService.speak("Bienvenido a Conecta con Amor. Toca cualquier botón para comenzar.");
    });
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  // Función para hacer llamadas telefónicas
  Future<void> _launchDialer() async {
    try {
      await _voiceService.speak("Abriendo el marcador telefónico");
      await _vibrate();

      const phoneUrl = 'tel:';
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        _showErrorDialog('No se puede abrir el marcador telefónico');
      }
    } catch (e) {
      _showErrorDialog('Error al abrir el marcador: $e');
    }
  }

  Future<void> _openCallTutorial() async {
    await _voiceService.speak("Abriendo tutorial de llamadas");
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CallTutorialScreen(),
        ),
      );
    }
  }



  // Función para abrir WhatsApp
  Future<void> _openWhatsApp() async {
    try {
      await _voiceService.speak("Abriendo WhatsApp");
      await _vibrate();
      
      const whatsappUrl = 'whatsapp://send';
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        _showWhatsAppNotInstalledDialog();
      }
    } catch (e) {
      _showErrorDialog('Error al abrir WhatsApp: $e');
    }
  }

  // Función para mostrar contactos
  void _showContacts() async {
    await _voiceService.speak("Abriendo contactos");
    await _vibrate();

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ContactsScreen()),
      );
    }
  }

  // Función para abrir galería de fotos
  Future<void> _pickImage() async {
    try {
      await _voiceService.speak("Abriendo galería de fotos");
      await _vibrate();
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        await _voiceService.speak("Foto seleccionada correctamente");
        // Aquí podrías agregar lógica para mostrar la imagen seleccionada
      }
    } catch (e) {
      _showErrorDialog('Error al abrir la galería: $e');
    }
  }

  // Función de emergencia
  Future<void> _sendEmergencySMS() async {
    try {
      await _voiceService.speak("Enviando mensaje de emergencia");
      await _vibrate();
      
      final result = await _emergencyService.sendEmergencySMS();
      if (result) {
        await _voiceService.speak("Mensaje de emergencia enviado");
        _showSuccessDialog('Mensaje de emergencia enviado correctamente');
      } else {
        _showErrorDialog('No se pudo enviar el mensaje de emergencia');
      }
    } catch (e) {
      _showErrorDialog('Error en emergencia: $e');
    }
  }

  // Función para mostrar ayuda
  void _showHelp() async {
    await _voiceService.speak("Opciones de ayuda");
    await _vibrate();

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Tutoriales y Ayuda'),
            content: const Text('¿Qué tutorial te gustaría ver?'),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openCallTutorial();
                },
                icon: const Icon(Icons.phone, color: Color(0xFF4CAF50)),
                label: const Text(
                  'Tutorial de Llamadas',
                  style: TextStyle(color: Color(0xFF4CAF50)),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openWhatsAppTutorial();
                },
                icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                label: const Text(
                  'Tutorial de WhatsApp',
                  style: TextStyle(color: Color(0xFF25D366)),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openHelpScreen();
                },
                icon: const Icon(Icons.help, color: Colors.orange),
                label: const Text(
                  'Ayuda General',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _openWhatsAppTutorial() async {
    await _voiceService.speak("Abriendo tutorial de WhatsApp");
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WhatsAppTutorialScreen(),
        ),
      );
    }
  }

  Future<void> _openHelpScreen() async {
    await _voiceService.speak("Abriendo ayuda general");
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HelpScreen()),
      );
    }
  }

  // Función para vibración
  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  // Diálogos de error y éxito
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error', style: TextStyle(fontSize: 24)),
          content: Text(message, style: const TextStyle(fontSize: 20)),
          actions: [
            TextButton(
              child: const Text('Entendido', style: TextStyle(fontSize: 18)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Éxito', style: TextStyle(fontSize: 24)),
          content: Text(message, style: const TextStyle(fontSize: 20)),
          actions: [
            TextButton(
              child: const Text('Perfecto', style: TextStyle(fontSize: 18)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showWhatsAppNotInstalledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WhatsApp no está instalado', style: TextStyle(fontSize: 24)),
          content: const Text(
            'Pídele a un familiar que instale WhatsApp por ti.',
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              child: const Text('Entendido', style: TextStyle(fontSize: 18)),
              onPressed: () => Navigator.of(context).pop(),
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
      body: Column(
        children: [
          // Header verde con título
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Conecta con Amor',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu comunicación simplificada',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.0,
                children: [
                  _buildMainButton(
                    icon: Icons.phone,
                    label: 'Llamar',
                    color: const Color(0xFF4CAF50),
                    onTap: _launchDialer,
                  ),
                  _buildMainButton(
                    icon: Icons.chat_bubble,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: _openWhatsApp,
                  ),
                  _buildMainButton(
                    icon: Icons.contacts,
                    label: 'Contactos',
                    color: const Color(0xFF2196F3),
                    onTap: _showContacts,
                  ),
                  _buildMainButton(
                    icon: Icons.photo_library,
                    label: 'Fotos',
                    color: const Color(0xFF9C27B0),
                    onTap: _pickImage,
                  ),
                  _buildMainButton(
                    icon: Icons.apps,
                    label: 'Más Apps',
                    color: const Color(0xFFFF9800),
                    onTap: _showMoreApps,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(Icons.home, 'Inicio', _currentIndex == 0, 0),
            _buildBottomNavItem(Icons.contacts, 'Contactos', _currentIndex == 1, 1),
            _buildBottomNavItem(Icons.photo_library, 'Fotos', _currentIndex == 2, 2),
            _buildBottomNavItem(Icons.help, 'Ayuda', _currentIndex == 3, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: label,
      hint: 'Toca para acceder a $label',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, int index) {
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? const Color(0xFF4CAF50) : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF4CAF50) : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) async {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Ya estamos en inicio, no hacer nada
        break;
      case 1:
        _showContacts();
        // Regresar a inicio después de la acción
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _currentIndex = 0;
            });
          }
        });
        break;
      case 2:
        _pickImage();
        // Regresar a inicio después de la acción
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _currentIndex = 0;
            });
          }
        });
        break;
      case 3:
        _showHelp();
        // Regresar a inicio después de la acción
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _currentIndex = 0;
            });
          }
        });
        break;
    }
  }

  Future<void> _showMoreApps() async {
    await _voiceService.speak("Mostrando más aplicaciones disponibles");
    await _vibrate();

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.apps,
                        size: 28,
                        color: const Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Más Aplicaciones',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                ),

                // Apps grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.8,
                      children: [
                        _buildAppItem(
                          icon: Icons.camera_alt,
                          label: 'Cámara',
                          color: const Color(0xFF4CAF50),
                          packageName: 'com.android.camera2',
                        ),
                        _buildAppItem(
                          icon: Icons.music_note,
                          label: 'Música',
                          color: const Color(0xFFE91E63),
                          packageName: 'com.google.android.music',
                        ),
                        _buildAppItem(
                          icon: Icons.map,
                          label: 'Mapas',
                          color: const Color(0xFF2196F3),
                          packageName: 'com.google.android.apps.maps',
                        ),
                        _buildAppItem(
                          icon: Icons.email,
                          label: 'Gmail',
                          color: const Color(0xFFD32F2F),
                          packageName: 'com.google.android.gm',
                        ),
                        _buildAppItem(
                          icon: Icons.web,
                          label: 'Chrome',
                          color: const Color(0xFF4285F4),
                          packageName: 'com.android.chrome',
                        ),
                        _buildAppItem(
                          icon: Icons.video_library,
                          label: 'YouTube',
                          color: const Color(0xFFFF0000),
                          packageName: 'com.google.android.youtube',
                        ),
                        _buildAppItem(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          color: const Color(0xFF1877F2),
                          packageName: 'com.facebook.katana',
                        ),
                        _buildAppItem(
                          icon: Icons.shopping_cart,
                          label: 'Play Store',
                          color: const Color(0xFF34A853),
                          packageName: 'com.android.vending',
                        ),
                        _buildAppItem(
                          icon: Icons.settings,
                          label: 'Configuración',
                          color: const Color(0xFF757575),
                          packageName: 'com.android.settings',
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Toca cualquier aplicación para abrirla',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildAppItem({
    required IconData icon,
    required String label,
    required Color color,
    required String packageName,
  }) {
    return Semantics(
      label: 'Aplicación $label',
      hint: 'Toca para abrir $label',
      button: true,
      child: GestureDetector(
        onTap: () => _launchApp(packageName, label),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchApp(String packageName, String appName) async {
    try {
      await _voiceService.speak("Abriendo $appName");
      await _vibrate();

      // Cerrar el modal primero
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Intentar abrir la aplicación
      final uri = Uri.parse('android-app://$packageName');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Si no se puede abrir directamente, intentar con el Play Store
        final playStoreUri = Uri.parse('market://details?id=$packageName');
        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri);
          await _voiceService.speak("Abriendo $appName en Play Store para instalar");
        } else {
          // Fallback a navegador web
          final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
          if (await canLaunchUrl(webUri)) {
            await launchUrl(webUri);
            await _voiceService.speak("Abriendo $appName en el navegador");
          } else {
            throw Exception('No se puede abrir la aplicación');
          }
        }
      }
    } catch (e) {
      await _voiceService.speak("No se pudo abrir $appName");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir $appName'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
