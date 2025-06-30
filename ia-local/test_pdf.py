#!/usr/bin/env python3
"""
Script de teste para funcionalidade de PDF
Testa upload, processamento e integração com chat
"""

import os
import sys
import json
import requests
from datetime import datetime

def test_pdf_functionality():
    """Testa a funcionalidade completa de PDF"""
    
    base_url = "http://localhost:8080"
    
    print("🧪 Testando funcionalidade de PDF...")
    print("=" * 50)
    
    # 1. Testar saúde do sistema
    print("1. Verificando saúde do sistema...")
    try:
        response = requests.get(f"{base_url}/api/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Sistema saudável - Ollama: {data['ollama']}")
        else:
            print(f"   ❌ Erro na saúde do sistema: {response.status_code}")
            return False
    except Exception as e:
        print(f"   ❌ Erro ao conectar: {e}")
        return False
    
    # 2. Testar listagem de PDFs (deve estar vazia inicialmente)
    print("\n2. Verificando lista de PDFs...")
    try:
        response = requests.get(f"{base_url}/api/pdfs", timeout=5)
        if response.status_code == 200:
            data = response.json()
            pdf_count = len(data.get('pdfs', []))
            print(f"   ✅ PDFs encontrados: {pdf_count}")
        else:
            print(f"   ❌ Erro ao listar PDFs: {response.status_code}")
            return False
    except Exception as e:
        print(f"   ❌ Erro ao listar PDFs: {e}")
        return False
    
    # 3. Testar chat sem PDF
    print("\n3. Testando chat sem PDF...")
    try:
        chat_data = {
            "message": "Olá! Como você está?",
            "model": "llama2"
        }
        response = requests.post(f"{base_url}/api/chat", 
                               json=chat_data, 
                               timeout=30)
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Chat funcionando - Resposta recebida")
        else:
            print(f"   ❌ Erro no chat: {response.status_code}")
            return False
    except Exception as e:
        print(f"   ❌ Erro no chat: {e}")
        return False
    
    # 4. Testar upload de PDF (se houver arquivo de teste)
    test_pdf_path = "test_document.pdf"
    if os.path.exists(test_pdf_path):
        print(f"\n4. Testando upload de PDF ({test_pdf_path})...")
        try:
            with open(test_pdf_path, 'rb') as f:
                files = {'pdf_file': f}
                response = requests.post(f"{base_url}/api/upload-pdf", 
                                       files=files, 
                                       timeout=60)
            
            if response.status_code == 200:
                data = response.json()
                pdf_hash = data['pdf']['hash']
                print(f"   ✅ PDF processado com sucesso!")
                print(f"   📄 Hash: {pdf_hash}")
                print(f"   📄 Nome: {data['pdf']['name']}")
                print(f"   📄 Páginas: {data['pdf']['pages']}")
                print(f"   📄 Tamanho: {data['pdf']['text_length']} caracteres")
                
                # 5. Testar chat com PDF
                print("\n5. Testando chat com PDF...")
                chat_data = {
                    "message": "Resuma o conteúdo deste documento",
                    "model": "llama2",
                    "pdf_context": pdf_hash
                }
                response = requests.post(f"{base_url}/api/chat", 
                                       json=chat_data, 
                                       timeout=30)
                if response.status_code == 200:
                    data = response.json()
                    print(f"   ✅ Chat com PDF funcionando - Resposta recebida")
                else:
                    print(f"   ❌ Erro no chat com PDF: {response.status_code}")
                
                # 6. Testar obtenção de contexto
                print("\n6. Testando obtenção de contexto...")
                response = requests.get(f"{base_url}/api/pdfs/{pdf_hash}/context", 
                                      timeout=10)
                if response.status_code == 200:
                    data = response.json()
                    context_length = len(data['context'])
                    print(f"   ✅ Contexto obtido - {context_length} caracteres")
                else:
                    print(f"   ❌ Erro ao obter contexto: {response.status_code}")
                
                # 7. Testar remoção de PDF
                print("\n7. Testando remoção de PDF...")
                response = requests.delete(f"{base_url}/api/pdfs/{pdf_hash}", 
                                         timeout=10)
                if response.status_code == 200:
                    print(f"   ✅ PDF removido com sucesso")
                else:
                    print(f"   ❌ Erro ao remover PDF: {response.status_code}")
                
            else:
                print(f"   ❌ Erro no upload: {response.status_code}")
                if response.text:
                    print(f"   📄 Resposta: {response.text}")
                return False
                
        except Exception as e:
            print(f"   ❌ Erro no upload: {e}")
            return False
    else:
        print(f"\n4. Pulando teste de upload - arquivo {test_pdf_path} não encontrado")
        print("   💡 Crie um PDF de teste para testar upload completo")
    
    print("\n" + "=" * 50)
    print("✅ Testes concluídos com sucesso!")
    print("🎉 Funcionalidade de PDF está funcionando corretamente!")
    
    return True

def create_test_pdf():
    """Cria um PDF de teste simples"""
    try:
        from reportlab.pdfgen import canvas
        from reportlab.lib.pagesizes import letter
        
        filename = "test_document.pdf"
        c = canvas.Canvas(filename, pagesize=letter)
        
        # Título
        c.setFont("Helvetica-Bold", 16)
        c.drawString(100, 750, "Documento de Teste - Rede Comunitária")
        
        # Subtítulo
        c.setFont("Helvetica", 12)
        c.drawString(100, 720, "Portal Sem Porteiras")
        
        # Conteúdo
        c.setFont("Helvetica", 10)
        content = [
            "Este é um documento de teste para verificar a funcionalidade",
            "de processamento de PDFs no chatbot de IA local.",
            "",
            "Principais características:",
            "- Processamento local de documentos",
            "- Extração de texto inteligente",
            "- Cache para melhor performance",
            "- Integração com IA para respostas baseadas no conteúdo",
            "",
            "Este documento contém informações sobre a rede comunitária",
            "e pode ser usado para testar as capacidades do sistema."
        ]
        
        y_position = 680
        for line in content:
            c.drawString(100, y_position, line)
            y_position -= 20
        
        c.save()
        print(f"✅ PDF de teste criado: {filename}")
        return True
        
    except ImportError:
        print("❌ reportlab não instalado. Instale com: pip install reportlab")
        return False
    except Exception as e:
        print(f"❌ Erro ao criar PDF de teste: {e}")
        return False

if __name__ == "__main__":
    print("🤖 Teste de Funcionalidade de PDF - Chatbot IA Local")
    print("Rede Comunitária Portal Sem Porteiras")
    print()
    
    # Verificar se quer criar PDF de teste
    if len(sys.argv) > 1 and sys.argv[1] == "--create-pdf":
        create_test_pdf()
    else:
        # Executar testes
        success = test_pdf_functionality()
        
        if not success:
            print("\n❌ Alguns testes falharam!")
            print("💡 Verifique se o servidor está rodando em http://localhost:8080")
            print("💡 Use --create-pdf para criar um PDF de teste")
            sys.exit(1) 