#!/bin/bash

# Script de Deploy Inteligente para Chatbot IA Local
# Portal Sem Porteiras - Rede Comunitária
# Usa servidor Ollama remoto em 10.208.173.206

set -e

echo "🤖 Deploy Inteligente - Chatbot IA Local"
echo "🌐 Portal Sem Porteiras - Rede Comunitária"
echo "🔗 Servidor Ollama: 10.208.173.206:11434"
echo ""

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Iniciando..."
    sudo systemctl start docker
    sleep 3
fi

# Verificar conectividade com servidor Ollama
echo "🔍 Verificando conectividade com servidor Ollama..."
if curl -s http://10.208.173.206:11434/api/tags > /dev/null 2>&1; then
    echo "✅ Servidor Ollama acessível"
else
    echo "⚠️  Aviso: Servidor Ollama não respondeu. Verifique se está rodando em 10.208.173.206:11434"
    echo "   Continuando deploy da aplicação web..."
fi

# Verificar se há mudanças no código
echo "🔍 Verificando mudanças no código..."

# Lista de arquivos para monitorar
FILES_TO_WATCH=(
    "app.py"
    "pdf_processor.py"
    "templates/"
    "static/"
    "requirements.txt"
    "Dockerfile"
    "Dockerfile.dev"
    "docker-compose.yml"
    "docker-compose.dev.yml"
)

# Verificar se há mudanças
HAS_CHANGES=false
for file in "${FILES_TO_WATCH[@]}"; do
    if [ -f "$file" ] || [ -d "$file" ]; then
        if [ "$file" -nt ".last_deploy" ] 2>/dev/null; then
            echo "📝 Mudanças detectadas em: $file"
            HAS_CHANGES=true
        fi
    fi
done

if [ "$HAS_CHANGES" = true ]; then
    echo "🔄 Mudanças detectadas - Rebuild necessário"
    echo ""
    
    # Parar containers existentes
    echo "🛑 Parando containers existentes..."
    docker-compose down 2>/dev/null || true
    
    # Rebuild da imagem
    echo "🔨 Rebuild da imagem Docker..."
    docker-compose build --no-cache
    
    # Atualizar timestamp
    touch .last_deploy
    echo "✅ Timestamp de deploy atualizado"
else
    echo "✅ Nenhuma mudança detectada - Iniciando containers existentes"
fi

# Iniciar containers
echo ""
echo "🚀 Iniciando containers..."
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
echo "🎉 Deploy concluído!"
echo "🌐 Acesse: http://localhost:8080"
echo "🔗 Servidor Ollama: http://10.208.173.206:11434"
echo ""
echo "📝 Comandos úteis:"
echo "   docker-compose logs -f chatbot    # Ver logs em tempo real"
echo "   docker-compose down               # Parar containers"
echo "   docker-compose restart chatbot    # Reiniciar apenas o chatbot"

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