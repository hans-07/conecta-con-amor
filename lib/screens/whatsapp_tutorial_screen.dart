import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../services/voice_service.dart';

class WhatsAppTutorialScreen extends StatefulWidget {
  const WhatsAppTutorialScreen({super.key});

  @override
  State<WhatsAppTutorialScreen> createState() => _WhatsAppTutorialScreenState();
}

class _WhatsAppTutorialScreenState extends State<WhatsAppTutorialScreen>
    with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();

  int _currentStep = 0;
  bool _isSimulating = false;
  String _typedMessage = '';
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      'title': '¡Bienvenido al Tutorial de WhatsApp!',
      'description': 'Te enseñaré paso a paso cómo enviar un mensaje por WhatsApp.',
      'instruction': 'Toca "Siguiente" para comenzar',
      'action': 'next',
    },
    {
      'title': 'Paso 1: Abrir WhatsApp',
      'description': 'Primero necesitamos abrir la aplicación de WhatsApp.',
      'instruction': 'Toca el botón verde "Abrir WhatsApp"',
      'action': 'open_whatsapp',
    },
    {
      'title': 'Paso 2: Seleccionar Contacto',
      'description': 'Ahora vamos a elegir a quién enviar el mensaje.',
      'instruction': 'Toca en "María García" para seleccionar el contacto',
      'action': 'select_contact',
    },
    {
      'title': 'Paso 3: Escribir Mensaje',
      'description': 'Ahora vamos a escribir nuestro mensaje.',
      'instruction': 'Escribe cualquier mensaje que quieras enviar',
      'action': 'type_message',
    },
    {
      'title': 'Paso 4: Enviar Mensaje',
      'description': 'Perfecto! Ya tienes tu mensaje escrito.',
      'instruction': 'Ahora toca el botón "ENVIAR" para enviarlo',
      'action': 'send_message',
    },
    {
      'title': 'Paso 5: Mensaje Enviado',
      'description': 'El mensaje se ha enviado exitosamente.',
      'instruction': 'Toca "Finalizar" para completar el tutorial',
      'action': 'finish',
    },
  ];

  final List<Map<String, String>> _contacts = [
    {'name': 'María García', 'status': 'En línea', 'avatar': '👩'},
    {'name': 'Juan Pérez', 'status': 'Hace 5 min', 'avatar': '👨'},
    {'name': 'Ana López', 'status': 'Hace 1 hora', 'avatar': '👵'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _speakCurrentStep();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _speakCurrentStep() async {
    final step = _tutorialSteps[_currentStep];

    // Anuncio completo para TalkBack/accesibilidad
    String announcement = "Tutorial de WhatsApp. ";
    announcement += "Paso ${_currentStep + 1} de ${_tutorialSteps.length}. ";
    announcement += "${step['title']}. ";
    announcement += "${step['description']}. ";
    announcement += "${step['instruction']}";

    // Agregar instrucciones específicas según el paso
    switch (_currentStep) {
      case 0: // Bienvenida
        announcement += ". Toca el botón Comenzar Tutorial para continuar.";
        break;
      case 1: // Abrir WhatsApp
        announcement += ". Busca y toca el botón verde que dice Abrir WhatsApp.";
        break;
      case 2: // Seleccionar contacto
        announcement += ". Toca el botón Seleccionar Contacto para elegir a quién enviar el mensaje.";
        break;
      case 3: // Escribir mensaje
        announcement += ". Toca en el campo de texto y escribe tu mensaje usando el teclado.";
        break;
      case 4: // Enviar mensaje
        announcement += ". Toca el botón Enviar para enviar tu mensaje.";
        break;
      case 5: // Finalización
        announcement += ". Toca Regresar al Inicio para terminar el tutorial.";
        break;
    }

    await _voiceService.speak(announcement);

    // También anunciar usando Semantics para TalkBack nativo
    SemanticsService.announce(announcement, TextDirection.ltr);
  }

  Future<void> _nextStep() async {
    if (_currentStep < _tutorialSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
      
      _slideController.reset();
      _slideController.forward();
      
      await _speakCurrentStep();
    }
  }

  Future<void> _handleStepAction(String action) async {
    await HapticFeedback.lightImpact();
    
    switch (action) {
      case 'next':
        await _nextStep();
        break;
      case 'open_whatsapp':
        setState(() {
          _isSimulating = true;
        });
        await Future.delayed(const Duration(milliseconds: 800));
        await _nextStep();
        break;
      case 'select_contact':
        // No avanzar automáticamente, esperar a que seleccione
        break;
      case 'type_message':
        // Enfocar el campo de texto para que aparezca el teclado
        Future.delayed(const Duration(milliseconds: 500), () {
          _messageFocusNode.requestFocus();
        });
        break;
      case 'send_message':
        final message = _messageController.text.trim();
        if (message.isNotEmpty) {
          setState(() {
            _typedMessage = message;
          });
          _messageFocusNode.unfocus(); // Ocultar el teclado
          await _voiceService.speak("Mensaje enviado exitosamente");
          await Future.delayed(const Duration(milliseconds: 1000));
          await _nextStep();
        } else {
          await _voiceService.speak("Primero debes escribir un mensaje");
        }
        break;
      case 'finish':
        if (mounted) {
          Navigator.of(context).pop();
        }
        break;
    }
  }

  void _selectContact(String contactName) {
    HapticFeedback.selectionClick();

    if (contactName == 'María García') {
      Future.delayed(const Duration(milliseconds: 500), () {
        _nextStep();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final currentStepData = _tutorialSteps[_currentStep];
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Tutorial de WhatsApp',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF25D366),
        elevation: 0,
        leading: Semantics(
          label: 'Regresar',
          hint: 'Toca para salir del tutorial y regresar al menú principal',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Semantics(
            label: 'Repetir instrucciones',
            hint: 'Toca para escuchar nuevamente las instrucciones del paso actual',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.white),
              onPressed: _speakCurrentStep,
              tooltip: 'Repetir instrucciones',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de progreso compacto
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isSmallScreen ? 8 : 12
            ),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paso ${_currentStep + 1} de ${_tutorialSteps.length}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${((_currentStep + 1) / _tutorialSteps.length * 100).round()}%',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF25D366),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _tutorialSteps.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF25D366)),
                ),
              ],
            ),
          ),

          // Contenido principal optimizado
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  children: [
                    // Título y descripción compactos
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentStepData['title'],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF25D366),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Text(
                            currentStepData['description'],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 15,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF25D366),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    currentStepData['instruction'],
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF25D366),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // Simulador de WhatsApp responsivo
                    Expanded(
                      child: _buildWhatsAppSimulator(currentStepData['action']),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppSimulator(String action) {
    switch (action) {
      case 'next':
        return _buildWelcomeScreen();
      case 'open_whatsapp':
        return _buildOpenWhatsAppStep();
      case 'select_contact':
        return _buildContactListScreen();
      case 'type_message':
        return _buildChatScreen();
      case 'send_message':
        return _buildSendMessageStep();
      case 'finish':
        return _buildFinishScreen();
      default:
        return Container();
    }
  }

  Widget _buildWelcomeScreen() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              size: isSmallScreen ? 60 : 70,
              color: const Color(0xFF25D366),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              '💬 Aprende WhatsApp',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              'Te enseñaré cómo enviar\nmensajes paso a paso',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 32),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Semantics(
                    label: 'Comenzar Tutorial de WhatsApp',
                    hint: 'Toca para iniciar el tutorial paso a paso de WhatsApp',
                    button: true,
                    child: ElevatedButton(
                      onPressed: () => _handleStepAction('next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 32 : 40,
                          vertical: isSmallScreen ? 12 : 16
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'Comenzar Tutorial',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenWhatsAppStep() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isSimulating) ...[
              Icon(
                Icons.smartphone,
                size: isSmallScreen ? 60 : 70,
                color: Colors.grey,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'WhatsApp Cerrado',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: isSmallScreen ? 24 : 32),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Semantics(
                      label: 'Abrir WhatsApp',
                      hint: 'Toca para simular abrir la aplicación de WhatsApp',
                      button: true,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleStepAction('open_whatsapp'),
                        icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                        label: Text(
                          'Abrir WhatsApp',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 24 : 30,
                            vertical: isSmallScreen ? 12 : 16
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              Icon(
                Icons.chat,
                size: isSmallScreen ? 60 : 70,
                color: const Color(0xFF25D366),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                '¡WhatsApp Abierto!',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF25D366),
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                'Cargando contactos...',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF25D366)),
                  strokeWidth: 3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactListScreen() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF075E54),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header de WhatsApp compacto
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: const BoxDecoration(
              color: Color(0xFF075E54),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: isSmallScreen ? 20 : 24),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Text(
                  'Seleccionar contacto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.search, color: Colors.white, size: isSmallScreen ? 20 : 24),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Icon(Icons.more_vert, color: Colors.white, size: isSmallScreen ? 20 : 24),
              ],
            ),
          ),

          // Lista de contactos optimizada
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  final isTarget = contact['name'] == 'María García';

                  return AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isTarget ? _pulseAnimation.value : 1.0,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 2 : 4),
                          decoration: BoxDecoration(
                            color: isTarget ? const Color(0xFF25D366).withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isTarget ? Border.all(
                              color: const Color(0xFF25D366),
                              width: 2,
                            ) : null,
                          ),
                          child: Semantics(
                            label: 'Contacto ${contact['name']}',
                            hint: isTarget
                              ? 'Toca para seleccionar este contacto y continuar con el tutorial'
                              : 'Contacto disponible. Para el tutorial, selecciona María García',
                            button: true,
                            child: ListTile(
                              dense: isSmallScreen,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 16,
                                vertical: isSmallScreen ? 4 : 8,
                              ),
                              onTap: () => _selectContact(contact['name']!),
                            leading: CircleAvatar(
                              radius: isSmallScreen ? 18 : 20,
                              backgroundColor: const Color(0xFF25D366),
                              child: Text(
                                contact['avatar']!,
                                style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
                              ),
                            ),
                            title: Text(
                              contact['name']!,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 14 : 16,
                                color: isTarget ? const Color(0xFF25D366) : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              contact['status']!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            trailing: isTarget ? Icon(
                              Icons.arrow_forward_ios,
                              color: const Color(0xFF25D366),
                              size: isSmallScreen ? 14 : 16,
                            ) : null,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatScreen() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del chat compacto
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: const BoxDecoration(
              color: Color(0xFF075E54),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: isSmallScreen ? 20 : 24),
                SizedBox(width: isSmallScreen ? 8 : 12),
                CircleAvatar(
                  radius: isSmallScreen ? 16 : 18,
                  backgroundColor: const Color(0xFF25D366),
                  child: Text('👩', style: TextStyle(fontSize: isSmallScreen ? 16 : 18)),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'María García',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'En línea',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.videocam, color: Colors.white, size: isSmallScreen ? 18 : 20),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Icon(Icons.call, color: Colors.white, size: isSmallScreen ? 18 : 20),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Icon(Icons.more_vert, color: Colors.white, size: isSmallScreen ? 18 : 20),
              ],
            ),
          ),

          // Área de chat compacta
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE5DDD5),
              ),
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              child: Column(
                children: [
                  const Spacer(),
                  // Mensaje de ejemplo
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 6 : 8
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '¡Hola! ¿Cómo has estado?',
                        style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                ],
              ),
            ),
          ),

          // Área de escritura con TextField real
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Campo de texto real
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 4 : 6
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_emotions_outlined,
                             color: Colors.grey,
                             size: isSmallScreen ? 16 : 18),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Expanded(
                          child: Semantics(
                            label: 'Campo de mensaje',
                            hint: 'Escribe aquí tu mensaje para enviar por WhatsApp',
                            textField: true,
                            child: TextField(
                              controller: _messageController,
                              focusNode: _messageFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Escribe tu mensaje aquí...',
                                hintStyle: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.grey[500],
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.black87,
                              ),
                              onChanged: (text) {
                                setState(() {
                                  _typedMessage = text;
                                });
                              },
                              textInputAction: TextInputAction.send,
                              onSubmitted: (text) {
                                if (text.trim().isNotEmpty) {
                                  _handleStepAction('send_message');
                                }
                              },
                            ),
                          ),
                        ),
                        Icon(Icons.attach_file,
                             color: Colors.grey,
                             size: isSmallScreen ? 16 : 18),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Icon(Icons.camera_alt,
                             color: Colors.grey,
                             size: isSmallScreen ? 16 : 18),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                // Botón de enviar
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final hasText = _messageController.text.trim().isNotEmpty;
                    return Transform.scale(
                      scale: hasText ? _pulseAnimation.value : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: hasText ? const Color(0xFF25D366) : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Semantics(
                          label: 'Enviar mensaje',
                          hint: hasText
                            ? 'Toca para enviar el mensaje que escribiste'
                            : 'Escribe un mensaje primero para poder enviarlo',
                          button: true,
                          enabled: hasText,
                          child: IconButton(
                            onPressed: hasText ? () => _handleStepAction('send_message') : null,
                            icon: Icon(
                              Icons.send,
                              color: hasText ? Colors.white : Colors.grey[600],
                              size: isSmallScreen ? 18 : 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSendMessageStep() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                size: isSmallScreen ? 40 : 50,
                color: const Color(0xFF25D366),
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _typedMessage.isEmpty ? 'Tu mensaje aquí' : _typedMessage,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF25D366),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Mensaje listo para enviar',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isSmallScreen ? 32 : 40),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () => _handleStepAction('send_message'),
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      icon: Icon(Icons.send, size: isSmallScreen ? 20 : 24),
                      label: Text(
                        'ENVIAR',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishScreen() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: isSmallScreen ? 50 : 60,
              color: const Color(0xFF25D366),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              '¡Felicitaciones!',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF25D366),
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Has aprendido a enviar\nmensajes por WhatsApp',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 15,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '📱 Ahora puedes:',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF25D366),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Text(
                    '• Abrir WhatsApp\n• Seleccionar contactos\n• Escribir mensajes\n• Enviar mensajes',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            ElevatedButton.icon(
              onPressed: () => _handleStepAction('finish'),
              icon: Icon(Icons.home, color: Colors.white, size: isSmallScreen ? 16 : 18),
              label: Text(
                'Regresar al Inicio',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 24,
                  vertical: isSmallScreen ? 10 : 12
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
