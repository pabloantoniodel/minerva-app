# Minerva ERP - iOS

Aplicación iOS para reconocimiento de voz continuo en segundo plano con detección de palabra clave "minerva" y transcripción automática.

## 🚀 Características

- **Reconocimiento de voz continuo** en segundo plano
- **Detección de palabra clave** "minerva"
- **Transcripción automática** hasta 2 segundos de silencio
- **Gestión de permisos** automática
- **Funcionamiento en segundo plano** con background modes
- **Interfaz simple** para control del servicio

## 📋 Requisitos

- **iOS 13.0+**
- **Xcode 15.0+**
- **Permisos de micrófono**
- **Permisos de reconocimiento de voz**

## 🛠️ Instalación

### 1. Compilar y ejecutar
```bash
cd ios/
./build_and_run.sh
```

### 2. Compilación manual
```bash
# Abrir en Xcode
open MinervaERP/MinervaERP.xcodeproj

# O compilar desde línea de comandos
xcodebuild -project MinervaERP/MinervaERP.xcodeproj \
           -scheme MinervaERP \
           -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
           build
```

## 🔧 Configuración

### Permisos necesarios:
1. **Micrófono** (`NSMicrophoneUsageDescription`)
2. **Reconocimiento de voz** (`NSSpeechRecognitionUsageDescription`)
3. **Background modes** (`UIBackgroundModes`)

### Background Modes configurados:
- `audio` - Para grabación en segundo plano
- `background-processing` - Para procesamiento continuo
- `background-fetch` - Para mantenimiento del servicio

## 📱 Uso

### Primera vez:
1. La app solicita permisos de micrófono → **ACEPTAR**
2. La app solicita permisos de reconocimiento de voz → **ACEPTAR**
3. Tocar "Iniciar Servicio"

### Funcionamiento:
1. **Servicio activo**: Escucha continuamente en segundo plano
2. **Detección**: Al decir "minerva" → Abre la app automáticamente
3. **Transcripción**: Transcribe todo hasta 2 segundos de silencio
4. **Resultado**: Muestra la transcripción completa

## 🏗️ Arquitectura

### Archivos principales:
- **`AppDelegate.swift`** - Configuración inicial y permisos
- **`SceneDelegate.swift`** - Gestión del ciclo de vida de la app
- **`VoiceService.swift`** - Servicio principal de reconocimiento de voz
- **`MainViewController.swift`** - Interfaz de usuario y control

### Servicios:
- **`VoiceService.shared`** - Singleton para reconocimiento de voz
- **Background Task** - Mantiene el servicio activo en segundo plano
- **Audio Session** - Configuración de audio para grabación continua

## 🔍 Debugging

### Logs importantes:
```bash
# Ver logs del simulador
xcrun simctl spawn booted log stream --predicate 'subsystem contains "com.minerva.erp"'

# Ver logs del dispositivo (requiere dispositivo conectado)
xcrun devicectl list devices
```

### Estados del servicio:
- `🎤 Starting voice recognition service...` - Iniciando
- `✅ Voice recognition started` - Activo
- `🎯 Keyword 'minerva' detected!` - Palabra clave detectada
- `📝 Starting transcription...` - Iniciando transcripción
- `📝 Transcription completed` - Transcripción completa

## 🚨 Solución de problemas

### Error: "Microphone permission denied"
- Ir a Configuración → Privacidad → Micrófono → Minerva ERP → Permitir

### Error: "Speech recognition permission denied"
- Ir a Configuración → Privacidad → Reconocimiento de voz → Minerva ERP → Permitir

### El servicio se detiene en segundo plano:
- Verificar que Background Modes estén configurados
- Verificar que la app tenga permisos de fondo
- En iOS 13+, puede requerir configuración adicional

### No detecta la palabra "minerva":
- Verificar permisos de micrófono
- Asegurar que el audio esté llegando al dispositivo
- Verificar logs para errores de reconocimiento

## 🔄 Diferencias con Android

### Ventajas de iOS:
- **Speech Framework** nativo más robusto
- **Background modes** más predecibles
- **Gestión de memoria** automática

### Limitaciones:
- **Más restrictivo** con servicios en segundo plano
- **Requiere configuración** adicional para background processing
- **Dependiente del sistema** de reconocimiento de voz de Apple

## 📝 Notas de desarrollo

### Simulador vs Dispositivo real:
- **Simulador**: Usa simulación de detección de audio
- **Dispositivo real**: Usa Speech Framework real

### Optimizaciones:
- **Background Task** para mantener el servicio activo
- **Audio Session** optimizada para grabación continua
- **Memory management** automático con ARC

### Próximas mejoras:
- [ ] Soporte para múltiples idiomas
- [ ] Configuración de sensibilidad de audio
- [ ] Historial de transcripciones
- [ ] Integración con API del backend
