import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  // Contactos de emergencia predeterminados
  List<String> _emergencyContacts = [
    '911', // Número de emergencia general
    '123456789', // Contacto familiar 1 (ejemplo)
  ];

  String _emergencyMessage = 'Necesito ayuda urgente. Este es un mensaje automático de emergencia.';

  Future<void> initialize() async {
    await _loadEmergencyContacts();
    await _loadEmergencyMessage();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contacts = prefs.getStringList('emergency_contacts');
      if (contacts != null && contacts.isNotEmpty) {
        _emergencyContacts = contacts;
      }
    } catch (e) {
      print("Error al cargar contactos de emergencia: $e");
    }
  }

  Future<void> _loadEmergencyMessage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final message = prefs.getString('emergency_message');
      if (message != null && message.isNotEmpty) {
        _emergencyMessage = message;
      }
    } catch (e) {
      print("Error al cargar mensaje de emergencia: $e");
    }
  }

  Future<bool> sendEmergencySMS() async {
    if (_emergencyContacts.isEmpty) {
      print("No hay contactos de emergencia configurados");
      return false;
    }

    try {
      // Crear la URL para SMS con múltiples destinatarios
      final recipients = _emergencyContacts.join(',');
      final encodedMessage = Uri.encodeComponent(_emergencyMessage);
      final smsUrl = 'sms:$recipients?body=$encodedMessage';

      if (await canLaunchUrl(Uri.parse(smsUrl))) {
        await launchUrl(Uri.parse(smsUrl));
        return true;
      } else {
        print("No se puede abrir la aplicación de SMS");
        return false;
      }
    } catch (e) {
      print("Error al enviar SMS de emergencia: $e");
      return false;
    }
  }

  Future<bool> makeEmergencyCall() async {
    if (_emergencyContacts.isEmpty) {
      print("No hay contactos de emergencia configurados");
      return false;
    }

    try {
      // Llamar al primer contacto de emergencia
      final phoneUrl = 'tel:${_emergencyContacts.first}';
      
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
        return true;
      } else {
        print("No se puede realizar la llamada");
        return false;
      }
    } catch (e) {
      print("Error al realizar llamada de emergencia: $e");
      return false;
    }
  }

  Future<void> addEmergencyContact(String phoneNumber) async {
    if (phoneNumber.isNotEmpty && !_emergencyContacts.contains(phoneNumber)) {
      _emergencyContacts.add(phoneNumber);
      await _saveEmergencyContacts();
    }
  }

  Future<void> removeEmergencyContact(String phoneNumber) async {
    _emergencyContacts.remove(phoneNumber);
    await _saveEmergencyContacts();
  }

  Future<void> _saveEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('emergency_contacts', _emergencyContacts);
    } catch (e) {
      print("Error al guardar contactos de emergencia: $e");
    }
  }

  Future<void> setEmergencyMessage(String message) async {
    if (message.isNotEmpty) {
      _emergencyMessage = message;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('emergency_message', message);
      } catch (e) {
        print("Error al guardar mensaje de emergencia: $e");
      }
    }
  }

  List<String> get emergencyContacts => List.unmodifiable(_emergencyContacts);
  String get emergencyMessage => _emergencyMessage;

  // Validar número de teléfono
  bool isValidPhoneNumber(String phoneNumber) {
    // Expresión regular básica para números de teléfono
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');
    return phoneRegex.hasMatch(phoneNumber.trim());
  }

  // Formatear número de teléfono
  String formatPhoneNumber(String phoneNumber) {
    // Remover espacios y caracteres especiales excepto +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return cleaned;
  }

  // Obtener información de emergencia para mostrar en configuración
  Map<String, dynamic> getEmergencyInfo() {
    return {
      'contacts': _emergencyContacts,
      'message': _emergencyMessage,
      'contactCount': _emergencyContacts.length,
    };
  }
}
