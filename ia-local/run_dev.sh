#!/bin/bash

# Script de Desenvolvimento para Chatbot IA Local
# Portal Sem Porteiras - Rede Comunitária
# Usa servidor Ollama remoto em 10.208.173.206

set -e

echo "🔧 Modo Desenvolvimento - Chatbot IA Local"
echo "🌐 Portal Sem Porteiras - Rede Comunitária"
echo "🔗 Servidor Ollama: 10.208.173.206:11434"
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "app.py" ]; then
    echo "❌ Execute este script no diretório ia-local/"
    exit 1
fi

# Verificar se o ambiente virtual existe
if [ ! -d "venv" ]; then
    echo "🔧 Criando ambiente virtual..."
    python3 -m venv venv
fi

# Ativar ambiente virtual
echo "🔧 Ativando ambiente virtual..."
source venv/bin/activate

# Instalar/atualizar dependências
echo "📦 Instalando dependências..."
pip install -r requirements.txt

# Verificar conectividade com servidor Ollama
echo "🔍 Verificando conectividade com servidor Ollama..."
if curl -s http://10.208.173.206:11434/api/tags > /dev/null 2>&1; then
    echo "✅ Servidor Ollama acessível"
else
    echo "⚠️  Aviso: Servidor Ollama não respondeu. Verifique se está rodando em 10.208.173.206:11434"
    echo "   Continuando inicialização da aplicação..."
fi

# Configurar variáveis de ambiente
export OLLAMA_HOST="http://10.208.173.206:11434"
export MODEL_NAME="llama2"
export FLASK_ENV="development"
export FLASK_DEBUG="True"

# Criar diretórios necessários
mkdir -p uploads cache logs

echo ""
echo "🚀 Iniciando aplicação em modo desenvolvimento..."
echo "🌐 Acesse: http://localhost:8080"
echo "🔗 Servidor Ollama: http://10.208.173.206:11434"
echo ""
echo "📝 Para parar: Ctrl+C"
echo ""

# Iniciar aplicação
python app.py 