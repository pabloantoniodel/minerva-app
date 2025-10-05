#!/bin/bash

echo "🎤 Minerva ERP - Arreglar Permisos de Micrófono"
echo "==============================================="

export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

echo "📱 Compilando app con mejoras de permisos..."
cd android
./gradlew clean assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk

echo ""
echo "🔧 Otorgando permisos de micrófono..."
adb shell pm grant com.minerva.erp android.permission.RECORD_AUDIO

echo ""
echo "🔧 Otorgando permisos de notificaciones..."
adb shell pm grant com.minerva.erp android.permission.POST_NOTIFICATIONS

echo ""
echo "🔧 Otorgando permisos de servicio en primer plano..."
adb shell pm grant com.minerva.erp android.permission.FOREGROUND_SERVICE

echo ""
echo "✅ Verificando permisos otorgados..."
adb shell dumpsys package com.minerva.erp | grep -A 20 "requested permissions:"

echo ""
echo "🚀 Iniciando la app..."
adb shell am start -n com.minerva.erp/.MainActivity

echo ""
echo "⏳ Esperando 3 segundos para que se active el servicio..."
sleep 3

echo ""
echo "🔍 Verificando estado del servicio..."
adb shell dumpsys activity services | grep -A 5 -B 5 "KeywordService"

echo ""
echo "📋 Instrucciones:"
echo "   1. La app debería mostrar: 'Servicio de escucha iniciado - Funciona independientemente'"
echo "   2. Deberías ver la notificación: 'Minerva ERP - Always Listening'"
echo "   3. Para probar: Di 'minerva' cerca del micrófono"
echo "   4. Para monitorear: ./monitor_voice.sh"

echo ""
echo "🎯 Si aún no funciona:"
echo "   • Ve a Configuración > Apps > Minerva ERP > Permisos"
echo "   • Asegúrate de que 'Micrófono' esté habilitado"
echo "   • Reinicia la app"

echo ""
echo "🏛️ Minerva ERP - Permisos configurados"
