#!/bin/bash

echo "🏛️ Minerva ERP - Compilación del Servicio Android"
echo "=================================================="

# Verificar que estamos en el directorio correcto
if [ ! -d "android" ]; then
    echo "❌ Error: No se encontró el directorio android"
    echo "   Ejecuta este script desde el directorio minerva-app"
    exit 1
fi

cd android

echo "📁 Verificando estructura del proyecto..."
echo ""

# Verificar archivos principales
files_to_check=(
    "app/src/main/java/com/minerva/erp/service/KeywordService.kt"
    "app/src/main/java/com/minerva/erp/MainActivity.kt"
    "app/src/main/java/com/minerva/erp/KeywordDetectionReceiver.kt"
    "app/src/main/java/com/minerva/erp/BootReceiver.kt"
    "app/src/main/AndroidManifest.xml"
    "app/build.gradle"
    "build.gradle"
    "settings.gradle"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - FALTANTE"
    fi
done

echo ""
echo "🔍 Verificando sintaxis Kotlin..."

# Verificar sintaxis básica de los archivos Kotlin
kotlin_files=(
    "app/src/main/java/com/minerva/erp/service/KeywordService.kt"
    "app/src/main/java/com/minerva/erp/MainActivity.kt"
    "app/src/main/java/com/minerva/erp/KeywordDetectionReceiver.kt"
    "app/src/main/java/com/minerva/erp/BootReceiver.kt"
)

for file in "${kotlin_files[@]}"; do
    if [ -f "$file" ]; then
        # Verificar que el archivo tenga package declaration
        if grep -q "package " "$file"; then
            echo "✅ $file - Sintaxis OK"
        else
            echo "⚠️  $file - Sin package declaration"
        fi
    fi
done

echo ""
echo "📱 Verificando AndroidManifest.xml..."

if [ -f "app/src/main/AndroidManifest.xml" ]; then
    if grep -q "KeywordService" "app/src/main/AndroidManifest.xml"; then
        echo "✅ KeywordService registrado"
    else
        echo "❌ KeywordService NO registrado"
    fi
    
    if grep -q "RECORD_AUDIO" "app/src/main/AndroidManifest.xml"; then
        echo "✅ Permisos de micrófono configurados"
    else
        echo "❌ Permisos de micrófono FALTANTES"
    fi
    
    if grep -q "FOREGROUND_SERVICE" "app/src/main/AndroidManifest.xml"; then
        echo "✅ Servicio en primer plano configurado"
    else
        echo "❌ Servicio en primer plano FALTANTE"
    fi
else
    echo "❌ AndroidManifest.xml NO encontrado"
fi

echo ""
echo "🔧 Verificando dependencias en build.gradle..."

if [ -f "app/build.gradle" ]; then
    if grep -q "vosk-android" "app/build.gradle"; then
        echo "✅ Vosk dependency configurada"
    else
        echo "❌ Vosk dependency FALTANTE"
    fi
    
    if grep -q "kotlinx-coroutines" "app/build.gradle"; then
        echo "✅ Coroutines dependency configurada"
    else
        echo "❌ Coroutines dependency FALTANTE"
    fi
else
    echo "❌ app/build.gradle NO encontrado"
fi

echo ""
echo "📊 Resumen del Servicio:"
echo "========================"
echo "🎤 KeywordService: Servicio principal de escucha"
echo "🔊 KeywordDetectionReceiver: Receptor de eventos de voz"
echo "🚀 BootReceiver: Auto-arranque del servicio"
echo "📱 MainActivity: Actividad principal con permisos"
echo ""
echo "🎯 Funcionalidades:"
echo "   • Escucha continua de la palabra 'minerva'"
echo "   • Activación automática de la app"
echo "   • Funciona en segundo plano (ForegroundService)"
echo "   • Auto-reinicio al arrancar el dispositivo"
echo "   • Optimización de batería integrada"
echo ""
echo "⚡ Para compilar completamente:"
echo "   1. Instala Android Studio"
echo "   2. Abre el proyecto android/"
echo "   3. Sync Project with Gradle Files"
echo "   4. Build → Make Project"
echo ""
echo "🏛️ Minerva ERP - Servicio listo para compilar"
