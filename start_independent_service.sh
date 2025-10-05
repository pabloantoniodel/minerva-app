#!/bin/bash

# Script para iniciar el servicio independientemente de la app
echo "🚀 Iniciando servicio de voz independiente..."

export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

PACKAGE_NAME="com.minerva.erp"
SERVICE_NAME="com.minerva.erp.service.KeywordService"

echo "📱 Iniciando servicio directamente..."

# Iniciar el servicio directamente sin abrir la app
adb shell am startservice -n $PACKAGE_NAME/$SERVICE_NAME --ez independent_mode true --ez auto_restart true

echo "✅ Servicio iniciado independientemente"
echo ""
echo "🔍 Verificando estado del servicio..."
adb shell dumpsys activity services $PACKAGE_NAME | grep -A 5 -B 5 "KeywordService"

echo ""
echo "📊 Monitoreando logs del servicio..."
echo "   (Presiona Ctrl+C para detener el monitoreo)"
echo ""
adb logcat -s KeywordService -v time