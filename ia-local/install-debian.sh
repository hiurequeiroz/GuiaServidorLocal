#!/bin/bash

# Script de instalação automática para Debian 12
# Chatbot de IA Local - Rede Comunitária

echo "🤖 Instalação do Chatbot de IA Local"
echo "====================================="
echo "Sistema: Debian 12"
echo ""

# Verificar se é root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Não execute este script como root!"
    echo "Execute como usuário normal com sudo"
    exit 1
fi

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "📦 Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

echo "📦 Instalando dependências básicas..."
sudo apt install -y curl wget git htop nano lsb-release gnupg

echo "🐳 Instalando Docker..."
if ! command_exists docker; then
    # Adicionar repositório oficial do Docker
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Atualizar e instalar Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Adicionar usuário ao grupo docker
    sudo usermod -aG docker $USER
    
    # Iniciar e habilitar Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    echo "✅ Docker instalado com sucesso!"
else
    echo "✅ Docker já está instalado"
fi

echo "📦 Instalando Docker Compose..."
if ! command_exists docker-compose; then
    # Baixar Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Criar link simbólico
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    echo "✅ Docker Compose instalado com sucesso!"
else
    echo "✅ Docker Compose já está instalado"
fi

echo "🎮 Verificando GPU NVIDIA..."
if lspci | grep -i nvidia > /dev/null; then
    echo "✅ GPU NVIDIA detectada!"
    
    echo "📦 Instalando drivers NVIDIA..."
    sudo apt install -y nvidia-driver firmware-misc-nonfree
    
    echo "📦 Instalando NVIDIA Container Toolkit..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    sudo apt update
    sudo apt install -y nvidia-container-toolkit
    sudo systemctl restart docker
    
    echo "✅ Drivers NVIDIA instalados!"
else
    echo "⚠️  GPU NVIDIA não detectada. O chatbot rodará apenas com CPU."
fi

echo "🔄 Aplicando mudanças do grupo docker..."
newgrp docker

echo ""
echo "🧪 Testando instalação..."

# Testar Docker
if docker --version > /dev/null 2>&1; then
    echo "✅ Docker funcionando"
else
    echo "❌ Erro: Docker não está funcionando"
    exit 1
fi

# Testar Docker Compose
if docker-compose --version > /dev/null 2>&1; then
    echo "✅ Docker Compose funcionando"
else
    echo "❌ Erro: Docker Compose não está funcionando"
    exit 1
fi

# Testar GPU se disponível
if command_exists nvidia-smi; then
    if nvidia-smi > /dev/null 2>&1; then
        echo "✅ GPU NVIDIA funcionando"
        
        # Testar NVIDIA Docker
        if docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi > /dev/null 2>&1; then
            echo "✅ NVIDIA Docker funcionando"
        else
            echo "⚠️  NVIDIA Docker não está funcionando (rodará apenas com CPU)"
        fi
    else
        echo "⚠️  GPU NVIDIA detectada mas não está funcionando"
    fi
fi

echo ""
echo "📥 Baixando o projeto..."
if [ ! -d "GuiaServidorLocal" ]; then
    git clone https://github.com/hiurequeiroz/GuiaServidorLocal.git
    echo "✅ Projeto baixado"
else
    echo "✅ Projeto já existe"
fi

cd GuiaServidorLocal/ia-local

echo ""
echo "🚀 Iniciando o chatbot..."
chmod +x start.sh
./start.sh

echo ""
echo "🎉 Instalação concluída!"
echo "🌐 Acesse: http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "📝 Comandos úteis:"
echo "   Parar: docker-compose down"
echo "   Logs:  docker-compose logs -f"
echo "   Status: docker-compose ps"
echo ""
echo "🤝 Compartilhe o IP $(hostname -I | awk '{print $1}'):8080 com outros membros da rede!" 