#!/bin/bash

echo "🏛️ Minerva ERP - Configuración de Android Studio"
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
    "build.gradle"
    "settings.gradle"
    "gradle.properties"
    "local.properties"
    "gradle/wrapper/gradle-wrapper.properties"
    "gradle/wrapper/gradle-wrapper.jar"
    "app/build.gradle"
    "app/src/main/AndroidManifest.xml"
    "app/src/main/java/com/minerva/erp/MainActivity.kt"
    "app/src/main/java/com/minerva/erp/service/KeywordService.kt"
    "app/src/main/res/values/strings.xml"
    "app/src/main/res/values/styles.xml"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - FALTANTE"
    fi
done

echo ""
echo "🔧 Configurando Android Studio..."

# Crear archivo de configuración para Android Studio
cat > .idea/modules.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectModuleManager">
    <modules>
      <module fileurl="file://$PROJECT_DIR$/app/app.iml" filepath="$PROJECT_DIR$/app/app.iml" />
    </modules>
  </component>
</project>
EOF

mkdir -p .idea
cat > .idea/gradle.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="GradleSettings">
    <option name="linkedExternalProjectsSettings">
      <GradleProjectSettings>
        <option name="testRunner" value="GRADLE" />
        <option name="distributionType" value="DEFAULT_WRAPPED" />
        <option name="externalProjectPath" value="$PROJECT_DIR$" />
        <option name="gradleJvm" value="17" />
        <option name="modules">
          <set>
            <option value="$PROJECT_DIR$" />
            <option value="$PROJECT_DIR$/app" />
          </set>
        </option>
      </GradleProjectSettings>
    </option>
  </component>
</project>
EOF

cat > .idea/misc.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectRootManager" version="2" languageLevel="JDK_17" default="true" project-jdk-name="17" project-jdk-type="JavaSDK">
    <output url="file://$PROJECT_DIR$/build/classes" />
  </component>
  <component name="ProjectType">
    <option name="id" value="Android" />
  </component>
</project>
EOF

cat > .idea/compiler.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="CompilerConfiguration">
    <bytecodeTargetLevel target="17" />
  </component>
</project>
EOF

echo "✅ Archivos de configuración de Android Studio creados"

echo ""
echo "🧹 Limpiando caché..."
./gradlew clean

echo ""
echo "📱 Verificando compilación..."
./gradlew assembleDebug

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 ¡Configuración completada exitosamente!"
    echo ""
    echo "📋 Instrucciones para Android Studio:"
    echo "====================================="
    echo "1. Abre Android Studio"
    echo "2. Selecciona 'Open an existing Android Studio project'"
    echo "3. Navega a: $(pwd)"
    echo "4. Selecciona el directorio 'android'"
    echo "5. Haz clic en 'OK'"
    echo "6. Espera a que Android Studio sincronice el proyecto"
    echo "7. Si aparece un mensaje sobre Gradle, haz clic en 'Sync Now'"
    echo ""
    echo "🎯 Funcionalidades disponibles:"
    echo "   • KeywordService: Servicio de escucha continua"
    echo "   • MainActivity: Actividad principal"
    echo "   • Reconocimiento de voz con Vosk"
    echo "   • Servicio en primer plano persistente"
    echo "   • Auto-arranque del dispositivo"
    echo ""
    echo "🏛️ Minerva ERP - Listo para Android Studio"
else
    echo ""
    echo "❌ Error en la compilación. Revisa los errores arriba."
    echo "   El proyecto puede necesitar ajustes adicionales."
fi
