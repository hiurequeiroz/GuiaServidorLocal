# 🤖 Chatbot de IA Local - Rede Comunitária

Um chatbot de inteligência artificial que roda localmente na sua rede, permitindo que membros da comunidade conversem com IA sem depender de serviços externos.

## 🎯 Características

- **Totalmente Local**: Roda na sua rede, sem internet
- **GPU NVIDIA**: Suporte para aceleração por GPU (RTX 4060+)
- **Docker**: Fácil instalação e deploy
- **Interface Web**: Interface amigável via navegador
- **Compartilhável**: Outros membros da rede podem acessar

## 🚀 Instalação Rápida (Debian 12)

### Opção 1: Instalação Automática (Recomendado)
```bash
# Baixar o script de instalação
wget https://raw.githubusercontent.com/hiurequeiroz/GuiaServidorLocal/main/ia-local/install-debian.sh
chmod +x install-debian.sh

# Executar instalação completa
./install-debian.sh
```

### Opção 2: Instalação Manual

#### 1. Atualizar sistema
```bash
sudo apt update && sudo apt upgrade -y
```

#### 2. Instalar Docker
```bash
# Adicionar repositório oficial
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Configurar usuário
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker
```

#### 3. Instalar Docker Compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
```

#### 4. Instalar drivers NVIDIA (se tiver GPU)
```bash
# Verificar GPU
lspci | grep -i nvidia

# Se tiver GPU, instalar drivers
sudo apt install -y nvidia-driver firmware-misc-nonfree

# NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker
```

#### 5. Aplicar mudanças
```bash
newgrp docker
```

#### 6. Baixar e executar
```bash
git clone https://github.com/hiurequeiroz/GuiaServidorLocal.git
cd GuiaServidorLocal/ia-local
chmod +x start.sh
./start.sh
```

## 🎮 Uso

### Iniciar o chatbot
```bash
./start.sh
```

### Acessar via navegador
- **Local**: http://localhost:8080
- **Rede**: http://SEU_IP:8080

### Comandos úteis
```bash
# Ver status
docker-compose ps

# Ver logs
docker-compose logs -f

# Parar
docker-compose down

# Reiniciar
docker-compose restart
```

## 🔧 Configuração

### Variáveis de Ambiente
Edite o arquivo `.env` para personalizar:

```env
# Modelo de IA (opções: llama2, codellama, mistral)
AI_MODEL=llama2

# Porta do servidor
PORT=8080

# Configurações de GPU
NVIDIA_VISIBLE_DEVICES=all
```

### Modelos Disponíveis
- **llama2**: Modelo geral (recomendado)
- **codellama**: Especializado em código
- **mistral**: Modelo rápido e eficiente

## 🖥️ Requisitos

### Mínimos
- **CPU**: 4 cores
- **RAM**: 8GB
- **Armazenamento**: 10GB livres
- **Sistema**: Debian 12 ou Ubuntu 22.04

### Recomendados (para GPU)
- **GPU**: NVIDIA RTX 4060 ou superior
- **RAM**: 16GB+
- **Armazenamento**: SSD 20GB+

## 🐛 Solução de Problemas

### Docker não funciona
```bash
# Verificar status
sudo systemctl status docker

# Reiniciar Docker
sudo systemctl restart docker

# Verificar permissões
groups $USER
```

### GPU não detectada
```bash
# Verificar drivers
nvidia-smi

# Verificar NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

### Porta ocupada
```bash
# Verificar porta
sudo netstat -tlnp | grep :8080

# Mudar porta no .env
PORT=8081
```

## 🤝 Compartilhamento na Rede

### Descobrir IP da máquina
```bash
hostname -I
```

### Compartilhar com outros
- **IP**: `192.168.1.100:8080` (exemplo)
- **URL**: `http://192.168.1.100:8080`

### Configurar firewall (se necessário)
```bash
# Permitir porta 8080
sudo ufw allow 8080
```

## 📚 Aprendizado

Este projeto demonstra:
- **Containerização** com Docker
- **IA Local** sem dependência externa
- **Redes Locais** para compartilhamento
- **Automação** com scripts bash
- **GPU Computing** para aceleração

## 🔒 Privacidade

- ✅ **100% Local**: Dados não saem da sua rede
- ✅ **Sem Telemetria**: Não coleta dados
- ✅ **Open Source**: Código transparente
- ✅ **Sem Conta**: Não precisa se cadastrar

## 📞 Suporte

Para problemas ou dúvidas:
1. Verificar logs: `docker-compose logs -f`
2. Reiniciar: `docker-compose restart`
3. Reinstalar: `./start.sh --reset`

---

**Desenvolvido para Redes Comunitárias** 🌐🤖 