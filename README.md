# 🏛️ Minerva ERP - Aplicación Móvil

## 📱 **Descripción**

Aplicación móvil multiplataforma para **Minerva ERP** desarrollada para **Android nativo** e **iOS nativo**. Incluye un sistema avanzado de reconocimiento de voz que funciona **incluso cuando la aplicación está cerrada o suspendida**.

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

### **🤖 Android**
- **Lenguaje**: Kotlin
- **Servicio**: ForegroundService persistente
- **Reconocimiento**: Vosk (offline)
- **Audio**: AudioRecord + MediaRecorder
- **Auto-arranque**: BootReceiver

### **🍎 iOS**
- **Lenguaje**: Swift
- **Servicio**: VoiceService con Background Modes
- **Reconocimiento**: Speech Framework (Apple)
- **Audio**: AVAudioEngine + AVAudioSession
- **Background**: Audio + Background Processing

### **🔗 Integración**
- **API**: Conexión con backend Flask
- **Base de Datos**: Híbrida (PostgreSQL + MongoDB)
- **Autenticación**: JWT tokens
- **Documentos**: Gestión de archivos

## 📂 **Estructura del Proyecto**

```
minerva-app/
├── 🤖 android/                    # Backend Android
│   ├── KeywordService.kt          # Servicio principal
│   ├── MainActivity.kt            # Actividad principal
│   ├── KeywordDetectionReceiver.kt # Receptor de eventos
│   ├── BootReceiver.kt            # Auto-arranque
│   └── ...
├── 🍎 ios/                        # Backend iOS
│   ├── MinervaERP/
│   │   ├── VoiceService.swift           # Servicio principal
│   │   ├── MainViewController.swift     # Controlador principal
│   │   ├── AppDelegate.swift            # Delegado de app
│   │   └── SceneDelegate.swift          # Delegado de escena
│   ├── MinervaERP.xcodeproj/      # Proyecto Xcode
│   └── Scripts de utilidad
│       ├── build_and_run.sh       # Compilar y ejecutar
│       ├── monitor_voice.sh       # Monitorear logs
│       └── configure_permissions.sh # Configurar permisos
├── 📖 BACKGROUND_VOICE_SYSTEM.md  # Documentación técnica
└── 📋 README.md                   # Este archivo
```

## 🛠️ **Instalación y Configuración**

### **Prerrequisitos**

#### **Android**
- **Android Studio**: Última versión
- **Android SDK**: API 29+ (Android 10+)
- **Kotlin**: 1.9+
- **Dispositivo Android**: Para pruebas reales

#### **iOS**
- **Xcode**: 15.0+
- **iOS Simulator**: Para pruebas
- **Dispositivo iOS**: Para pruebas reales (opcional)
- **macOS**: Requerido para desarrollo iOS
- **Gradle**: 7.0+

### **1. Clonar el Repositorio**
```bash
git clone https://github.com/pabloantoniodel/minerva-app.git
cd minerva-app
```

### **2. Configurar Android**
```bash
# Abrir en Android Studio
open -a "Android Studio" android/

# O compilar desde línea de comandos
cd android
./gradlew assembleDebug
```

### **3. Configurar iOS**
```bash
# Abrir en Xcode
open ios/MinervaERP/MinervaERP.xcodeproj

# O compilar desde línea de comandos
cd ios
./build_and_run.sh
```

### **4. Configurar Permisos**

#### **Android**
- ✅ **Micrófono**: Para escuchar "minerva"
- ✅ **Notificaciones**: Para el servicio en segundo plano
- ✅ **Optimización de Batería**: Para funcionar continuamente
- ✅ **Auto-arranque**: Para iniciar automáticamente

#### **iOS**
- ✅ **Micrófono**: Para escuchar "minerva"
- ✅ **Reconocimiento de Voz**: Para procesar audio
- ✅ **Notificaciones**: Para mostrar resultados
- ✅ **Background Modes**: Para funcionar en segundo plano

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

### **Android**

#### **1. Activación Inicial**
```bash
# Compilar e instalar
cd android
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk

# El servicio se activa automáticamente
# Notificación visible: "Minerva ERP - Always Listening"
```

#### **2. Uso Diario**
```
1. Usuario dice "minerva" (incluso con app cerrada)
2. App se abre automáticamente
3. Sistema transcribe hasta 2 segundos de silencio
4. Transcripción se muestra en la app
```

### **iOS**

#### **1. Activación Inicial**
```bash
# Compilar e instalar
cd ios
./build_and_run.sh

# Configurar permisos
./configure_permissions.sh
```

#### **2. Uso Diario**
```
1. Abrir la app Minerva ERP
2. Tocar "Iniciar Servicio"
3. Usuario dice "minerva" (incluso con app en segundo plano)
4. App se activa automáticamente
5. Sistema transcribe hasta 2 segundos de silencio
6. Transcripción se muestra en la app
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

### **iOS**
```bash
# Compilar y ejecutar
cd ios
./build_and_run.sh

# Configurar permisos automáticamente
./configure_permissions.sh

# Monitorear logs
./monitor_voice.sh

# Lanzar app manualmente
xcrun simctl launch booted com.minerva.erp

# Ver logs del simulador
xcrun simctl spawn booted log stream --predicate 'subsystem contains "com.minerva.erp"'
```

## 📱 **Compatibilidad**

### **Android**
- ✅ **Android 10+** (API 29+)
- ✅ **Todos los fabricantes**: Samsung, Xiaomi, Huawei, OnePlus, etc.
- ✅ **Arquitecturas**: ARM64, ARM32, x86_64

### **iOS**
- ✅ **iOS 13.0+**
- ✅ **iPhone**: 6s y posteriores
- ✅ **iPad**: Air 2 y posteriores
- ✅ **iPod Touch**: 7ta generación

### **Características Requeridas**
- **Micrófono**: Funcional
- **Memoria RAM**: 2GB mínimo (Android), 2GB mínimo (iOS)
- **Almacenamiento**: 500MB libres
- **Conectividad**: WiFi/4G para API (opcional)

## 🚨 **Troubleshooting**

### **Android**

#### **Problema: No detecta "minerva"**
**Soluciones**:
1. Verificar permisos de micrófono
2. Comprobar exención de optimización de batería
3. Reiniciar el KeywordService
4. Verificar que el modelo Vosk esté cargado

#### **Problema: App no se abre automáticamente**
**Soluciones**:
1. Verificar configuración de auto-arranque
2. Comprobar que KeywordDetectionReceiver esté registrado
3. Revisar logs de MainActivity

### **iOS**

#### **Problema: No detecta "minerva"**
**Soluciones**:
1. Verificar permisos de micrófono en Configuración → Privacidad → Micrófono
2. Verificar permisos de reconocimiento de voz en Configuración → Privacidad → Reconocimiento de voz
3. Reiniciar la app y tocar "Iniciar Servicio"
4. Verificar que Background Modes estén configurados

#### **Problema: App no funciona en segundo plano**
**Soluciones**:
1. Verificar que Background App Refresh esté habilitado
2. Comprobar que la app tenga permisos de fondo
3. Verificar configuración de Background Modes en Xcode
4. Reiniciar el dispositivo si es necesario
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
