import 'dart:convert';

class ContactModel {
  final String name;
  final String phoneNumber;
  final bool isEmergency;
  final String? email;
  final String? notes;

  ContactModel({
    required this.name,
    required this.phoneNumber,
    this.isEmergency = false,
    this.email,
    this.notes,
  });

  // Convertir a JSON para guardar en SharedPreferences
  String toJson() {
    return jsonEncode({
      'name': name,
      'phoneNumber': phoneNumber,
      'isEmergency': isEmergency,
      'email': email,
      'notes': notes,
    });
  }

  // Crear desde JSON
  factory ContactModel.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ContactModel(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isEmergency: json['isEmergency'] ?? false,
      email: json['email'],
      notes: json['notes'],
    );
  }

  // Crear copia con modificaciones
  ContactModel copyWith({
    String? name,
    String? phoneNumber,
    bool? isEmergency,
    String? email,
    String? notes,
  }) {
    return ContactModel(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmergency: isEmergency ?? this.isEmergency,
      email: email ?? this.email,
      notes: notes ?? this.notes,
    );
  }

  // Validar número de teléfono
  bool get isValidPhoneNumber {
    // Expresión regular básica para números de teléfono
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');
    return phoneRegex.hasMatch(phoneNumber.trim());
  }

  // Formatear número de teléfono para mostrar
  String get formattedPhoneNumber {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Si es un número de 10 dígitos, formatear como (XXX) XXX-XXXX
    if (cleaned.length == 10 && !cleaned.startsWith('+')) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    
    return phoneNumber;
  }

  // Obtener número limpio para llamadas
  String get cleanPhoneNumber {
    return phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  @override
  String toString() {
    return 'ContactModel(name: $name, phoneNumber: $phoneNumber, isEmergency: $isEmergency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactModel &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.isEmergency == isEmergency &&
        other.email == email &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        phoneNumber.hashCode ^
        isEmergency.hashCode ^
        email.hashCode ^
        notes.hashCode;
  }
}
