#!/bin/bash

# Script para probar la funcionalidad completa de permisos
# Incluye: micrófono, notificaciones y optimización de batería

echo "🎤 Probando funcionalidad completa de permisos de Minerva ERP"
echo "============================================================="

# Configurar variables
export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Verificar conexión del dispositivo
echo "📱 Verificando conexión del dispositivo..."
if ! adb devices | grep -q "device$"; then
    echo "❌ Error: No hay dispositivos conectados"
    exit 1
fi

echo "✅ Dispositivo conectado"

# Limpiar logs anteriores
echo "🧹 Limpiando logs anteriores..."
adb logcat -c

# Lanzar la aplicación
echo "🚀 Lanzando aplicación..."
adb shell am start -n com.minerva.erp/.MainActivity

echo ""
echo "📋 INSTRUCCIONES PARA EL USUARIO:"
echo "================================="
echo "1. La app solicitará permisos de micrófono - ACEPTAR"
echo "2. La app solicitará permisos de notificaciones (Android 13+) - ACEPTAR"
echo "3. La app abrirá configuración de optimización de batería - DESHABILITAR optimización para Minerva ERP"
echo "4. El servicio se iniciará automáticamente"
echo ""
echo "🔍 Monitoreando logs de la aplicación..."
echo "Presiona Ctrl+C para detener el monitoreo"
echo ""

# Monitorear logs de la aplicación
adb logcat -s MainActivity KeywordService -v time
