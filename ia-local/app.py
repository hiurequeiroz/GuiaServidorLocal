#!/usr/bin/env python3
"""
Chatbot de IA Local - Rede Comunitária
Servidor Flask para interface web do chatbot
"""

import os
import json
import requests
from datetime import datetime
from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

# Carregar variáveis de ambiente
load_dotenv()

app = Flask(__name__)
CORS(app)

# Configurações
OLLAMA_HOST = os.getenv('OLLAMA_HOST', 'http://localhost:11434')
MODEL_NAME = os.getenv('MODEL_NAME', 'llama2')
LOG_FILE = 'logs/chat_history.json'

# Garantir que o diretório de logs existe
os.makedirs('logs', exist_ok=True)

def load_chat_history():
    """Carrega histórico de conversas"""
    if os.path.exists(LOG_FILE):
        try:
            with open(LOG_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        except:
            return []
    return []

def save_chat_history(history):
    """Salva histórico de conversas"""
    try:
        with open(LOG_FILE, 'w', encoding='utf-8') as f:
            json.dump(history, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"Erro ao salvar histórico: {e}")

def get_available_models():
    """Obtém lista de modelos disponíveis no Ollama"""
    try:
        response = requests.get(f"{OLLAMA_HOST}/api/tags")
        if response.status_code == 200:
            models = response.json().get('models', [])
            return [model['name'] for model in models]
    except Exception as e:
        print(f"Erro ao obter modelos: {e}")
    return []

@app.route('/')
def index():
    """Página principal do chatbot"""
    models = get_available_models()
    return render_template('index.html', models=models)

@app.route('/api/chat', methods=['POST'])
def chat():
    """Endpoint para conversar com a IA"""
    try:
        data = request.get_json()
        message = data.get('message', '').strip()
        model = data.get('model', MODEL_NAME)
        
        if not message:
            return jsonify({'error': 'Mensagem vazia'}), 400
        
        # Preparar requisição para o Ollama
        payload = {
            'model': model,
            'prompt': message,
            'stream': False
        }
        
        # Fazer requisição para o Ollama
        response = requests.post(
            f"{OLLAMA_HOST}/api/generate",
            json=payload,
            timeout=60
        )
        
        if response.status_code == 200:
            result = response.json()
            ai_response = result.get('response', 'Desculpe, não consegui processar sua mensagem.')
            
            # Salvar no histórico
            chat_entry = {
                'timestamp': datetime.now().isoformat(),
                'user_message': message,
                'ai_response': ai_response,
                'model': model
            }
            
            history = load_chat_history()
            history.append(chat_entry)
            save_chat_history(history)
            
            return jsonify({
                'response': ai_response,
                'model': model,
                'timestamp': chat_entry['timestamp']
            })
        else:
            return jsonify({'error': 'Erro na comunicação com o modelo de IA'}), 500
            
    except requests.exceptions.Timeout:
        return jsonify({'error': 'Timeout - o modelo demorou muito para responder'}), 408
    except Exception as e:
        return jsonify({'error': f'Erro interno: {str(e)}'}), 500

@app.route('/api/models')
def models():
    """Endpoint para listar modelos disponíveis"""
    models = get_available_models()
    return jsonify({'models': models})

@app.route('/api/history')
def history():
    """Endpoint para obter histórico de conversas"""
    history = load_chat_history()
    return jsonify({'history': history})

@app.route('/api/health')
def health():
    """Endpoint de saúde do sistema"""
    try:
        # Verificar se o Ollama está respondendo
        response = requests.get(f"{OLLAMA_HOST}/api/tags", timeout=5)
        ollama_status = response.status_code == 200
    except:
        ollama_status = False
    
    return jsonify({
        'status': 'healthy',
        'ollama': 'connected' if ollama_status else 'disconnected',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/download-model', methods=['POST'])
def download_model():
    """Endpoint para baixar um modelo"""
    try:
        data = request.get_json()
        model_name = data.get('model', MODEL_NAME)
        
        # Requisição para baixar modelo
        payload = {'name': model_name}
        response = requests.post(
            f"{OLLAMA_HOST}/api/pull",
            json=payload,
            timeout=300  # 5 minutos para download
        )
        
        if response.status_code == 200:
            return jsonify({'message': f'Modelo {model_name} baixado com sucesso!'})
        else:
            return jsonify({'error': 'Erro ao baixar modelo'}), 500
            
    except Exception as e:
        return jsonify({'error': f'Erro interno: {str(e)}'}), 500

if __name__ == '__main__':
    # Obter IP local para exibir
    import socket
    hostname = socket.gethostname()
    local_ip = socket.gethostbyname(hostname)
    
    print(f"🤖 Chatbot de IA Local iniciando...")
    print(f"🌐 Acesse: http://{local_ip}:8080")
    print(f"🔗 Ollama: {OLLAMA_HOST}")
    print(f"📝 Modelo padrão: {MODEL_NAME}")
    
    app.run(host='0.0.0.0', port=8080, debug=False) 