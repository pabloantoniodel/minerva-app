#!/bin/bash

# Script para compilar y ejecutar la aplicación iOS Minerva ERP
# Requiere Xcode y un simulador iOS o dispositivo conectado

echo "🍎 Compilando aplicación iOS Minerva ERP"
echo "========================================"

# Verificar que estamos en el directorio correcto
if [ ! -d "MinervaERP" ]; then
    echo "❌ Error: No se encontró el directorio MinervaERP"
    echo "Ejecuta este script desde el directorio ios/"
    exit 1
fi

# Verificar que Xcode está instalado
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode no está instalado o xcodebuild no está en el PATH"
    echo "Instala Xcode desde la App Store"
    exit 1
fi

# Listar simuladores disponibles
echo "📱 Simuladores iOS disponibles:"
xcrun simctl list devices available | grep "iPhone\|iPad"

echo ""
echo "🔧 Compilando proyecto..."

# Compilar el proyecto
xcodebuild -project MinervaERP/MinervaERP.xcodeproj \
           -scheme MinervaERP \
           -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
           build

if [ $? -eq 0 ]; then
    echo "✅ Compilación exitosa"
    
    # Instalar en el simulador
    echo "📲 Instalando en el simulador..."
    xcodebuild -project MinervaERP/MinervaERP.xcodeproj \
               -scheme MinervaERP \
               -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
               -derivedDataPath ./build \
               build-for-testing
    
    # Abrir el simulador si no está abierto
    open -a Simulator
    
    # Instalar la app en el simulador
    xcrun simctl install booted ./build/Build/Products/Debug-iphonesimulator/MinervaERP.app
    
    if [ $? -eq 0 ]; then
        echo "✅ Aplicación instalada en el simulador"
        
        # Lanzar la aplicación
        echo "🚀 Lanzando aplicación..."
        xcrun simctl launch booted com.minerva.erp
        
        echo ""
        echo "📋 INSTRUCCIONES:"
        echo "=================="
        echo "1. La app solicitará permisos de micrófono - ACEPTAR"
        echo "2. La app solicitará permisos de reconocimiento de voz - ACEPTAR"
        echo "3. Toca 'Iniciar Servicio' para comenzar"
        echo "4. La app detectará la palabra 'minerva' automáticamente"
        echo "5. Después de detectar 'minerva', transcribirá hasta 2 segundos de silencio"
        
    else
        echo "❌ Error instalando la aplicación"
    fi
else
    echo "❌ Error en la compilación"
    exit 1
fi
