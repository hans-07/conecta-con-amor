import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/voice_service.dart';
import '../models/contact_model.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final VoiceService _voiceService = VoiceService();
  List<ContactModel> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
    Future.delayed(const Duration(milliseconds: 500), () {
      _voiceService.speak("Pantalla de contactos. Aquí están tus contactos favoritos.");
    });
  }

  Future<void> _loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList('favorite_contacts') ?? [];
      
      setState(() {
        _contacts = contactsJson.map((json) => ContactModel.fromJson(json)).toList();
      });

      // Si no hay contactos, agregar algunos de ejemplo
      if (_contacts.isEmpty) {
        _contacts = [
          ContactModel(
            name: 'Familia',
            phoneNumber: '123456789',
            isEmergency: true,
          ),
          ContactModel(
            name: 'Doctor',
            phoneNumber: '987654321',
            isEmergency: false,
          ),
          ContactModel(
            name: 'Emergencias',
            phoneNumber: '911',
            isEmergency: true,
          ),
        ];
        await _saveContacts();
      }
    } catch (e) {
      print("Error al cargar contactos: $e");
    }
  }

  Future<void> _saveContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = _contacts.map((contact) => contact.toJson()).toList();
      await prefs.setStringList('favorite_contacts', contactsJson);
    } catch (e) {
      print("Error al guardar contactos: $e");
    }
  }

  Future<void> _makeCall(ContactModel contact) async {
    try {
      await _voiceService.speak("Llamando a ${contact.name}");
      
      final phoneUrl = 'tel:${contact.phoneNumber}';
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        _showErrorDialog('No se puede realizar la llamada');
      }
    } catch (e) {
      _showErrorDialog('Error al llamar: $e');
    }
  }

  Future<void> _sendWhatsApp(ContactModel contact) async {
    try {
      await _voiceService.speak("Enviando WhatsApp a ${contact.name}");
      
      final whatsappUrl = 'whatsapp://send?phone=${contact.phoneNumber}';
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        _showErrorDialog('WhatsApp no está instalado o no se puede abrir');
      }
    } catch (e) {
      _showErrorDialog('Error al enviar WhatsApp: $e');
    }
  }

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

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    bool isEmergency = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Agregar Contacto',
                style: TextStyle(fontSize: 24),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    style: const TextStyle(fontSize: 18),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      labelStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isEmergency,
                        onChanged: (value) {
                          setDialogState(() {
                            isEmergency = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        'Contacto de emergencia',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar', style: TextStyle(fontSize: 18)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Agregar', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    if (nameController.text.isNotEmpty && 
                        phoneController.text.isNotEmpty) {
                      final newContact = ContactModel(
                        name: nameController.text,
                        phoneNumber: phoneController.text,
                        isEmergency: isEmergency,
                      );
                      setState(() {
                        _contacts.add(newContact);
                      });
                      _saveContacts();
                      Navigator.of(context).pop();
                      _voiceService.speak("Contacto ${nameController.text} agregado");
                    }
                  },
                ),
              ],
            );
          },
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
          'Mis Contactos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: _showAddContactDialog,
            tooltip: 'Agregar contacto',
          ),
        ],
      ),
      body: _contacts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay contactos guardados',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toca el botón + para agregar contactos',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: contact.isEmergency ? Colors.red : Colors.blue,
                      radius: 30,
                      child: Icon(
                        contact.isEmergency ? Icons.emergency : Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      contact.phoneNumber,
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 24),
                      tooltip: 'Opciones del contacto',
                      onSelected: (String action) {
                        switch (action) {
                          case 'call':
                            _makeCall(contact);
                            break;
                          case 'whatsapp':
                            _sendWhatsApp(contact);
                            break;
                          case 'delete':
                            _showDeleteConfirmation(contact, index);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'call',
                          child: Row(
                            children: [
                              Icon(Icons.phone, color: Colors.green, size: 20),
                              SizedBox(width: 12),
                              Text('Llamar', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'whatsapp',
                          child: Row(
                            children: [
                              Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                              SizedBox(width: 12),
                              Text('WhatsApp', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Eliminar', style: TextStyle(fontSize: 16, color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showDeleteConfirmation(ContactModel contact, int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Confirmar eliminación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que quieres eliminar este contacto?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: contact.isEmergency ? Colors.red : Colors.blue,
                      radius: 20,
                      child: Icon(
                        contact.isEmergency ? Icons.emergency : Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            contact.phoneNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                _voiceService.speak("Eliminación cancelada");
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteContact(contact, index);
    }
  }

  Future<void> _deleteContact(ContactModel contact, int index) async {
    try {
      // Anunciar la eliminación
      await _voiceService.speak("Eliminando contacto ${contact.name}");

      // Eliminar de la lista
      setState(() {
        _contacts.removeAt(index);
      });

      // Guardar la lista actualizada
      await _saveContacts();

      // Mostrar mensaje de confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Contacto "${contact.name}" eliminado exitosamente',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Deshacer',
              textColor: Colors.white,
              onPressed: () => _undoDelete(contact, index),
            ),
          ),
        );
      }

      // Anunciar confirmación
      await _voiceService.speak("Contacto eliminado exitosamente");

    } catch (e) {
      // Manejar errores
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Error al eliminar el contacto',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      await _voiceService.speak("Error al eliminar el contacto");
    }
  }

  Future<void> _undoDelete(ContactModel contact, int originalIndex) async {
    try {
      // Restaurar el contacto en su posición original
      setState(() {
        if (originalIndex <= _contacts.length) {
          _contacts.insert(originalIndex, contact);
        } else {
          _contacts.add(contact);
        }
      });

      // Guardar la lista actualizada
      await _saveContacts();

      // Anunciar la restauración
      await _voiceService.speak("Contacto ${contact.name} restaurado");

      // Mostrar confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.restore, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Contacto "${contact.name}" restaurado',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      await _voiceService.speak("Error al restaurar el contacto");
    }
  }

}
