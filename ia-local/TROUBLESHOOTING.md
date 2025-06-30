# 🐛 Guia de Solução de Problemas

Este guia documenta problemas comuns e suas soluções baseadas em experiências reais.

## ⚠️ Problemas Comuns

### 1. **Sistema entra em suspensão durante instalação**

**Problema**: Servidor suspende no meio da instalação via SSH

**Sintomas**:
- Conexão SSH cai
- Script para de responder
- Mensagem "The system will suspend now!"

**Soluções**:

#### Opção A: Desabilitar suspensão automática
```bash
# Desabilitar suspensão do sistema
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Verificar se foi desabilitado
sudo systemctl status sleep.target
```

#### Opção B: Usar screen (Recomendado)
```bash
# Instalar screen
sudo apt install screen

# Criar uma nova sessão
screen -S instalacao

# Executar o script dentro do screen
./install-debian.sh
```

**Se a sessão cair, reconecte com:**
```bash
screen -r instalacao
```

#### Opção C: Usar nohup
```bash
# Executar em background que continua mesmo se SSH cair
nohup ./install-debian.sh > instalacao.log 2>&1 &

# Acompanhar o progresso
tail -f instalacao.log
```

### 2. **Script trava na instalação do NVIDIA Container Toolkit**

**Problema**: Script para de responder durante instalação dos drivers NVIDIA

**Sintomas**:
- Script para em "Instalando NVIDIA Container Toolkit..."
- Não responde a Ctrl+C
- Processo fica travado

**Solução**:
```bash
# Parar processo travado
pkill -f install-debian

# Verificar se Docker já foi instalado
docker --version
docker-compose --version

# Se Docker estiver OK, continuar manualmente
git clone https://github.com/hiurequeiroz/GuiaServidorLocal.git
cd GuiaServidorLocal/ia-local
./start.sh
```

### 3. **Erro "Erro na comunicação com o modelo de IA"**

**Problema**: Chatbot inicia mas não consegue se comunicar com a IA

**Sintomas**:
- Interface web carrega
- Erro 500 ao tentar enviar mensagem
- Console mostra "Erro na comunicação com o modelo de IA"

**Causa**: Modelo de IA não foi baixado ainda

**Solução**:
```bash
# Verificar se Ollama está funcionando
curl http://SEU_IP:11434/api/tags

# Baixar um modelo (pode demorar 10-15 minutos)
docker exec -it ia-local-ollama ollama pull llama2

# Verificar modelos disponíveis
docker exec -it ia-local-ollama ollama list

# Testar API diretamente
curl -X POST http://SEU_IP:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "llama2", "prompt": "Olá"}'
```

### 4. **Container não encontrado**

**Problema**: `Error: No such container: ia-local-ollama`

**Sintomas**:
- Comando docker exec falha
- Container não aparece na lista

**Solução**:
```bash
# Verificar containers ativos
docker ps

# Se não estiver rodando, iniciar
cd GuiaServidorLocal/ia-local
./start.sh

# Verificar logs
docker-compose logs -f
```

### 5. **Download do modelo muito lento**

**Problema**: Download do modelo demora muito ou para

**Sintomas**:
- Progresso muito lento
- Download para no meio
- Conexão instável

**Soluções**:

#### Usar modelo menor
```bash
# Baixar modelo menor (mais rápido)
docker exec -it ia-local-ollama ollama pull mistral
```

#### Verificar conexão
```bash
# Testar velocidade de download
wget --report-speed=bits https://speed.cloudflare.com/__down

# Verificar se há proxy ou firewall
curl -I https://ollama.ai
```

## 📋 Checklist de Verificação

Após a instalação, execute este checklist:

```bash
echo "=== VERIFICAÇÃO COMPLETA ==="
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo 'CPU apenas')"
echo "Usuário no grupo docker: $(groups $USER | grep docker && echo 'SIM' || echo 'NÃO')"
echo "Ollama API: $(curl -s http://localhost:11434/api/tags | grep -o '"models":\[.*\]' || echo 'NÃO RESPONDE')"
echo "Containers ativos: $(docker ps --format 'table {{.Names}}\t{{.Status}}')"
```

## 🔧 Comandos Úteis

### Verificar status
```bash
# Status dos containers
docker-compose ps

# Logs em tempo real
docker-compose logs -f

# Uso da GPU
watch -n 1 nvidia-smi

# Uso de recursos
htop
```

### Reiniciar serviços
```bash
# Reiniciar containers
docker-compose restart

# Reiniciar Docker
sudo systemctl restart docker

# Reiniciar tudo
docker-compose down && ./start.sh
```

### Limpar e reinstalar
```bash
# Parar tudo
docker-compose down

# Remover imagens
docker rmi ia-local-web ollama/ollama

# Reinstalar
./start.sh
```

## 📞 Suporte

Se ainda tiver problemas:

1. **Verificar logs**: `docker-compose logs -f`
2. **Reiniciar**: `docker-compose restart`
3. **Reinstalar**: `./start.sh --reset`
4. **Verificar requisitos**: CPU 4 cores, RAM 8GB, 10GB livre

## 🎯 Dicas Importantes

- **Sempre use screen** quando instalar via SSH
- **Baixe o modelo** antes de testar o chatbot
- **Verifique a GPU** se tiver placa NVIDIA
- **Monitore os logs** para identificar problemas
- **Use modelos menores** se tiver conexão lenta

---

**Baseado em experiências reais de instalação** 🚀 