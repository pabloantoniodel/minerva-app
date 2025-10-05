#!/bin/bash

echo "🏛️ Minerva ERP - Ejecutar App en Emulador"
echo "==========================================="

# Configurar PATH para Android SDK
export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin

echo "📱 Verificando emuladores..."
adb devices

echo ""
echo "🎯 Iniciando la aplicación Minerva ERP..."
adb shell am start -n com.minerva.erp/.MainActivity

echo ""
echo "✅ Aplicación iniciada. Verifica el emulador."
echo ""
echo "🔍 Para ver logs en tiempo real, ejecuta:"
echo "   adb logcat | grep -E '(Minerva|KeywordService|MainActivity)'"
echo ""
echo "🎤 Para probar el reconocimiento de voz:"
echo "   1. Asegúrate de que el emulador tenga micrófono habilitado"
echo "   2. Ve a Settings > Apps > Minerva ERP > Permissions"
echo "   3. Concede permiso de micrófono"
echo "   4. Di 'minerva' cerca del micrófono"
echo ""
echo "🏛️ Minerva ERP - Listo para usar"
