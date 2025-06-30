#!/bin/bash

# Script de Deploy Inteligente - Chatbot IA Local
# Rede Comunitária Portal Sem Porteiras

set -e

# Configurações
ENVIRONMENT=${1:-production}  # production ou development
COMPOSE_FILE="docker-compose.yml"
COMPOSE_DEV_FILE="docker-compose.dev.yml"

echo "🚀 Deploy do Chatbot IA Local"
echo "Rede Comunitária Portal Sem Porteiras"
echo "======================================"
echo "🌍 Ambiente: $ENVIRONMENT"
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Execute este script no diretório ia-local/"
    exit 1
fi

# Escolher arquivo de compose baseado no ambiente
if [ "$ENVIRONMENT" = "development" ]; then
    if [ -f "$COMPOSE_DEV_FILE" ]; then
        COMPOSE_FILE="$COMPOSE_DEV_FILE"
        echo "🔧 Usando configuração de desenvolvimento"
    else
        echo "⚠️  Arquivo de desenvolvimento não encontrado, usando produção"
    fi
else
    echo "🏭 Usando configuração de produção"
fi

# Verificar se há mudanças que precisam de rebuild
echo "📋 Verificando mudanças..."
NEEDS_REBUILD=false

# Verificar se requirements.txt mudou
if git diff --quiet HEAD~1 HEAD -- requirements.txt 2>/dev/null; then
    echo "✅ Dependências não mudaram"
else
    echo "📦 Dependências mudaram - rebuild necessário"
    NEEDS_REBUILD=true
fi

# Verificar se Dockerfile mudou
if git diff --quiet HEAD~1 HEAD -- Dockerfile 2>/dev/null; then
    echo "✅ Dockerfile não mudou"
else
    echo "🐳 Dockerfile mudou - rebuild necessário"
    NEEDS_REBUILD=true
fi

# Verificar se Dockerfile.dev mudou (se existir)
if [ -f "Dockerfile.dev" ] && ! git diff --quiet HEAD~1 HEAD -- Dockerfile.dev 2>/dev/null; then
    echo "🐳 Dockerfile.dev mudou - rebuild necessário"
    NEEDS_REBUILD=true
fi

echo ""
echo "🎯 Rebuild necessário: $NEEDS_REBUILD"

# Parar containers existentes
echo "⏹️  Parando containers existentes..."
docker-compose -f "$COMPOSE_FILE" down

# Remover containers órfãos
echo "🧹 Removendo containers órfãos..."
docker container prune -f

# Subir containers
if [ "$NEEDS_REBUILD" = true ]; then
    echo "🔨 Fazendo rebuild completo..."
    docker-compose -f "$COMPOSE_FILE" up -d --build
else
    echo "⚡ Subindo sem rebuild..."
    docker-compose -f "$COMPOSE_FILE" up -d
fi

# Aguardar serviços iniciarem
echo "⏳ Aguardando serviços iniciarem..."
sleep 10

# Verificar status
echo "📊 Verificando status..."
if docker-compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
    echo "✅ Serviços estão rodando!"
    
    # Testar API
    echo "🔍 Testando API..."
    for i in {1..5}; do
        if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
            echo "✅ API está respondendo!"
            break
        else
            echo "⏳ Tentativa $i/5 - Aguardando API..."
            sleep 2
        fi
    done
    
    if [ $i -eq 5 ]; then
        echo "⚠️  API não está respondendo ainda..."
        echo "💡 Verifique os logs: docker-compose -f $COMPOSE_FILE logs chatbot"
    fi
    
    echo ""
    echo "🌐 Acesse: http://localhost:8080"
    echo "📋 Status: docker-compose -f $COMPOSE_FILE ps"
    echo "📋 Logs: docker-compose -f $COMPOSE_FILE logs -f"
    
else
    echo "❌ Alguns serviços não estão rodando"
    echo "📋 Status dos containers:"
    docker-compose -f "$COMPOSE_FILE" ps
    echo ""
    echo "📋 Logs de erro:"
    docker-compose -f "$COMPOSE_FILE" logs --tail=20
fi

echo ""
echo "🎉 Deploy concluído!"
echo "======================================"

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