#!/bin/bash

# Script de Setup para Desenvolvimento - Chatbot IA Local
# Rede Comunitária Portal Sem Porteiras

set -e  # Parar em caso de erro

echo "🚀 Configurando ambiente de desenvolvimento..."
echo "Rede Comunitária Portal Sem Porteiras"
echo "======================================"

# Verificar se Python 3.11+ está instalado
echo "📋 Verificando Python..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não encontrado. Instale Python 3.11+ primeiro."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "✅ Python $PYTHON_VERSION encontrado"

# Verificar se pip está instalado
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 não encontrado. Instale pip primeiro."
    exit 1
fi

# Criar ambiente virtual
echo "🔧 Criando ambiente virtual..."
if [ -d "venv" ]; then
    echo "⚠️  Ambiente virtual já existe. Removendo..."
    rm -rf venv
fi

python3 -m venv venv
echo "✅ Ambiente virtual criado"

# Ativar ambiente virtual
echo "🔌 Ativando ambiente virtual..."
source venv/bin/activate

# Atualizar pip
echo "📦 Atualizando pip..."
pip install --upgrade pip

# Instalar dependências
echo "📚 Instalando dependências..."
pip install -r requirements.txt

# Criar diretórios necessários
echo "📁 Criando diretórios..."
mkdir -p uploads cache logs

# Verificar se Docker está instalado (opcional para desenvolvimento)
echo "🐳 Verificando Docker..."
if command -v docker &> /dev/null; then
    echo "✅ Docker encontrado"
    DOCKER_AVAILABLE=true
else
    echo "⚠️  Docker não encontrado (opcional para desenvolvimento)"
    DOCKER_AVAILABLE=false
fi

# Verificar se Ollama está instalado
echo "🤖 Verificando Ollama..."
if command -v ollama &> /dev/null; then
    echo "✅ Ollama encontrado"
    OLLAMA_AVAILABLE=true
else
    echo "⚠️  Ollama não encontrado"
    echo "   Instale com: curl -fsSL https://ollama.ai/install.sh | sh"
    OLLAMA_AVAILABLE=false
fi

# Criar arquivo .env para desenvolvimento
echo "⚙️  Criando arquivo .env..."
cat > .env << EOF
# Configurações de Desenvolvimento
OLLAMA_HOST=http://localhost:11434
MODEL_NAME=llama2
FLASK_ENV=development
FLASK_DEBUG=True
EOF

echo "✅ Arquivo .env criado"

# Criar PDF de teste
echo "📄 Criando PDF de teste..."
python test_pdf.py --create-pdf

echo ""
echo "🎉 Ambiente de desenvolvimento configurado!"
echo "======================================"
echo ""
echo "📋 Próximos passos:"
echo ""
echo "1. Ativar ambiente virtual:"
echo "   source venv/bin/activate"
echo ""
echo "2. Iniciar Ollama (se instalado):"
echo "   ollama serve"
echo ""
echo "3. Baixar modelo (opcional):"
echo "   ollama pull llama2"
echo ""
echo "4. Executar aplicação:"
echo "   python app.py"
echo ""
echo "5. Acessar interface:"
echo "   http://localhost:8080"
echo ""
echo "6. Testar funcionalidade de PDF:"
echo "   python test_pdf.py"
echo ""
echo "🔧 Comandos úteis:"
echo "   - Desativar venv: deactivate"
echo "   - Reinstalar dependências: pip install -r requirements.txt"
echo "   - Ver logs: tail -f logs/chat_history.json"
echo ""
echo "📚 Documentação:"
echo "   - README.md: Documentação geral"
echo "   - PDF_FEATURE.md: Funcionalidade de PDF"
echo "   - PERFORMANCE.md: Análise de performance"
echo ""

if [ "$DOCKER_AVAILABLE" = true ]; then
    echo "🐳 Para usar Docker:"
    echo "   docker-compose up -d"
    echo "   docker-compose logs -f"
fi

echo "✅ Setup concluído!" 