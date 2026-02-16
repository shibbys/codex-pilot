# 🎨 Solução Mais Fácil - Gerar Ícone do App

## Método 1: Flutter Launcher Icons (Recomendado)

### 1. Converter SVG para PNG primeiro

Use um conversor online:
- https://convertio.co/svg-png/
- Upload: `assets/icon/app_icon.svg`
- Download: Salve como `assets/icon/app_icon.png` (512x512 ou maior)

### 2. Adicionar ao pubspec.yaml

No arquivo `pubspec.yaml`, já existe a configuração:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: true
  image_path: assets/icon.png  # MUDE para: assets/icon/app_icon.png
  adaptive_icon_background: "#10b981"  # Verde do tema
  adaptive_icon_foreground: assets/icon/app_icon.png
```

### 3. Executar

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

---

## Método 2: Script Python Simplificado

```bash
python tools/generate_icons_simple.py
```

Cria ícone programaticamente (não precisa de Cairo).

---

## Método 3: Ferramenta Online (Mais Rápido)

1. Acesse: https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
2. Upload SVG: `assets/icon/app_icon.svg`
3. Customize cores se quiser
4. Download ZIP
5. Extraia para: `android/app/src/main/res/`

---

## Após Gerar os Ícones

```bash
flutter clean
flutter pub get
flutter run
```

O novo ícone aparecerá no app! 🎉
