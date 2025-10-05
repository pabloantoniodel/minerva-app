#!/bin/bash

# Script para abrir la app cuando se detecta "minerva"
echo "🎯 Monitoreando detección de keyword para abrir app..."

export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

PACKAGE_NAME="com.minerva.erp"

# Función para abrir la app
open_app() {
    echo "🚀 Abriendo app..."
    adb shell am start -n $PACKAGE_NAME/.MainActivity
    echo "✅ App abierta - $(date '+%H:%M:%S')"
}

echo "🔍 Monitoreando logs de KeywordService..."
echo "   (Presiona Ctrl+C para detener)"

# Monitorear logs y abrir app cuando detecte "minerva"
echo "🔍 Iniciando monitoreo de logs..."
adb logcat -s KeywordService | while IFS= read -r line; do
    echo "📝 Log: $line"
    if [[ $line == *"Keyword 'minerva' detected!"* ]]; then
        echo "🎯 Keyword 'minerva' detectado en log!"
        open_app
    elif [[ $line == *"Triggering keyword detection from audio"* ]]; then
        echo "🎯 Keyword detection triggered!"
        open_app
    fi
done
