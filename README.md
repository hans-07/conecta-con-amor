# 📱 Conecta con Amor

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

**Una aplicación Flutter diseñada especialmente para adultos mayores**
*Interfaz simple, botones grandes y guía por voz en español*
</div>

---

## ✨ Características Principales

### 🎯 **Diseño Inclusivo**
- **Interfaz ultra-simple**: Botones grandes (120x120px) y fáciles de tocar
- **Tipografía accesible**: Texto de 18-32px para mejor legibilidad
- **Colores contrastantes**: Diseño optimizado para problemas de visión
- **Espaciado generoso**: Elementos bien separados para evitar toques accidentales

### 🗣️ **Accesibilidad Completa**
- **Guía por voz**: Instrucciones claras en español con TTS
- **TalkBack compatible**: Etiquetas Semantics en todos los elementos
- **Anuncios contextuales**: Feedback de voz para cada acción
- **Botón de ayuda**: Repetir instrucciones en cualquier momento

### 📞 **Comunicación Simplificada**
- **Llamadas fáciles**: Acceso directo al marcador telefónico
- **WhatsApp integrado**: Envío de mensajes paso a paso
- **Contactos favoritos**: Lista personalizable con opciones de eliminar
- **Tutoriales interactivos**: Guías completas para llamadas y WhatsApp

### 📱 **Más Aplicaciones**
- **Launcher integrado**: Acceso a 9 aplicaciones populares
- **Lanzamiento inteligente**: Sistema robusto con múltiples fallbacks
- **Apps incluidas**: Cámara, Música, Mapas, Gmail, Chrome, YouTube, Facebook, Play Store, Configuración

## 🚀 Instalación y Ejecución

### 📋 Prerrequisitos

| Herramienta | Versión Mínima | Recomendada |
|-------------|----------------|-------------|
| Flutter SDK | 3.35.1 | Última estable |
| Dart | 3.5.1 | Incluido con Flutter |
| Android Studio | 2023.1 | Última versión |
| VS Code | 1.80+ | Con extensión Flutter |

### 🛠️ Configuración del Entorno

1. **Instalar Flutter**
   ```bash
   # Verificar instalación
   flutter doctor

   # Debe mostrar ✓ en Android toolchain y VS Code/Android Studio
   ```

2. **Clonar el repositorio**
   ```bash
   git clone https://github.com/hans-07/conecta-con-amor.git
   cd conecta_con_amor
   ```

3. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

4. **Verificar dispositivos**
   ```bash
   flutter devices
   ```

### 🏃‍♂️ Ejecutar la Aplicación

#### Modo Desarrollo
```bash
# Android
flutter run -d android

# iOS (solo en macOS)
flutter run -d ios

# Escritorio (Linux/Windows/macOS)
flutter run -d linux
flutter run -d windows
flutter run -d macos
```

#### Compilar para Producción
```bash
# APK para Android
flutter build apk --release

# App Bundle (recomendado para Play Store)
flutter build appbundle --release

# iOS (solo en macOS)
flutter build ios --release
```

### 📦 Archivos Generados
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

## 🏗️ Estructura del Proyecto

```
conecta_con_amor/
├── 📁 lib/
│   ├── 🚀 main.dart                      # Punto de entrada de la aplicación
│   ├── 📱 screens/                       # Pantallas de la aplicación
│   │   ├── home_screen.dart              # 🏠 Pantalla principal con launcher
│   │   ├── contacts_screen.dart          # 👥 Gestión de contactos favoritos
│   │   ├── help_screen.dart              # ❓ Centro de ayuda y soporte
│   │   ├── whatsapp_tutorial_screen.dart # 💬 Tutorial interactivo de WhatsApp
│   │   └── call_tutorial_screen.dart     # 📞 Tutorial interactivo de llamadas
│   ├── 🔧 services/                      # Servicios de la aplicación
│   │   ├── voice_service.dart            # 🗣️ Texto a voz (TTS) en español
│   │   └── emergency_service.dart        # 🚨 Gestión de emergencias y SMS
│   ├── 🧩 widgets/                       # Widgets reutilizables
│   │   └── big_button.dart               # 🔘 Botón grande personalizado
│   └── 📊 models/                        # Modelos de datos
│       └── contact_model.dart            # 👤 Modelo de contacto con JSON
├── 📁 android/                           # Configuración específica de Android
├── 📁 ios/                               # Configuración específica de iOS
├── 📁 assets/                            # Recursos estáticos
│   └── images/                           # Imágenes y iconos
├── 📄 pubspec.yaml                       # Dependencias y configuración
└── 📖 README.md                          # Este archivo
```

### 📋 Descripción de Componentes

| Componente | Descripción | Funcionalidades |
|------------|-------------|-----------------|
| **HomeScreen** | Pantalla principal | Launcher con 5 botones principales + Más Apps |
| **ContactsScreen** | Gestión de contactos | Agregar, eliminar, llamar, WhatsApp |
| **TutorialScreens** | Tutoriales interactivos | Guías paso a paso con voz y accesibilidad |
| **VoiceService** | Servicio de voz | TTS en español, anuncios contextuales |

### 🌈 **Paleta de Colores**
```css
/* Colores principales */
--primary-green: #4CAF50    /* Llamadas */
--whatsapp-green: #25D366   /* WhatsApp */
--emergency-red: #F44336    /* Emergencias */
--orange-apps: #FF9800      /* Más Apps */
--purple-photos: #9C27B0    /* Fotos */
--blue-help: #2196F3        /* Ayuda */
```

### 📐 **Sistema de Grid**
- **Grid 2x2**: Pantalla principal (5 botones + Más Apps)
- **Grid 3x3**: Modal de aplicaciones
- **Lista vertical**: Contactos y tutoriales

---

## 📋 Funcionalidades Detalladas

### 🏠 **Pantalla Principal**
<details>
<summary>Ver características completas</summary>

- **5 botones principales** organizados en grid 2x2 + 1
- **Animaciones suaves** para feedback visual

**Botones incluidos:**
- 📞 **Llamadas** → Tutorial + Marcador nativo
- 💬 **WhatsApp** → Tutorial + Integración directa
- 👥 **Contactos** → Gestión completa de favoritos
- 📸 **Fotos** → Acceso a galería del sistema
- 📱 **Más Apps** → Launcher con 9 aplicaciones populares

</details>

### 👥 **Gestión de Contactos**
<details>
<summary>Ver características completas</summary>

**Funcionalidades Avanzadas:**
- ✅ **Agregar contactos** con formulario simple
- ✅ **Eliminar contactos** con confirmación segura
- ✅ **Función "Deshacer"** por 3 segundos
- ✅ **Menú contextual** (Llamar, WhatsApp, Eliminar)
- ✅ **Contactos de emergencia** marcados especialmente

**Interfaz:**
- Lista vertical con avatares coloridos
- Botones de acción en menú desplegable
- Diálogos de confirmación claros
- Feedback visual y auditivo completo

</details>

### 📱 **Más Aplicaciones**
<details>
<summary>Ver características completas</summary>

**Launcher Integrado:**
- ✅ **9 aplicaciones populares** preconfiguradas
- ✅ **Accesibilidad completa** con TalkBack

**Apps Incluidas:**
- 📷 **Cámara** → Intent nativo `IMAGE_CAPTURE`
- 🎵 **Música** → Intent nativo `MUSIC_PLAYER`
- 🗺️ **Mapas** → Intent nativo `geo:` y `APP_MAPS`
- 📧 **Gmail** → Intent nativo `mailto:` y `SENDTO`
- 🌐 **Chrome** → Intent nativo `VIEW` con URL
- 📺 **YouTube** → com.google.android.youtube
- 👥 **Facebook** → com.facebook.katana
- 🛒 **Play Store** → com.android.vending
- ⚙️ **Configuración** → Intent nativo `SETTINGS`

</details>

### ❓ **Centro de Ayuda**
<details>
<summary>Ver características completas</summary>

**Tutoriales Interactivos:**
- ✅ **Tutorial de WhatsApp** (6 pasos)
- ✅ **Tutorial de Llamadas** (5 pasos)
- ✅ **Guías paso a paso** con voz
- ✅ **Botón de repetir** instrucciones
- ✅ **Navegación intuitiva** entre pasos
</details>

---

## 🔧 Dependencias y Tecnologías

### 📦 **Dependencias Principales**

| Paquete | Versión | Propósito | Documentación |
|---------|---------|-----------|---------------|
| `url_launcher` | ^6.2.4 | Llamadas, SMS, WhatsApp, Apps externas | [📖 Docs](https://pub.dev/packages/url_launcher) |
| `flutter_tts` | ^4.0.2 | Texto a voz en español (TTS) | [📖 Docs](https://pub.dev/packages/flutter_tts) |
| `image_picker` | ^1.0.7 | Acceso a galería de fotos | [📖 Docs](https://pub.dev/packages/image_picker) |
| `vibration` | ^1.8.4 | Feedback háptico y vibración | [📖 Docs](https://pub.dev/packages/vibration) |
| `shared_preferences` | ^2.2.2 | Almacenamiento local persistente | [📖 Docs](https://pub.dev/packages/shared_preferences) |
| `overlay_support` | ^2.1.0 | Superposiciones para tutoriales | [📖 Docs](https://pub.dev/packages/overlay_support) |

### 🛠️ **Dependencias de Desarrollo**

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `flutter_test` | SDK | Testing framework |
| `flutter_lints` | ^3.0.0 | Análisis de código |

### 🏗️ **Arquitectura Técnica**

```mermaid
graph TD
    A[main.dart] --> B[HomeScreen]
    B --> C[ContactsScreen]
    B --> D[TutorialScreens]
    B --> E[HelpScreen]

    C --> F[ContactModel]
    D --> G[VoiceService]
    E --> G

    G --> H[flutter_tts]
    F --> I[shared_preferences]

    B --> J[url_launcher]
    J --> K[Llamadas]
    J --> L[WhatsApp]
    J --> M[Apps Externas]
```

## 🎯 Público Objetivo

### 👥 **Usuarios Principales**
- **Adultos mayores (65+ años)** con poca experiencia tecnológica
- **Personas con discapacidades visuales** que necesitan accesibilidad
- **Usuarios con problemas motores** que requieren botones grandes
- **Familias** que buscan facilitar la comunicación con adultos mayores

### 📊 **Casos de Uso**
- **Comunicación familiar**: Llamadas y WhatsApp simplificados
- **Emergencias**: Contacto rápido con familiares y servicios
- **Entretenimiento**: Acceso fácil a fotos y aplicaciones
- **Aprendizaje**: Tutoriales paso a paso para nuevas tecnologías

---

## 🧪 Testing y Calidad

### ✅ **Pruebas Implementadas**
- **Pruebas unitarias** para servicios críticos
- **Pruebas de widgets** para componentes principales
- **Pruebas de integración** para flujos completos
- **Pruebas de accesibilidad** con TalkBack/VoiceOver

### 🔍 **Análisis de Código**
```bash
# Ejecutar análisis estático
flutter analyze

# Ejecutar todas las pruebas
flutter test

# Generar reporte de cobertura
flutter test --coverage
```
---

#### Estilo de Código
- Seguir las [convenciones de Dart](https://dart.dev/guides/language/effective-dart)
- Usar `flutter format` antes de cada commit
- Mantener cobertura de pruebas > 80%
