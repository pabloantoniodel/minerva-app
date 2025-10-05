# Sistema de Escucha en Segundo Plano - Minerva ERP

## 🎯 **Funcionalidad Principal**

El sistema permite que Minerva ERP escuche continuamente la palabra clave "minerva" **incluso cuando la aplicación está cerrada o suspendida**, activando automáticamente la aplicación y iniciando el reconocimiento de voz.

## 🏗️ **Arquitectura del Sistema**

### **1. KeywordService (Servicio Principal)**
- **Ubicación**: `android/KeywordService.kt`
- **Tipo**: Servicio en primer plano persistente
- **Funcionalidad**:
  - Escucha continua de audio del micrófono
  - Detección de la palabra clave "minerva" usando Vosk
  - Auto-reinicio si es terminado por el sistema
  - Notificación persistente visible al usuario

### **2. KeywordDetectionReceiver (Receptor de Eventos)**
- **Ubicación**: `android/KeywordDetectionReceiver.kt`
- **Funcionalidad**:
  - Recibe broadcast cuando se detecta la palabra clave
  - Lanza automáticamente la MainActivity
  - Maneja el despertar de la aplicación

### **3. BootReceiver (Auto-arranque)**
- **Ubicación**: `android/BootReceiver.kt`
- **Funcionalidad**:
  - Inicia automáticamente el KeywordService al arrancar el dispositivo
  - Reinicia el servicio después de actualizaciones de la app

### **4. MainActivity (Punto de Entrada)**
- **Funcionalidad**:
  - Maneja el lanzamiento automático por palabra clave
  - Solicita exención de optimizaciones de batería
  - Integra con Flutter para mostrar la interfaz

## 🔧 **Configuración Técnica**

### **Permisos Requeridos**
```xml
<!-- Grabación de audio -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Servicio en primer plano -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />

<!-- Optimizaciones de batería -->
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

<!-- Auto-arranque -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Notificaciones -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### **Configuración del Servicio**
```kotlin
// Servicio persistente con auto-reinicio
override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    startForeground(PERSISTENT_NOTIFICATION_ID, buildPersistentNotification())
    startListening()
    return START_STICKY // Reinicia automáticamente si es terminado
}
```

## 🚀 **Flujo de Funcionamiento**

### **1. Inicio del Sistema**
```
Dispositivo arranca → BootReceiver → KeywordService → Escucha continua
```

### **2. Detección de Palabra Clave**
```
Usuario dice "minerva" → KeywordService detecta → Broadcast → KeywordDetectionReceiver → MainActivity se lanza
```

### **3. Activación de la App**
```
MainActivity lanzada → Flutter se inicializa → Página de reconocimiento de voz → Usuario puede dar comandos
```

## ⚙️ **Configuración del Usuario**

### **1. Permisos Iniciales**
Al instalar la app, el usuario debe otorgar:
- ✅ **Permiso de micrófono**: Para escuchar la palabra clave
- ✅ **Permiso de notificaciones**: Para mostrar el servicio activo
- ✅ **Exención de optimización de batería**: Para funcionar en segundo plano

### **2. Notificación Persistente**
- **Título**: "Minerva ERP - Always Listening"
- **Mensaje**: "Say 'minerva' to activate voice commands"
- **Funcionalidad**: Al tocarla, abre la aplicación

### **3. Configuración de Batería**
El sistema solicita automáticamente exención de optimizaciones de batería para:
- Mantener el servicio activo
- Continuar escuchando en segundo plano
- Funcionar incluso con el dispositivo en modo ahorro de energía

## 🔄 **Estados del Sistema**

### **Estado 1: App Cerrada, Servicio Activo**
- ✅ KeywordService escuchando continuamente
- ✅ Notificación persistente visible
- ✅ Detección de "minerva" funcional

### **Estado 2: App Suspendida, Servicio Activo**
- ✅ KeywordService sigue funcionando
- ✅ Detección de palabra clave activa
- ✅ Auto-lanzamiento de la app

### **Estado 3: App Abierta, Servicio Activo**
- ✅ Funcionamiento normal
- ✅ Escucha continua para reactivación
- ✅ Integración completa con Flutter

## 🛠️ **Mantenimiento y Monitoreo**

### **Logs del Sistema**
```kotlin
// Logs principales para debugging
Log.d("KeywordService", "Listening started")
Log.d("KeywordService", "Keyword 'minerva' detected!")
Log.d("BootReceiver", "Device booted, starting KeywordService")
```

### **Verificación del Estado**
```kotlin
// Verificar si el servicio está activo
val isServiceRunning = isServiceRunning(KeywordService::class.java)
```

### **Reinicio Manual**
```kotlin
// Reiniciar el servicio si es necesario
val intent = Intent(this, KeywordService::class.java)
startForegroundService(intent)
```

## ⚠️ **Consideraciones Importantes**

### **1. Optimizaciones de Batería**
- **Samsung**: Desactivar optimización de batería en configuración
- **Xiaomi**: Permitir auto-arranque y ejecución en segundo plano
- **Huawei**: Agregar a lista blanca de aplicaciones protegidas
- **OnePlus**: Desactivar optimización de batería avanzada

### **2. Limitaciones del Sistema**
- **Android 8+**: Requiere servicio en primer plano
- **Modo Doze**: Puede afectar la detección en algunos dispositivos
- **Restricciones OEM**: Algunos fabricantes limitan servicios en segundo plano

### **3. Privacidad y Seguridad**
- ✅ Solo escucha la palabra clave específica
- ✅ No almacena audio sin activación
- ✅ Procesamiento local con Vosk
- ✅ Transmisión de datos solo después de activación

## 🎯 **Casos de Uso**

### **1. Trabajo Remoto**
```
Usuario en casa → Dice "minerva" → App se abre → "Crear nueva factura" → Proceso automatizado
```

### **2. Oficina**
```
Usuario en reunión → Dice "minerva" → App se abre → "Buscar cliente Juan Pérez" → Información mostrada
```

### **3. Movilidad**
```
Usuario caminando → Dice "minerva" → App se abre → "Crear nota de gastos" → Captura rápida
```

## 📱 **Integración con Flutter**

### **Event Channel**
```dart
// Escuchar eventos de detección de palabra clave
EventChannel('minerva_voice_events').receiveBroadcastStream()
  .listen((event) {
    if (event['type'] == 'keyword_detected') {
      // Mostrar interfaz de voz activa
      showVoiceInterface();
    }
  });
```

### **Method Channel**
```dart
// Inicializar el sistema de escucha
await platform.invokeMethod('initialize');
```

## 🔧 **Troubleshooting**

### **Problema: No detecta palabra clave**
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

## 🎉 **Beneficios del Sistema**

### **✅ Experiencia de Usuario**
- **Activación instantánea** con solo decir "minerva"
- **Funciona sin tocar el dispositivo**
- **Acceso rápido a funciones ERP**

### **✅ Productividad**
- **Reducción de pasos** para acceder a la app
- **Manejo hands-free** de tareas
- **Integración natural** con flujo de trabajo

### **✅ Tecnología Avanzada**
- **IA local** para detección de palabras clave
- **Arquitectura robusta** con auto-recuperación
- **Optimización de batería** inteligente

---

**🏛️ Minerva ERP - Sistema de Escucha Inteligente en Segundo Plano**
