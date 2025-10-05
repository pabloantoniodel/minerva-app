#!/bin/bash

# Script para mantener el servicio vivo independientemente de la app
echo "🔄 Configurando servicio persistente..."

export ANDROID_HOME=/Users/pabloantoniodelpinorubio/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

PACKAGE_NAME="com.minerva.erp"
SERVICE_NAME="com.minerva.erp.service.KeywordService"

echo "🚀 Iniciando servicio persistente..."

# Función para iniciar el servicio
start_service() {
    echo "📱 Iniciando servicio..."
    adb shell am startservice -n $PACKAGE_NAME/$SERVICE_NAME --ez independent_mode true --ez auto_restart true
    sleep 2
}

# Función para verificar si el servicio está corriendo
check_service() {
    local result=$(adb shell dumpsys activity services $PACKAGE_NAME | grep "KeywordService")
    if [ -n "$result" ]; then
        return 0  # Servicio está corriendo
    else
        return 1  # Servicio no está corriendo
    fi
}

# Iniciar el servicio inicialmente
start_service

# Loop infinito para mantener el servicio activo
echo "🔄 Iniciando monitor de servicio..."
echo "   (Presiona Ctrl+C para detener)"

while true; do
    if check_service; then
        echo "✅ Servicio activo - $(date '+%H:%M:%S')"
    else
        echo "❌ Servicio detenido - Reiniciando..."
        start_service
        if check_service; then
            echo "✅ Servicio reiniciado exitosamente"
        else
            echo "⚠️ Error al reiniciar servicio"
        fi
    fi
    sleep 10  # Verificar cada 10 segundos
done
