import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../services/voice_service.dart';

class CallTutorialScreen extends StatefulWidget {
  const CallTutorialScreen({super.key});

  @override
  State<CallTutorialScreen> createState() => _CallTutorialScreenState();
}

class _CallTutorialScreenState extends State<CallTutorialScreen>
    with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  
  int _currentStep = 0;
  bool _isSimulating = false;
  String _dialedNumber = '';
  bool _isCallActive = false;
  
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      'title': '¡Bienvenido al Tutorial de Llamadas!',
      'description': 'Te enseñaré paso a paso cómo hacer una llamada telefónica.',
      'instruction': 'Toca "Siguiente" para comenzar',
      'action': 'next',
    },
    {
      'title': 'Paso 1: Abrir el Marcador',
      'description': 'Primero necesitamos abrir la aplicación de teléfono.',
      'instruction': 'Toca el botón verde "Abrir Teléfono"',
      'action': 'open_dialer',
    },
    {
      'title': 'Paso 2: Marcar el Número',
      'description': 'Ahora vamos a marcar un número de teléfono.',
      'instruction': 'Toca los números para marcar: 123-456-7890',
      'action': 'dial_number',
    },
    {
      'title': 'Paso 3: Realizar la Llamada',
      'description': 'Con el número marcado, ahora podemos llamar.',
      'instruction': 'Toca el botón verde de llamada',
      'action': 'make_call',
    },
    {
      'title': 'Paso 4: Llamada en Progreso',
      'description': 'La llamada está conectando. Puedes hablar normalmente.',
      'instruction': 'Toca el botón rojo para colgar',
      'action': 'end_call',
    },
    {
      'title': '¡Tutorial Completado!',
      'description': 'Ahora sabes cómo hacer una llamada telefónica.',
      'instruction': 'Toca "Finalizar" para regresar',
      'action': 'finish',
    },
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
    super.dispose();
  }

  Future<void> _speakCurrentStep() async {
    final step = _tutorialSteps[_currentStep];

    // Anuncio completo para TalkBack/accesibilidad
    String announcement = "Tutorial de Llamadas. ";
    announcement += "Paso ${_currentStep + 1} de ${_tutorialSteps.length}. ";
    announcement += "${step['title']}. ";
    announcement += "${step['description']}. ";
    announcement += "${step['instruction']}";

    // Agregar instrucciones específicas según el paso
    switch (_currentStep) {
      case 0: // Bienvenida
        announcement += ". Toca el botón Comenzar Tutorial para continuar.";
        break;
      case 1: // Abrir teléfono
        announcement += ". Toca el botón verde Abrir Teléfono para simular abrir la aplicación.";
        break;
      case 2: // Marcar número
        announcement += ". Usa el teclado de tu teléfono para marcar el número 123-456-7890.";
        break;
      case 3: // Llamada activa
        announcement += ". Toca el botón rojo para colgar la llamada.";
        break;
      case 4: // Finalización
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
      case 'open_dialer':
        setState(() {
          _isSimulating = true;
        });
        await Future.delayed(const Duration(milliseconds: 800));
        await _nextStep();
        break;
      case 'dial_number':
        // No avanzar automáticamente, esperar a que termine de marcar
        break;
      case 'make_call':
        // Verificar que estamos en el paso correcto o que el número está completo
        final cleanNumber = _dialedNumber.replaceAll(RegExp(r'[^\d]'), '');
        if (_currentStep == 2 || cleanNumber == '1234567890') {
          setState(() {
            _isCallActive = true;
          });
          await _voiceService.speak("Realizando llamada");
          await Future.delayed(const Duration(milliseconds: 1000));
          await _nextStep();
        } else {
          // Si no está en el paso correcto, mostrar mensaje
          await _voiceService.speak("Primero debes completar el número 123-456-7890");
        }
        break;
      case 'end_call':
        setState(() {
          _isCallActive = false;
        });
        await _voiceService.speak("Llamada terminada");
        await Future.delayed(const Duration(milliseconds: 500));
        await _nextStep();
        break;
      case 'finish':
        if (mounted) {
          Navigator.of(context).pop();
        }
        break;
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
        title: Text(
          'Tutorial de Llamadas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
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
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _tutorialSteps.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
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
                              color: const Color(0xFF4CAF50),
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
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF4CAF50),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    currentStepData['instruction'],
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4CAF50),
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

                    // Simulador de teléfono responsivo
                    Expanded(
                      child: _buildPhoneSimulator(currentStepData['action']),
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

  Widget _buildPhoneSimulator(String action) {
    switch (action) {
      case 'next':
        return _buildWelcomeScreen();
      case 'open_dialer':
        return _buildOpenDialerStep();
      case 'dial_number':
        return _buildDialerScreen();
      case 'make_call':
        return _buildMakeCallStep();
      case 'end_call':
        return _buildActiveCallScreen();
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
              Icons.phone,
              size: isSmallScreen ? 60 : 70,
              color: const Color(0xFF4CAF50),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              '📞 Aprende a Llamar',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              'Te guiaré paso a paso para\nque aprendas fácilmente',
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
                  child: ElevatedButton(
                    onPressed: () => _handleStepAction('next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenDialerStep() {
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
                'Teléfono Cerrado',
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
                    child: ElevatedButton.icon(
                      onPressed: () => _handleStepAction('open_dialer'),
                      icon: Icon(Icons.phone, color: Colors.white, size: isSmallScreen ? 18 : 20),
                      label: Text(
                        'Abrir Teléfono',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
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
                  );
                },
              ),
            ] else ...[
              Icon(
                Icons.smartphone,
                size: isSmallScreen ? 60 : 70,
                color: const Color(0xFF4CAF50),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                '¡Teléfono Abierto!',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                'Cargando marcador...',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  strokeWidth: 3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDialerScreen() {
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
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          children: [
            // Icono de teléfono
            Icon(
              Icons.phone,
              size: isSmallScreen ? 50 : 60,
              color: const Color(0xFF4CAF50),
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // Instrucciones
            Text(
              'Marca el número:',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
              ),
            ),

            SizedBox(height: isSmallScreen ? 8 : 12),

            // Número objetivo
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '123-456-7890',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                  letterSpacing: 2,
                ),
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 24),

            // Campo de entrada con teclado nativo
            Container(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                autofocus: true,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                decoration: const InputDecoration(
                  hintText: 'Toca aquí y marca el número',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _dialedNumber = value;
                  });
                },
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 24),

            // Mensaje de ayuda
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Usa el teclado de tu teléfono para marcar',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Botón de llamada
            if (_dialedNumber.isNotEmpty && _dialedNumber.replaceAll(RegExp(r'[^\d]'), '') == '1234567890')
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleStepAction('make_call'),
                      icon: Icon(Icons.phone, color: Colors.white, size: isSmallScreen ? 18 : 20),
                      label: Text(
                        'Realizar Llamada',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 30 : 40,
                          vertical: isSmallScreen ? 12 : 16
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 3,
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



  Widget _buildMakeCallStep() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone,
                size: 50,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _dialedNumber.isEmpty ? '123-456-7890' : _dialedNumber,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Número listo para llamar',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 50),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () => _handleStepAction('make_call'),
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.call, size: 28),
                      label: const Text(
                        'LLAMAR',
                        style: TextStyle(
                          fontSize: 20,
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

  Widget _buildActiveCallScreen() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF1B5E20),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
        child: Column(
          children: [
            // Avatar con tamaño adecuado
            Flexible(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: isSmallScreen ? 35 : 45,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: isSmallScreen ? 40 : 50,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),

            // Espaciado flexible
            const Flexible(flex: 1, child: SizedBox()),

            // Número de teléfono
            Text(
              _dialedNumber.isEmpty ? '123-456-7890' : _dialedNumber,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 8),

            // Estado de llamada
            Text(
              'Llamada en progreso...',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            // Timer
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 4 : 6
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '00:15',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),

            // Espaciado flexible
            const Flexible(flex: 2, child: SizedBox()),

            // Botón de colgar con animación
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      onPressed: () => _handleStepAction('end_call'),
                      backgroundColor: Colors.red,
                      elevation: 0,
                      child: Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: isSmallScreen ? 26 : 30,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Texto de instrucción
            Text(
              'Toca para colgar',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
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
        padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: isSmallScreen ? 60 : 70,
              color: const Color(0xFF4CAF50),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              '¡Felicitaciones!',
              style: TextStyle(
                fontSize: isSmallScreen ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              'Has completado el tutorial\nde llamadas exitosamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 32),
            ElevatedButton.icon(
              onPressed: () => _handleStepAction('finish'),
              icon: Icon(Icons.home, color: Colors.white, size: isSmallScreen ? 18 : 20),
              label: Text(
                'Regresar al Inicio',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 30,
                  vertical: isSmallScreen ? 12 : 16
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
