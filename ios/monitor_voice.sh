#!/bin/bash

# Script para monitorear logs de la aplicación iOS Minerva ERP
# Similar al script de Android pero para iOS

echo "🍎 Monitoreando aplicación Minerva ERP iOS"
echo "=========================================="

# Verificar que estamos en macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Este script solo funciona en macOS"
    exit 1
fi

# Verificar que Xcode está instalado
if ! command -v xcrun &> /dev/null; then
    echo "❌ Error: Xcode no está instalado"
    exit 1
fi

# Obtener el ID del simulador booteado
BOOTED_SIMULATOR=$(xcrun simctl list devices | grep "Booted" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')

if [ -z "$BOOTED_SIMULATOR" ]; then
    echo "⚠️  No hay simulador ejecutándose"
    echo "Iniciando simulador..."
    
    # Listar simuladores disponibles y usar el primero
    FIRST_SIMULATOR=$(xcrun simctl list devices available | grep "iPhone" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')
    
    if [ -z "$FIRST_SIMULATOR" ]; then
        echo "❌ No se encontraron simuladores disponibles"
        exit 1
    fi
    
    echo "🚀 Iniciando simulador: $FIRST_SIMULATOR"
    xcrun simctl boot "$FIRST_SIMULATOR"
    BOOTED_SIMULATOR="$FIRST_SIMULATOR"
    
    # Esperar a que el simulador se inicie
    sleep 5
fi

echo "✅ Simulador activo: $BOOTED_SIMULATOR"

# Verificar si la app está instalada
echo "📲 Verificando si Minerva ERP está instalada..."
APP_INSTALLED=$(xcrun simctl listapps "$BOOTED_SIMULATOR" | grep -i "minerva")

if [ -z "$APP_INSTALLED" ]; then
    echo "⚠️  La aplicación no está instalada"
    echo "Ejecuta primero: ./build_and_run.sh"
    exit 1
fi

echo "✅ Aplicación encontrada"

# Lanzar la aplicación si no está ejecutándose
echo "🚀 Lanzando aplicación Minerva ERP..."
xcrun simctl launch "$BOOTED_SIMULATOR" com.minerva.erp

echo ""
echo "📋 INSTRUCCIONES:"
echo "=================="
echo "1. La app se ha lanzado automáticamente"
echo "2. Acepta los permisos de micrófono y reconocimiento de voz"
echo "3. Toca 'Iniciar Servicio' en la app"
echo "4. El servicio escuchará continuamente en segundo plano"
echo "5. Di 'minerva' para activar la transcripción"
echo ""
echo "🔍 Monitoreando logs de la aplicación..."
echo "Presiona Ctrl+C para detener el monitoreo"
echo ""

# Función para mostrar logs en tiempo real
show_logs() {
    echo "📊 Iniciando monitoreo de logs..."
    
    # Filtrar logs relacionados con la aplicación
    xcrun simctl spawn "$BOOTED_SIMULATOR" log stream \
        --predicate 'subsystem contains "com.minerva.erp" OR process contains "MinervaERP"' \
        --style compact
}

# Función para limpiar al salir
cleanup() {
    echo ""
    echo "🛑 Deteniendo monitoreo..."
    exit 0
}

# Configurar trap para limpieza
trap cleanup SIGINT SIGTERM

# Mostrar logs
show_logs
