#!/usr/bin/env python3
"""
Script para gerar ícones Android em todas as resoluções a partir do SVG
Requer: pip install cairosvg pillow
"""

from pathlib import Path
import cairosvg
from PIL import Image
import io

# Resoluções necessárias para Android
SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

def generate_icons():
    # Paths
    app_dir = Path(__file__).parent.parent
    svg_path = app_dir / 'assets' / 'icon' / 'app_icon.svg'
    res_dir = app_dir / 'android' / 'app' / 'src' / 'main' / 'res'
    
    if not svg_path.exists():
        print(f"❌ SVG não encontrado: {svg_path}")
        return
    
    print(f"📱 Gerando ícones a partir de {svg_path.name}...")
    
    # Ler SVG
    with open(svg_path, 'rb') as f:
        svg_data = f.read()
    
    # Gerar cada resolução
    for folder, size in SIZES.items():
        output_dir = res_dir / folder
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / 'ic_launcher.png'
        
        # Converter SVG para PNG
        png_data = cairosvg.svg2png(
            bytestring=svg_data,
            output_width=size,
            output_height=size
        )
        
        # Salvar
        with open(output_path, 'wb') as f:
            f.write(png_data)
        
        print(f"  ✅ {folder}/ic_launcher.png ({size}x{size})")
    
    print("\n🎉 Ícones gerados com sucesso!")
    print("\n📋 Próximos passos:")
    print("  1. Execute: flutter clean")
    print("  2. Execute: flutter pub get")
    print("  3. Reinstale o app")

if __name__ == '__main__':
    try:
        generate_icons()
    except ImportError as e:
        print("❌ Dependências faltando!")
        print("   Execute: pip install cairosvg pillow")
        print(f"   Erro: {e}")
    except Exception as e:
        print(f"❌ Erro: {e}")
