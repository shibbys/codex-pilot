# 🎨 Gerar Novo Ícone do App

## 📱 Ícone Criado
Um ícone moderno foi criado com:
- Gradiente roxo moderno (667eea → 764ba2)
- Balança estilizada
- Indicador de peso (seta amarela)
- Linha de tendência sutil

## 🚀 Como Aplicar

### Opção 1: Gerar Automaticamente (Recomendado)

```bash
# 1. Instalar dependências Python
pip install cairosvg pillow

# 2. Gerar ícones em todas as resoluções
python tools/generate_icons.py

# 3. Limpar e reconstruir o app
flutter clean
flutter pub get
flutter run
```

### Opção 2: Usar flutter_launcher_icons (Mais Simples)

```bash
# 1. Adicionar ao pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#667eea"
  adaptive_icon_foreground: "assets/icon/app_icon.png"

# 2. Executar
flutter pub get
flutter pub run flutter_launcher_icons

# 3. Reinstalar
flutter clean
flutter run
```

### Opção 3: Manual

Converta o SVG (`assets/icon/app_icon.svg`) para PNG em:
- 48x48 → mipmap-mdpi/ic_launcher.png
- 72x72 → mipmap-hdpi/ic_launcher.png  
- 96x96 → mipmap-xhdpi/ic_launcher.png
- 144x144 → mipmap-xxhdpi/ic_launcher.png
- 192x192 → mipmap-xxxhdpi/ic_launcher.png

## 📂 Arquivos Criados
- `assets/icon/app_icon.svg` - Ícone vetorial
- `tools/generate_icons.py` - Script gerador
- `ICON_GENERATION.md` - Este guia

## ✨ Resultado
Após aplicar, o app terá um ícone profissional e moderno que representa:
- 📊 Tracking de peso (balança)
- 📈 Progresso/tendência
- 🎨 Design moderno e clean
