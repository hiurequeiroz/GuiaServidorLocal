#!/bin/bash

# Script de Atualização Inteligente - Chatbot IA Local
# Rede Comunitária Portal Sem Porteiras

set -e

echo "🔄 Atualizando Chatbot IA Local..."
echo "Rede Comunitária Portal Sem Porteiras"
echo "======================================"

# Verificar se estamos no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Execute este script no diretório ia-local/"
    exit 1
fi

# Verificar se há mudanças no Git
echo "📋 Verificando mudanças..."
if git diff --quiet HEAD~1 HEAD -- .; then
    echo "✅ Nenhuma mudança detectada no código"
    UPDATE_TYPE="restart"
else
    echo "🔄 Mudanças detectadas no código"
    UPDATE_TYPE="rebuild"
fi

# Verificar se requirements.txt mudou
if git diff --quiet HEAD~1 HEAD -- requirements.txt; then
    echo "✅ Dependências não mudaram"
else
    echo "📦 Dependências mudaram - rebuild necessário"
    UPDATE_TYPE="rebuild"
fi

# Verificar se Dockerfile mudou
if git diff --quiet HEAD~1 HEAD -- Dockerfile; then
    echo "✅ Dockerfile não mudou"
else
    echo "🐳 Dockerfile mudou - rebuild necessário"
    UPDATE_TYPE="rebuild"
fi

echo ""
echo "🎯 Tipo de atualização: $UPDATE_TYPE"

if [ "$UPDATE_TYPE" = "rebuild" ]; then
    echo "🔨 Executando rebuild completo..."
    
    # Parar containers
    echo "⏹️  Parando containers..."
    docker-compose down
    
    # Remover containers órfãos
    echo "🧹 Removendo containers órfãos..."
    docker container prune -f
    
    # Rebuild e subir
    echo "🔨 Fazendo rebuild..."
    docker-compose up -d --build
    
else
    echo "⚡ Atualização rápida (sem rebuild)..."
    
    # Apenas restart dos containers
    echo "🔄 Reiniciando containers..."
    docker-compose restart chatbot
    
    # Verificar se ollama precisa restart
    if ! docker-compose exec -T ollama ollama list > /dev/null 2>&1; then
        echo "🤖 Reiniciando Ollama..."
        docker-compose restart ollama
    fi
fi

# Aguardar um pouco para os serviços iniciarem
echo "⏳ Aguardando serviços iniciarem..."
sleep 5

# Verificar status
echo "📊 Verificando status..."
if docker-compose ps | grep -q "Up"; then
    echo "✅ Serviços estão rodando!"
    
    # Testar API
    if curl -s http://localhost:8080/api/health > /dev/null; then
        echo "✅ API está respondendo!"
        echo "🌐 Acesse: http://localhost:8080"
    else
        echo "⚠️  API não está respondendo ainda..."
        echo "💡 Aguarde mais alguns segundos e tente novamente"
    fi
else
    echo "❌ Alguns serviços não estão rodando"
    echo "📋 Status dos containers:"
    docker-compose ps
fi

echo ""
echo "🎉 Atualização concluída!"
echo "======================================" 