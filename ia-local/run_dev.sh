#!/bin/bash

# Script para executar aplicação em modo de desenvolvimento
# Chatbot IA Local - Rede Comunitária Portal Sem Porteiras

echo "🤖 Iniciando Chatbot IA Local em modo de desenvolvimento..."
echo "Rede Comunitária Portal Sem Porteiras"
echo "======================================"

# Verificar se ambiente virtual existe
if [ ! -d "venv" ]; then
    echo "❌ Ambiente virtual não encontrado!"
    echo "Execute primeiro: ./setup_dev.sh"
    exit 1
fi

# Verificar se arquivo .env existe
if [ ! -f ".env" ]; then
    echo "❌ Arquivo .env não encontrado!"
    echo "Execute primeiro: ./setup_dev.sh"
    exit 1
fi

# Ativar ambiente virtual
echo "🔌 Ativando ambiente virtual..."
source venv/bin/activate

# Verificar se dependências estão instaladas
echo "📦 Verificando dependências..."
if ! python -c "import flask, requests, PyPDF2, pdfplumber" 2>/dev/null; then
    echo "❌ Dependências não encontradas!"
    echo "Execute: pip install -r requirements.txt"
    exit 1
fi

# Verificar se Ollama está rodando
echo "🤖 Verificando Ollama..."
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "⚠️  Ollama não está rodando ou não está acessível"
    echo "   Inicie com: ollama serve"
    echo "   Ou instale com: curl -fsSL https://ollama.ai/install.sh | sh"
    echo ""
    echo "💡 Continuando sem Ollama (funcionalidade limitada)..."
    OLLAMA_RUNNING=false
else
    echo "✅ Ollama está rodando"
    OLLAMA_RUNNING=true
fi

# Verificar se diretórios existem
echo "📁 Verificando diretórios..."
mkdir -p uploads cache logs

# Mostrar informações do sistema
echo ""
echo "📊 Informações do Sistema:"
echo "   Python: $(python --version)"
echo "   Flask: $(python -c "import flask; print(flask.__version__)")"
echo "   Ollama: $([ "$OLLAMA_RUNNING" = true ] && echo "Rodando" || echo "Não disponível")"
echo "   Diretório: $(pwd)"
echo "   Porta: 8080"
echo ""

# Verificar se porta está livre
if netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "⚠️  Porta 8080 já está em uso!"
    echo "   Verifique se outra instância está rodando"
    echo "   Ou mude a porta no arquivo .env"
    exit 1
fi

echo "🚀 Iniciando aplicação..."
echo "   Interface: http://localhost:8080"
echo "   Pressione Ctrl+C para parar"
echo ""

# Executar aplicação
python app.py 