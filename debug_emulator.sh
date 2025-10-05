#!/bin/bash

echo "🏛️ Minerva ERP - Debug del Emulador Android"
echo "============================================="

# Verificar que el emulador esté ejecutándose
echo "📱 Verificando emuladores activos..."
adb devices

echo ""
echo "🔍 Verificando instalación de la app..."
adb shell pm list packages | grep minerva

echo ""
echo "🎯 Iniciando la aplicación Minerva ERP..."
adb shell am start -n com.minerva.erp/.MainActivity

echo ""
echo "📊 Verificando logs de la aplicación..."
echo "   Presiona Ctrl+C para detener el monitoreo de logs"
echo ""

# Monitorear logs de la aplicación
adb logcat | grep -E "(Minerva|KeywordService|MainActivity)" --color=always

echo ""
echo "🏛️ Debug completado"
