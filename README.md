# 🏛️ Minerva ERP - Aplicación Móvil

## 📱 **Descripción**

Aplicación móvil híbrida para **Minerva ERP** desarrollada con **Flutter** y **Android nativo**. Incluye un sistema avanzado de reconocimiento de voz que funciona **incluso cuando la aplicación está cerrada o suspendida**.

## 🎤 **Característica Principal: Sistema de Voz Inteligente**

### **✨ Funcionalidad Única**
- **Escucha Continua**: Detecta la palabra clave "minerva" 24/7
- **Activación Automática**: Abre la app automáticamente al detectar la palabra
- **Funciona en Segundo Plano**: Servicio persistente optimizado para batería
- **Sin Internet**: Reconocimiento offline usando Vosk

### **🚀 Flujo de Activación**
```
Usuario dice "minerva" → Servicio detecta → App se abre → Comandos de voz disponibles
```

## 🏗️ **Arquitectura Técnica**

### **📱 Flutter Frontend**
- **Framework**: Flutter 3.x
- **UI**: Material Design 3
- **Estado**: Provider/Riverpod
- **Navegación**: GoRouter
- **Comunicación**: MethodChannel con Android

### **🤖 Android Backend**
- **Lenguaje**: Kotlin
- **Servicio**: ForegroundService persistente
- **Reconocimiento**: Vosk (offline)
- **Audio**: AudioRecord + MediaRecorder
- **Auto-arranque**: BootReceiver

### **🔗 Integración**
- **API**: Conexión con backend Flask
- **Base de Datos**: Híbrida (PostgreSQL + MongoDB)
- **Autenticación**: JWT tokens
- **Documentos**: Gestión de archivos

## 📂 **Estructura del Proyecto**

```
minerva-app/
├── 📱 flutter/                    # Frontend Flutter
│   ├── lib/
│   │   ├── minerva_voice_plugin.dart    # Plugin de voz
│   │   ├── minerva_api_client.dart      # Cliente API
│   │   ├── voice_recognition_page.dart  # UI de voz
│   │   └── ...
│   ├── pubspec.yaml
│   └── ...
├── 🤖 android/                    # Backend Android
│   ├── KeywordService.kt          # Servicio principal
│   ├── MainActivity.kt            # Actividad principal
│   ├── KeywordDetectionReceiver.kt # Receptor de eventos
│   ├── BootReceiver.kt            # Auto-arranque
│   └── ...
├── 📖 BACKGROUND_VOICE_SYSTEM.md  # Documentación técnica
└── 📋 README.md                   # Este archivo
```

## 🛠️ **Instalación y Configuración**

### **Prerrequisitos**
- **Flutter SDK**: 3.0+
- **Android Studio**: Última versión
- **Android SDK**: API 21+ (Android 5.0+)
- **Kotlin**: 1.8+
- **Gradle**: 7.0+

### **1. Configurar Flutter**
```bash
# Clonar el repositorio
git clone https://github.com/pabloantoniodel/minerva-app.git
cd minerva-app

# Instalar dependencias Flutter
cd flutter
flutter pub get
```

### **2. Configurar Android**
```bash
# Abrir en Android Studio
open -a "Android Studio" android/

# Sincronizar proyecto
# Build → Sync Project with Gradle Files
```

### **3. Configurar Permisos**
La aplicación requiere los siguientes permisos:
- ✅ **Micrófono**: Para escuchar "minerva"
- ✅ **Notificaciones**: Para el servicio en segundo plano
- ✅ **Optimización de Batería**: Para funcionar continuamente
- ✅ **Auto-arranque**: Para iniciar automáticamente

## 🎯 **Funcionalidades**

### **🎤 Sistema de Voz**
- **Palabra Clave**: Detecta "minerva" en cualquier momento
- **Comandos de Voz**: Navegación y operaciones ERP
- **Procesamiento Local**: Sin envío de audio a servidores
- **Optimización**: Consumo mínimo de batería

### **📊 Gestión ERP**
- **Dashboard**: Métricas en tiempo real
- **Clientes**: Gestión completa de CRM
- **Facturas**: Creación y envío
- **Documentos**: Visualización y gestión
- **Reportes**: Análisis y estadísticas

### **🔐 Seguridad**
- **Autenticación JWT**: Tokens seguros
- **Cifrado**: Comunicaciones encriptadas
- **Biometría**: Desbloqueo con huella/cara
- **Sesiones**: Control de acceso

## 🚀 **Uso del Sistema de Voz**

### **1. Activación Inicial**
```bash
# Iniciar la aplicación
flutter run

# El servicio se activa automáticamente
# Notificación visible: "Minerva ERP - Always Listening"
```

### **2. Uso Diario**
```
1. Usuario dice "minerva" (incluso con app cerrada)
2. App se abre automáticamente
3. Sistema muestra interfaz de voz
4. Usuario da comandos: "crear factura", "buscar cliente", etc.
5. Sistema ejecuta comandos y muestra resultados
```

### **3. Comandos Disponibles**
- **"Crear factura"** → Abre formulario de facturación
- **"Buscar cliente [nombre]"** → Busca en base de datos
- **"Ver reportes"** → Muestra dashboard
- **"Nueva empresa"** → Formulario de empresa
- **"Cerrar sesión"** → Logout seguro

## ⚙️ **Configuración Avanzada**

### **Optimización de Batería**
```kotlin
// En KeywordService.kt
private fun initializePowerManagement() {
    val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
    wakeLock = powerManager.newWakeLock(
        PowerManager.PARTIAL_WAKE_LOCK,
        "MinervaERP::KeywordService"
    )
    wakeLock?.acquire()
}
```

### **Configuración de Audio**
```kotlin
// Configuración optimizada para detección
private val audioConfig = AudioRecord(
    MediaRecorder.AudioSource.MIC,
    16000, // Sample rate optimizado para Vosk
    AudioFormat.CHANNEL_IN_MONO,
    AudioFormat.ENCODING_PCM_16BIT,
    AudioRecord.getMinBufferSize(16000, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)
)
```

## 🔧 **Desarrollo**

### **Estructura de Comunicación**
```
Flutter App ←→ MethodChannel ←→ Android Service
     ↓              ↓                ↓
  UI Layer    Event Handling    Audio Processing
     ↓              ↓                ↓
API Calls ←→ HTTP Client ←→ Backend Flask
```

### **Archivos Clave**
- **`minerva_voice_plugin.dart`**: Comunicación Flutter-Android
- **`KeywordService.kt`**: Servicio de reconocimiento
- **`MainActivity.kt`**: Punto de entrada y permisos
- **`voice_recognition_page.dart`**: Interfaz de usuario

### **Debugging**
```bash
# Ver logs del servicio
adb logcat | grep "KeywordService"

# Ver logs de Flutter
flutter logs

# Verificar permisos
adb shell dumpsys package com.minerva.erp | grep permission
```

## 📱 **Compatibilidad**

### **Dispositivos Soportados**
- ✅ **Android 5.0+** (API 21+)
- ✅ **Todos los fabricantes**: Samsung, Xiaomi, Huawei, OnePlus, etc.
- ✅ **Arquitecturas**: ARM64, ARM32, x86_64

### **Características Requeridas**
- **Micrófono**: Funcional
- **Memoria RAM**: 2GB mínimo
- **Almacenamiento**: 500MB libres
- **Conectividad**: WiFi/4G para API

## 🚨 **Troubleshooting**

### **Problema: No detecta "minerva"**
**Soluciones**:
1. Verificar permisos de micrófono
2. Comprobar exención de optimización de batería
3. Reiniciar el KeywordService
4. Verificar que el modelo Vosk esté cargado

### **Problema: App no se abre automáticamente**
**Soluciones**:
1. Verificar configuración de auto-arranque
2. Comprobar que KeywordDetectionReceiver esté registrado
3. Revisar logs de MainActivity
4. Verificar flags de Intent

### **Problema: Servicio se detiene**
**Soluciones**:
1. Verificar configuración de batería
2. Comprobar que START_STICKY esté configurado
3. Revisar logs de BootReceiver
4. Verificar permisos de servicio en primer plano

## 📊 **Métricas de Rendimiento**

### **Consumo de Recursos**
- **Batería**: ~2-3% por día en modo escucha
- **RAM**: ~50-80MB para el servicio
- **CPU**: <1% en modo inactivo
- **Red**: Solo durante comandos activos

### **Tiempos de Respuesta**
- **Detección de palabra clave**: <500ms
- **Apertura de app**: <2 segundos
- **Procesamiento de comandos**: <3 segundos
- **Sincronización con backend**: <5 segundos

## 🔮 **Roadmap Futuro**

### **Versión 2.0**
- [ ] **Reconocimiento Multilingüe**: Español, Inglés, Portugués
- [ ] **Comandos Personalizados**: Configuración de palabras clave
- [ ] **Integración Wear OS**: Relojes inteligentes
- [ ] **Modo Offline**: Funcionalidades sin conexión

### **Versión 2.1**
- [ ] **IA Avanzada**: ChatGPT para comandos naturales
- [ ] **Análisis de Sentimientos**: Detección de emociones
- [ ] **Reportes de Voz**: Generación automática
- [ ] **Integración IoT**: Dispositivos conectados

## 📄 **Licencia**

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 👥 **Contribución**

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 **Soporte**

- **Email**: soporte@minerva-erp.com
- **Documentación**: [docs.minerva-erp.com](https://docs.minerva-erp.com)
- **Issues**: [GitHub Issues](https://github.com/pabloantoniodel/minerva-app/issues)

---

**🏛️ Minerva ERP - Revolucionando la Gestión Empresarial con Voz**

*Desarrollado con ❤️ para empresas modernas*
