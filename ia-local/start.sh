#!/bin/bash

# Script de inicialização do Chatbot de IA Local
# Rede Comunitária

echo "🤖 Chatbot de IA Local - Rede Comunitária"
echo "=========================================="

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado. Instale o Docker primeiro."
    echo "📖 Guia: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado. Instale o Docker Compose primeiro."
    echo "📖 Guia: https://docs.docker.com/compose/install/"
    exit 1
fi

# Verificar se NVIDIA Docker está configurado (para GPU)
if command -v nvidia-smi &> /dev/null; then
    echo "✅ GPU NVIDIA detectada"
    if docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi &> /dev/null; then
        echo "✅ NVIDIA Docker configurado corretamente"
    else
        echo "⚠️  NVIDIA Docker não configurado. O chatbot rodará apenas com CPU."
        echo "📖 Guia: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
    fi
else
    echo "⚠️  GPU NVIDIA não detectada. O chatbot rodará apenas com CPU."
fi

echo ""
echo "🚀 Iniciando o chatbot..."

# Construir e iniciar os containers
docker-compose up -d --build

echo ""
echo "⏳ Aguardando inicialização..."

# Aguardar alguns segundos para os serviços iniciarem
sleep 10

# Verificar status dos containers
echo ""
echo "📊 Status dos containers:"
docker-compose ps

# Obter IP local
HOSTNAME=$(hostname)
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "✅ Chatbot iniciado com sucesso!"
echo "🌐 Acesse: http://$LOCAL_IP:8080"
echo "🔗 Ollama API: http://$LOCAL_IP:11434"
echo ""
echo "📝 Comandos úteis:"
echo "   Parar: docker-compose down"
echo "   Logs:  docker-compose logs -f"
echo "   Status: docker-compose ps"
echo ""
echo "🎓 Para baixar um modelo de IA:"
echo "   1. Acesse a interface web"
echo "   2. Selecione um modelo no dropdown"
echo "   3. Clique em 'Baixar Modelo'"
echo ""
echo "🤝 Compartilhe o IP $LOCAL_IP:8080 com outros membros da rede!" 