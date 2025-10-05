#!/bin/bash

echo "🎤 Minerva ERP - Monitor de Reconocimiento de Voz"
echo "================================================="

export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

echo "📱 Verificando dispositivos conectados..."
adb devices

echo ""
echo "🔍 Monitoreando logs de reconocimiento de voz..."
echo "   Presiona Ctrl+C para detener"
echo ""
echo "💡 Instrucciones:"
echo "   • En emulador: Espera 10 segundos para simulación"
echo "   • En dispositivo real: Di 'minerva' cerca del micrófono"
echo ""

# Monitorear logs específicos
adb logcat | grep -E "(KeywordService|Emulator detection|Speech detected|keyword detection|MainActivity)" --color=always
