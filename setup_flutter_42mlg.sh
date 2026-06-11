#!/bin/bash

# ==========================================
# VARIABLES GLOBALES
# ==========================================
BASE_DIR="$HOME/goinfre/flutter_dev"
FLUTTER_DIR="$BASE_DIR/flutter"
ANDROID_HOME="$BASE_DIR/Android/Sdk"
TOOLS_DIR="$BASE_DIR/tools"

# ==========================================
# INTERFAZ GRÁFICA Y MENÚ
# ==========================================
clear
echo "================================================================"
echo "   🚀  SETUP FLUTTER ENVIRONMENT - 42 MÁLAGA  🚀"
echo "================================================================"
echo "   👤 Autor: pvilchez"
echo "   📧 Correo: pvilchez@student.42malaga.com"
echo "   🎯 Objetivo: Instalar el entorno en disco local (goinfre) "
echo "      para compilar a máxima velocidad y evitar bloqueos."
echo "================================================================"
echo ""
echo "   1) 📥 Instalar y configurar el entorno completo"
echo "   2) 🧹 Limpiar todo (Empezar de cero / Liberar espacio)"
echo "   3) ❌ Salir"
echo ""
read -p "👉 Elige una opción (1, 2 o 3): " OPCION

echo ""

case $OPCION in
    1)
        # ==========================================
        # OPCIÓN 1: INSTALACIÓN
        # ==========================================
        echo "🚀 Iniciando configuración de Flutter en disco rápido (goinfre)..."

        # 1. Preparar directorios y enlaces
        mkdir -p "$ANDROID_HOME" "$BASE_DIR/.gradle" "$BASE_DIR/.android" "$BASE_DIR/.pub-cache"

        if [ ! -L ~/.gradle ]; then
            rm -rf ~/.gradle
            ln -s "$BASE_DIR/.gradle" ~/.gradle
        fi

        if [ ! -L ~/.android ]; then
            rm -rf ~/.android
            ln -s "$BASE_DIR/.android" ~/.android
        fi

        # 2. Descargar Flutter
        if [ ! -d "$FLUTTER_DIR" ]; then
            echo "⬇️ Descargando SDK de Flutter..."
            git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR" > /dev/null 2>&1
        else
            echo "✅ Flutter ya está instalado."
        fi

        # 3. Herramientas de Linux (Ninja)
        if [ ! -d "$TOOLS_DIR/ninja_bin" ]; then
            echo "⬇️ Instalando herramientas para compilación Linux (Ninja)..."
            mkdir -p "$TOOLS_DIR"
            cd "$TOOLS_DIR" || exit
            wget -q https://github.com/ninja-build/ninja/releases/latest/download/ninja-linux.zip
            unzip -q ninja-linux.zip -d ninja_bin
            rm ninja-linux.zip
            cd - > /dev/null || exit
        else
            echo "✅ Herramientas de Linux configuradas."
        fi

        # 4. Bypass de eglinfo
        if [ ! -f "$TOOLS_DIR/fake_bin/eglinfo" ]; then
            mkdir -p "$TOOLS_DIR/fake_bin"
            echo '#!/bin/bash' > "$TOOLS_DIR/fake_bin/eglinfo"
            echo 'echo "EGL API version: 1.5"' >> "$TOOLS_DIR/fake_bin/eglinfo"
            echo 'echo "EGL client APIs: OpenGL"' >> "$TOOLS_DIR/fake_bin/eglinfo"
            chmod +x "$TOOLS_DIR/fake_bin/eglinfo"
        fi

        # 5. Cargar entorno temporal
        export PUB_CACHE="$BASE_DIR/.pub-cache"
        export ANDROID_HOME="$ANDROID_HOME"
        export PATH="$FLUTTER_DIR/bin:$TOOLS_DIR/ninja_bin:$TOOLS_DIR/fake_bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

        flutter config --android-sdk "$ANDROID_HOME" > /dev/null 2>&1

        # 6. Asistente interactivo Android Studio
        if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
            echo ""
            echo "------------------------------------------------------"
            echo "⏸️  ACCIÓN MANUAL REQUERIDA (Herramientas de Android)"
            echo "------------------------------------------------------"
            echo "1. Abre Android Studio."
            echo "2. Cierra carpeta de proyecto si tienes alguno abierto."
            echo "3. Si te pregunta por la ruta del SDK, indicar:"
            echo "   $ANDROID_HOME"
            echo "4. Ve al SDK Manager (... > SDK Manager)."
            echo "5. Ve a la pestaña 'SDK Tools'."
            echo "6. Marca la casilla 'Android SDK Command-line Tools (latest)'."
            echo "7. Dale a Apply, acepta y espera a que termine."
            echo "------------------------------------------------------"
            echo "👉 Pulsa la tecla ENTER en esta ventana cuando hayas terminado..."
            read -r
        fi

        # 7. Licencias
        echo "📝 Aceptando licencias de Android..."
        yes y | flutter doctor --android-licenses > /dev/null 2>&1 || flutter doctor --android-licenses

        # 8. Persistencia en Zshrc
        if ! grep -q "FLUTTER_GOINFRE_MARKER" ~/.zshrc; then
            echo "🔗 Vinculando herramientas a tu terminal..."
            echo 'export PUB_CACHE="$HOME/goinfre/flutter_dev/.pub-cache" # FLUTTER_GOINFRE_MARKER' >> ~/.zshrc
            echo 'export ANDROID_HOME="$HOME/goinfre/flutter_dev/Android/Sdk" # FLUTTER_GOINFRE_MARKER' >> ~/.zshrc
            echo 'export PATH="$HOME/goinfre/flutter_dev/flutter/bin:$HOME/goinfre/flutter_dev/tools/ninja_bin:$HOME/goinfre/flutter_dev/tools/fake_bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH" # FLUTTER_GOINFRE_MARKER' >> ~/.zshrc
        fi

        # 9. Diagnóstico final
        echo ""
        echo "🩺 Entorno configurado. Ejecutando diagnóstico final..."
        flutter doctor

        echo ""
        echo "======================================================"
        echo "🎉 ¡TODO LISTO! Tu entorno vuela en el goinfre."
        echo "======================================================"
        echo "⚠️  PASOS FINALES IMPORTANTES:"
        echo "1. Cierra esta terminal y abre una nueva para recargar los comandos,"
        echo "   o ejecuta en esta misma: source ~/.zshrc"
        echo "2. Abre tu IDE (Android Studio, VS Code, ...)."
        echo "3. Ve a Extensiones e instala:"
        echo "   - Flutter (oficial)"
        echo "   - Dart (oficial)"
        echo "   (Si ya tenías el IDE abierto, reinícialo para que las detecte)."
        echo ""
        echo "4. Los proyectos de Flutter pueden ocupar varios gigas. Créalos en sgoinfre, pendrive, ..."
        echo "======================================================"
        ;;
    
    2)
        # ==========================================
        # OPCIÓN 2: LIMPIEZA
        # ==========================================
        echo "⚠️  ADVERTENCIA: Vas a borrar todo el entorno Flutter del goinfre. (Tus proyectos no, tranqui)."
        read -p "¿Estás seguro? (s/n): " CONFIRMAR
        if [[ "$CONFIRMAR" == "s" || "$CONFIRMAR" == "S" ]]; then
            echo "🧹 Iniciando protocolo de limpieza profunda..."
            rm -rf ~/goinfre/flutter_dev
            rm -rf ~/.gradle ~/.android
            
            sed -i '' '/FLUTTER_GOINFRE_MARKER/d' ~/.zshrc 2>/dev/null || sed -i '/FLUTTER_GOINFRE_MARKER/d' ~/.zshrc
            
            echo "✅ Entorno completamente borrado. Tu sistema está limpio."
        else
            echo "❌ Operación cancelada."
        fi
        ;;
    
    3)
        # ==========================================
        # OPCIÓN 3: SALIR
        # ==========================================
        echo "👋 ¡Hasta pronto!"
        exit 0
        ;;
    
    *)
        echo "❌ Opción no válida. Ejecuta el script de nuevo."
        exit 1
        ;;
esac