#!/bin/bash

# Script de Deploy para DESENVOLVIMENTO - Chatbot IA Local
# Portal Sem Porteiras - Rede Comunitária
# Usa servidor Ollama remoto configurado via variável de ambiente

set -e

echo "🔧 Deploy de DESENVOLVIMENTO - Chatbot IA Local"
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
    docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
    
    # Rebuild da imagem
    echo "🔨 Rebuild da imagem Docker para desenvolvimento..."
    docker-compose -f docker-compose.dev.yml build --no-cache
    
    # Atualizar timestamp
    touch .last_deploy
    echo "✅ Timestamp de deploy atualizado"
else
    echo "✅ Nenhuma mudança detectada - Iniciando containers existentes"
fi

# Iniciar containers de desenvolvimento
echo ""
echo "🚀 Iniciando containers de desenvolvimento..."
docker-compose -f docker-compose.dev.yml up -d

# Aguardar inicialização
echo "⏳ Aguardando inicialização..."
sleep 5

# Verificar status
echo ""
echo "📊 Status dos containers:"
docker-compose -f docker-compose.dev.yml ps

# Verificar logs
echo ""
echo "📋 Últimos logs do chatbot:"
docker-compose -f docker-compose.dev.yml logs --tail=10 chatbot

echo ""
echo "🎉 Deploy de DESENVOLVIMENTO concluído!"
echo "🌐 Acesse: http://localhost:8080"
echo "🔗 Servidor Ollama: $OLLAMA_HOST"
echo "📝 Volumes montados para desenvolvimento (código atualizado sem rebuild)"
echo ""
echo "📝 Comandos úteis:"
echo "   docker-compose -f docker-compose.dev.yml logs -f chatbot    # Ver logs em tempo real"
echo "   docker-compose -f docker-compose.dev.yml down               # Parar containers"
echo "   docker-compose -f docker-compose.dev.yml restart chatbot    # Reiniciar apenas o chatbot"
echo ""
echo "💡 Para produção, use: ./deploy.sh" 