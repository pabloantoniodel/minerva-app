#!/bin/bash

echo "🎤 Minerva ERP - Test de Servicio Independiente"
echo "==============================================="

export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

echo "📱 Verificando dispositivos..."
adb devices

echo ""
echo "🔧 Paso 1: Instalar la app actualizada"
cd android
./gradlew clean assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk

echo ""
echo "🚀 Paso 2: Iniciar la app para activar el servicio"
adb shell am start -n com.minerva.erp/.MainActivity

echo ""
echo "⏳ Esperando 3 segundos para que se active el servicio..."
sleep 3

echo ""
echo "🛑 Paso 3: Cerrar completamente la app"
adb shell am force-stop com.minerva.erp

echo ""
echo "✅ Paso 4: Verificar que el servicio sigue funcionando"
echo "   El servicio debería seguir ejecutándose en segundo plano"
echo "   Verifica que la notificación 'Minerva ERP - Always Listening' esté visible"

echo ""
echo "🎯 Paso 5: Probar detección de voz"
echo ""
echo "   Para dispositivo real:"
echo "   • Di 'minerva' cerca del micrófono"
echo "   • La app debería abrirse automáticamente"
echo ""
echo "   Para emulador:"
echo "   • Espera 10 segundos"
echo "   • La app debería abrirse automáticamente"

echo ""
echo "🔍 Paso 6: Monitorear logs"
echo "   Ejecuta: ./monitor_voice.sh"
echo "   para ver los logs en tiempo real"

echo ""
echo "📊 Verificación final:"
echo "   1. ¿Ves la notificación persistente?"
echo "   2. ¿Se abre la app al detectar voz/simulación?"
echo "   3. ¿El servicio funciona con la app cerrada?"

echo ""
echo "🏛️ Minerva ERP - Test completado"
