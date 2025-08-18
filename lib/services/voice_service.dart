import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isEnabled = true;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();
    
    try {
      // Configuración para español
      await _flutterTts.setLanguage("es-ES");
      await _flutterTts.setSpeechRate(0.5); // Velocidad lenta para adultos mayores
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);

      // Cargar preferencias guardadas
      await _loadPreferences();

      // Configurar callbacks
      _flutterTts.setStartHandler(() {
        print("TTS: Iniciando reproducción");
      });

      _flutterTts.setCompletionHandler(() {
        print("TTS: Reproducción completada");
      });

      _flutterTts.setErrorHandler((msg) {
        print("TTS Error: $msg");
      });

      _isInitialized = true;
      print("VoiceService inicializado correctamente");
    } catch (e) {
      print("Error al inicializar VoiceService: $e");
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool('voice_enabled') ?? true;
      
      final speechRate = prefs.getDouble('speech_rate') ?? 0.5;
      await _flutterTts.setSpeechRate(speechRate);
      
      final volume = prefs.getDouble('voice_volume') ?? 0.8;
      await _flutterTts.setVolume(volume);
    } catch (e) {
      print("Error al cargar preferencias de voz: $e");
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized || !_isEnabled || text.isEmpty) return;

    try {
      await _flutterTts.stop(); // Detener cualquier reproducción anterior
      await _flutterTts.speak(text);
    } catch (e) {
      print("Error al reproducir texto: $e");
    }
  }

  Future<void> stop() async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("Error al detener TTS: $e");
    }
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('voice_enabled', enabled);
    } catch (e) {
      print("Error al guardar preferencia de voz: $e");
    }
  }

  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.setSpeechRate(rate);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('speech_rate', rate);
    } catch (e) {
      print("Error al configurar velocidad de voz: $e");
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.setVolume(volume);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('voice_volume', volume);
    } catch (e) {
      print("Error al configurar volumen de voz: $e");
    }
  }

  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;

  // Frases predefinidas para la aplicación
  static const Map<String, String> phrases = {
    'welcome': 'Bienvenido a Conecta con Amor',
    'call': 'Abriendo el marcador telefónico',
    'whatsapp': 'Abriendo WhatsApp',
    'contacts': 'Abriendo contactos',
    'photos': 'Abriendo galería de fotos',
    'emergency': 'Enviando mensaje de emergencia',
    'help': 'Abriendo ayuda',
    'success': 'Operación completada correctamente',
    'error': 'Ha ocurrido un error',
    'tap_button': 'Toca cualquier botón para comenzar',
  };

  Future<void> speakPhrase(String phraseKey) async {
    final text = phrases[phraseKey] ?? phraseKey;
    await speak(text);
  }

  void dispose() {
    if (_isInitialized) {
      _flutterTts.stop();
    }
  }
}
