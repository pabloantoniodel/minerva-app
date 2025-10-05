#!/bin/bash

# Script para configurar el dispositivo y evitar que mate el servicio
echo "🔧 Configurando dispositivo para servicio robusto..."

export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

PACKAGE_NAME="com.minerva.erp"

echo "📱 Configurando permisos y optimizaciones..."

# Otorgar todos los permisos necesarios
echo "🔐 Otorgando permisos..."
adb shell pm grant $PACKAGE_NAME android.permission.RECORD_AUDIO
adb shell pm grant $PACKAGE_NAME android.permission.WAKE_LOCK
adb shell pm grant $PACKAGE_NAME android.permission.FOREGROUND_SERVICE
adb shell pm grant $PACKAGE_NAME android.permission.FOREGROUND_SERVICE_MICROPHONE
adb shell pm grant $PACKAGE_NAME android.permission.SYSTEM_ALERT_WINDOW
adb shell pm grant $PACKAGE_NAME android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
adb shell pm grant $PACKAGE_NAME android.permission.POST_NOTIFICATIONS
adb shell pm grant $PACKAGE_NAME android.permission.RECEIVE_BOOT_COMPLETED

# Deshabilitar optimizaciones de batería para la app
echo "🔋 Deshabilitando optimizaciones de batería..."
adb shell dumpsys deviceidle whitelist +$PACKAGE_NAME

# Configurar como app de sistema (si es posible)
echo "⚙️ Configurando como app del sistema..."
adb shell settings put global device_provisioned 1

# Deshabilitar doze mode para la app
echo "😴 Deshabilitando modo doze..."
adb shell dumpsys deviceidle disable

# Configurar para mantener el servicio activo
echo "🔄 Configurando para mantener servicio activo..."
adb shell settings put global stay_on_while_plugged_in 7

# Deshabilitar hibernación de apps
echo "🌙 Deshabilitando hibernación de apps..."
adb shell settings put global app_hibernation_enabled false

# Configurar modo desarrollador para evitar optimizaciones
echo "👨‍💻 Configurando modo desarrollador..."
adb shell settings put global development_settings_enabled 1
adb shell settings put global stay_on_while_plugged_in 7

# Configurar para no matar procesos en segundo plano
echo "🛡️ Configurando protección de procesos..."
adb shell settings put global background_app_limit -1

echo "✅ Configuración completada!"
echo ""
echo "📋 Configuraciones aplicadas:"
echo "   - Permisos otorgados"
echo "   - Optimizaciones de batería deshabilitadas"
echo "   - App en whitelist de deviceidle"
echo "   - Modo doze deshabilitado"
echo "   - Hibernación de apps deshabilitada"
echo "   - Límites de apps en segundo plano deshabilitados"
echo ""
echo "🚀 El servicio debería mantenerse activo ahora"
