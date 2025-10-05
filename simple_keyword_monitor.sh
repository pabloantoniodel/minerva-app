#!/bin/bash

# Script simple para monitorear y abrir app cuando detecte keyword
echo "🎯 Monitor simple de keyword..."

export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

PACKAGE_NAME="com.minerva.erp"

# Función para abrir la app
open_app() {
    echo "🚀 Abriendo app..."
    adb shell am start -n $PACKAGE_NAME/.MainActivity
    echo "✅ App abierta - $(date '+%H:%M:%S')"
}

echo "🔍 Monitoreando logs..."
echo "   (Presiona Ctrl+C para detener)"

# Limpiar logs anteriores
adb logcat -c

# Monitorear logs con filtro más amplio
adb logcat | grep -E "(KeywordService|minerva)" | while read line; do
    echo "📝 $line"
    
    # Detectar cuando se activa la detección de keyword
    if [[ $line == *"Triggering keyword detection"* ]] || 
       [[ $line == *"Keyword 'minerva' detected"* ]] ||
       [[ $line == *"minerva detected"* ]]; then
        echo "🎯 ¡Keyword detectado! Abriendo app..."
        open_app
        sleep 2  # Esperar un poco antes de continuar
    fi
done
