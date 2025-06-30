#!/bin/bash

# Script de Deploy para PRODUÇÃO - Chatbot IA Local
# Portal Sem Porteiras - Rede Comunitária
# Usa servidor Ollama remoto configurado via variável de ambiente

set -e

echo "🏭 Deploy de PRODUÇÃO - Chatbot IA Local"
echo "🌐 Portal Sem Porteiras - Rede Comunitária"
echo ""

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Iniciando..."
    sudo systemctl start docker
    sleep 3
fi

# Verificar se arquivo .env existe
if [ ! -f ".env" ]; then
    echo "⚠️  Arquivo .env não encontrado!"
    if [ -f ".env.example" ]; then
        echo "📝 Criando .env a partir do .env.example..."
        cp .env.example .env
        echo "✅ Arquivo .env criado com valor padrão (localhost:11434)"
        echo "💡 Para usar servidor remoto, edite o arquivo .env:"
        echo "   nano .env"
        echo "   # Altere OLLAMA_HOST para o IP do servidor Ollama"
    else
        echo "❌ Arquivo .env.example não encontrado!"
        echo "📝 Criando .env manualmente..."
        echo "OLLAMA_HOST=http://localhost:11434" > .env
        echo "✅ Arquivo .env criado com valor padrão"
    fi
fi

# Carregar variáveis de ambiente
source .env

# Verificar se OLLAMA_HOST está definido
if [ -z "$OLLAMA_HOST" ]; then
    echo "❌ Variável OLLAMA_HOST não está definida no .env"
    echo "💡 Adicione ao arquivo .env:"
    echo "   OLLAMA_HOST=http://localhost:11434"
    exit 1
fi

echo "🔗 Servidor Ollama configurado: $OLLAMA_HOST"

# Verificar conectividade com servidor Ollama
echo "🔍 Verificando conectividade com servidor Ollama..."
if curl -s "$OLLAMA_HOST/api/tags" > /dev/null 2>&1; then
    echo "✅ Servidor Ollama acessível"
else
    echo "⚠️  Aviso: Servidor Ollama não respondeu em $OLLAMA_HOST"
    echo "   Verifique se o servidor está rodando e acessível"
    echo "   Continuando deploy da aplicação web..."
fi

# Parar containers existentes e limpar órfãos
echo "🛑 Parando containers existentes..."
docker-compose down --remove-orphans 2>/dev/null || true

# Limpar containers órfãos
echo "🧹 Limpando containers órfãos..."
docker container prune -f 2>/dev/null || true

# Rebuild da imagem para produção
echo "🔨 Rebuild da imagem Docker para produção..."
docker-compose build --no-cache

# Iniciar containers
echo ""
echo "🚀 Iniciando containers de produção..."
docker-compose up -d

# Aguardar inicialização
echo "⏳ Aguardando inicialização..."
sleep 5

# Verificar status
echo ""
echo "📊 Status dos containers:"
docker-compose ps

# Verificar logs
echo ""
echo "📋 Últimos logs do chatbot:"
docker-compose logs --tail=10 chatbot

echo ""
echo "🎉 Deploy de PRODUÇÃO concluído!"
echo "🌐 Acesse: http://localhost:8080"
echo "🔗 Servidor Ollama: $OLLAMA_HOST"
echo ""
echo "📝 Comandos úteis:"
echo "   docker-compose logs -f chatbot    # Ver logs em tempo real"
echo "   docker-compose down               # Parar containers"
echo "   docker-compose restart chatbot    # Reiniciar apenas o chatbot"
echo ""
echo "💡 Para desenvolvimento, use: ./deploy-dev.sh"

# Mostrar informações úteis
echo ""
echo "🔧 Comandos úteis:"
echo "   - Ver logs: docker-compose -f $COMPOSE_FILE logs -f"
echo "   - Parar: docker-compose -f $COMPOSE_FILE down"
echo "   - Restart: docker-compose -f $COMPOSE_FILE restart"
echo "   - Status: docker-compose -f $COMPOSE_FILE ps"
echo ""
echo "📚 Documentação:"
echo "   - README.md: Documentação geral"
echo "   - DEVELOPMENT.md: Guia de desenvolvimento"
echo "   - PDF_FEATURE.md: Funcionalidade de PDF" 