#!/usr/bin/env python3
"""
Script para extrair LPA String de QR Code de eSIM

Uso:
    python extrair_lpa_qrcode.py qrcode.png
    
Instalar dependências:
    pip install opencv-python pyzbar pillow
"""

import sys
from PIL import Image
from pyzbar.pyzbar import decode

def extrair_lpa_de_qrcode(caminho_imagem):
    """Extrai LPA String de uma imagem de QR Code"""
    try:
        # Abre a imagem
        img = Image.open(caminho_imagem)
        
        # Decodifica o QR Code
        resultados = decode(img)
        
        if not resultados:
            print("❌ Nenhum QR Code encontrado na imagem")
            return None
        
        # Pega o primeiro resultado
        qr_data = resultados[0].data.decode('utf-8')
        
        # Verifica se é uma LPA String válida
        if qr_data.startswith('LPA:1$'):
            print("✅ LPA String encontrada!")
            print(f"\n📋 LPA String:\n{qr_data}\n")
            
            # Extrai informações
            partes = qr_data.split('$')
            if len(partes) >= 3:
                print("📊 Informações:")
                print(f"   Versão: {partes[0]}")
                print(f"   Servidor: {partes[1]}")
                print(f"   Código: {partes[2]}")
            
            return qr_data
        else:
            print(f"⚠️ QR Code encontrado, mas não é uma LPA String:")
            print(f"   Conteúdo: {qr_data}")
            return None
            
    except FileNotFoundError:
        print(f"❌ Arquivo não encontrado: {caminho_imagem}")
        return None
    except Exception as e:
        print(f"❌ Erro ao processar imagem: {e}")
        return None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python extrair_lpa_qrcode.py <caminho_da_imagem>")
        print("\nExemplo:")
        print("  python extrair_lpa_qrcode.py qrcode_esim.png")
        sys.exit(1)
    
    caminho = sys.argv[1]
    lpa = extrair_lpa_de_qrcode(caminho)
    
    if lpa:
        print("\n💡 Próximos passos:")
        print("1. Copie a LPA String acima")
        print("2. Cole no seu código de teste")
        print("3. Execute o app e teste a instalação!")
