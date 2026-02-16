# 📱 Guia Completo: Build APK do Pesandinho

## ✅ Checklist Pré-Build

### 1. Nome do App ✅
**Status:** Já configurado como "pesandinho"
**Arquivo:** `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:label="Pesandinho"  <!-- Mude aqui se quiser -->
```

### 2. Package Name ✅
**Status:** Já configurado como `br.com.marlon.pensandinho`
**Arquivo:** `android/app/build.gradle.kts`
```kotlin
namespace = "br.com.marlon.pensandinho"
applicationId = "br.com.marlon.pensandinho"
```

### 3. Versão do App
**Arquivo:** `pubspec.yaml` (linha 4)
```yaml
version: 1.1.0+1
# Formato: <versão>+<build number>
# Exemplo: 1.0.0+1, 1.0.1+2, 2.0.0+10
```

Para atualizar:
- **1.0.0**: Versão exibida ao usuário
- **+1**: Build number (incremente a cada build)

---

## 🔨 Gerar APK

### Opção 1: APK para Testes (Recomendado)

```bash
# 1. Limpar build anterior
flutter clean
flutter pub get

# 2. Gerar APK
flutter build apk --release

# 3. Localização do APK
# C:\dev\codex-pilot\app\build\app\outputs\flutter-apk\app-release.apk
```

### Opção 2: APK Split (Menor tamanho)

```bash
flutter build apk --split-per-abi --release

# Gera 3 APKs otimizados:
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM) ← MAIS COMUM
# - app-x86_64-release.apk (Intel/AMD)
```

### Opção 3: AAB para Play Store

```bash
flutter build appbundle --release

# Localização:
# C:\dev\codex-pilot\app\build\app\outputs\bundle\release\app-release.aab
```

---

## ⚙️ Configurações Importantes

### Permissões (Já configuradas)
**Arquivo:** `android/app/src/main/AndroidManifest.xml`
- ✅ Internet (para futuras funcionalidades)
- ✅ Notificações (lembretes)
- ✅ Armazenamento (export/import CSV)

### Ícone do App
**Status:** Você tem SVG pronto em `assets/icon/app_icon.svg`

Para aplicar:
```bash
# Opção 1: Usar script Python
pip install cairosvg pillow
python tools/generate_icons.py

# Opção 2: Usar flutter_launcher_icons
flutter pub run flutter_launcher_icons
```

---

## 🔐 Assinatura (Para Play Store)

### 1. Criar Keystore

```bash
keytool -genkey -v -keystore C:\dev\codex-pilot\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Responda:
# - Senha: [ANOTE BEM!]
# - Nome: Marlon
# - Organização: [Seu nome/empresa]
# - Cidade/Estado/País: Canela/RS/BR
```

### 2. Configurar Assinatura

**Arquivo:** `android/key.properties` (CRIAR NOVO)
```properties
storePassword=<senha_que_você_criou>
keyPassword=<senha_que_você_criou>
keyAlias=upload
storeFile=C:/dev/codex-pilot/upload-keystore.jks
```

**⚠️ IMPORTANTE:** Adicione ao `.gitignore`:
```
# Keystore
*.jks
**/android/key.properties
```

### 3. Atualizar build.gradle.kts

**Arquivo:** `android/app/build.gradle.kts`

Adicione ANTES de `android {`:
```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Substitua a seção `buildTypes`:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"]
        keyPassword = keystoreProperties["keyPassword"]
        storeFile = file(keystoreProperties["storeFile"])
        storePassword = keystoreProperties["storePassword"]
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

---

## 📋 Checklist Final

Antes de buildar:
- [ ] Nome do app correto
- [ ] Package name único
- [ ] Versão atualizada em pubspec.yaml
- [ ] Ícone aplicado
- [ ] Permissões corretas
- [ ] (Opcional) Keystore configurado

---

## 🚀 Comandos Rápidos

```bash
# Build rápido para testar
flutter build apk --release

# Build otimizado (recomendado)
flutter build apk --split-per-abi --release

# Build para Play Store
flutter build appbundle --release

# Instalar direto no celular conectado
flutter install
```

---

## 📍 Localização dos Arquivos

- **APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **AAB:** `build/app/outputs/bundle/release/app-release.aab`
- **Ícones:** `android/app/src/main/res/mipmap-*/ic_launcher.png`

---

## ⚠️ Troubleshooting

### Erro: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Erro: "SDK not found"
```bash
# Verificar se ANDROID_HOME está configurado
echo $ANDROID_HOME  # Linux/Mac
echo %ANDROID_HOME%  # Windows

# Configurar se necessário
export ANDROID_HOME=/caminho/para/android/sdk
```

### APK muito grande
```bash
# Use split APKs
flutter build apk --split-per-abi --release

# Ou habilite ProGuard (minificação)
# Em android/app/build.gradle.kts:
buildTypes {
    release {
        minifyEnabled = true
        shrinkResources = true
        proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
    }
}
```

---

## 🎉 Pronto!

Seu APK estará em:
`C:\dev\codex-pilot\app\build\app\outputs\flutter-apk\app-release.apk`

Transfira para o celular e instale! 📱
