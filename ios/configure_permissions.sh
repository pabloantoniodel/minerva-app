#!/bin/bash

# Script para configurar permisos y verificar el estado de la aplicación iOS
# Minerva ERP

echo "🍎 Configurando permisos para Minerva ERP iOS"
echo "============================================="

# Verificar si estamos en macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Este script solo funciona en macOS"
    exit 1
fi

# Verificar que Xcode está instalado
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode no está instalado"
    echo "Instala Xcode desde la App Store"
    exit 1
fi

echo "📱 Verificando simuladores disponibles..."
xcrun simctl list devices available | grep "iPhone\|iPad"

echo ""
echo "🔧 Configurando permisos del simulador..."

# Obtener el ID del simulador booteado
BOOTED_SIMULATOR=$(xcrun simctl list devices | grep "Booted" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')

if [ -z "$BOOTED_SIMULATOR" ]; then
    echo "⚠️  No hay simulador ejecutándose. Iniciando simulador..."
    
    # Listar simuladores disponibles y usar el primero
    FIRST_SIMULATOR=$(xcrun simctl list devices available | grep "iPhone" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')
    
    if [ -z "$FIRST_SIMULATOR" ]; then
        echo "❌ No se encontraron simuladores disponibles"
        echo "Crea un simulador desde Xcode: Window → Devices and Simulators"
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

# Configurar permisos del simulador
echo "🔐 Configurando permisos..."

# Configurar permiso de micrófono
echo "• Configurando permiso de micrófono..."
xcrun simctl privacy "$BOOTED_SIMULATOR" grant microphone com.minerva.erp

# Configurar permiso de reconocimiento de voz
echo "• Configurando permiso de reconocimiento de voz..."
xcrun simctl privacy "$BOOTED_SIMULATOR" grant speech-recognition com.minerva.erp

# Configurar permiso de notificaciones
echo "• Configurando permiso de notificaciones..."
xcrun simctl privacy "$BOOTED_SIMULATOR" grant notifications com.minerva.erp

echo ""
echo "✅ Permisos configurados correctamente"

# Verificar permisos
echo "🔍 Verificando permisos configurados..."
echo "• Micrófono: $(xcrun simctl privacy "$BOOTED_SIMULATOR" get microphone com.minerva.erp)"
echo "• Reconocimiento de voz: $(xcrun simctl privacy "$BOOTED_SIMULATOR" get speech-recognition com.minerva.erp)"
echo "• Notificaciones: $(xcrun simctl privacy "$BOOTED_SIMULATOR" get notifications com.minerva.erp)"

echo ""
echo "📋 INSTRUCCIONES PARA USAR LA APP:"
echo "=================================="
echo "1. La app ya tiene todos los permisos necesarios"
echo "2. Abre la app Minerva ERP"
echo "3. Toca 'Iniciar Servicio'"
echo "4. El servicio escuchará continuamente en segundo plano"
echo "5. Di 'minerva' para activar la transcripción"
echo "6. La app se abrirá automáticamente y transcribirá hasta 2 segundos de silencio"

echo ""
echo "🔧 COMANDOS ÚTILES:"
echo "==================="
echo "• Ver logs de la app:"
echo "  xcrun simctl spawn $BOOTED_SIMULATOR log stream --predicate 'subsystem contains \"com.minerva.erp\"'"
echo ""
echo "• Lanzar la app:"
echo "  xcrun simctl launch $BOOTED_SIMULATOR com.minerva.erp"
echo ""
echo "• Desinstalar la app:"
echo "  xcrun simctl uninstall $BOOTED_SIMULATOR com.minerva.erp"

echo ""
echo "✅ Configuración completada"
