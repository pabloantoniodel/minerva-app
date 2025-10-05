#!/bin/bash

# Script para probar la apertura de la app
echo "🧪 Probando apertura de app..."

export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

PACKAGE_NAME="com.minerva.erp"

echo "📱 Abriendo app manualmente..."
adb shell am start -n $PACKAGE_NAME/.MainActivity

echo "✅ App abierta"
echo ""
echo "🎯 Ahora prueba diciendo 'minerva' para ver si funciona la transcripción"
