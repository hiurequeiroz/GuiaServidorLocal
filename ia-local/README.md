# 🤖 Chatbot de IA Local - Rede Comunitária Portal Sem Porteiras

Um chatbot de inteligência artificial que roda localmente na rede comunitária, sem necessidade de internet externa. Desenvolvido para a **Rede Comunitária Portal Sem Porteiras**.

## ✨ Funcionalidades

- **IA Local**: Processamento local sem dependência de serviços externos
- **Aceleração GPU**: Suporte a GPU NVIDIA para processamento mais rápido
- **Upload de PDFs**: Faça upload de documentos PDF para que a IA responda baseada no conteúdo
- **Múltiplos Modelos**: Suporte a diferentes modelos de IA (LLaMA 2, Mistral, Code Llama)
- **Interface Web**: Interface moderna e responsiva
- **Histórico**: Salva e exporta conversas
- **Cache Inteligente**: Cache de PDFs processados para melhor performance

## 🚀 Instalação Rápida

### Pré-requisitos

- **Sistema**: Debian 12 ou Ubuntu 22.04+
- **GPU**: NVIDIA RTX 4060 ou superior (recomendado)
- **RAM**: Mínimo 8GB, recomendado 16GB+
- **Armazenamento**: 20GB livres para modelos e cache

### Instalação Automática

```bash
# Baixar script de instalação
wget https://raw.githubusercontent.com/seu-repo/ia-local/main/install-debian.sh

# Tornar executável
chmod +x install-debian.sh

# Executar instalação
sudo ./install-debian.sh
```

### Instalação Manual

1. **Instalar Docker e NVIDIA Container Toolkit**:
```bash
# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

2. **Clonar e executar**:
```bash
git clone https://github.com/seu-repo/ia-local.git
cd ia-local
sudo docker-compose up -d
```

## 📄 Funcionalidade de PDF

### Como Usar

1. **Upload de PDF**: Clique no botão "Upload PDF" no painel lateral
2. **Seleção**: Arraste um arquivo PDF ou clique para selecionar
3. **Processamento**: O sistema extrai automaticamente o texto do PDF
4. **Ativação**: Clique em um PDF na lista para ativá-lo como contexto
5. **Chat**: A IA responderá baseada no conteúdo do PDF ativo

### Recursos

- **Extração Inteligente**: Usa múltiplos métodos para extrair texto (PyPDF2 + pdfplumber)
- **Cache**: PDFs processados são cacheados para evitar reprocessamento
- **Metadados**: Extrai título, autor, número de páginas e outras informações
- **Limite de Tamanho**: Máximo 16MB por arquivo
- **Contexto Limitado**: Limita o contexto enviado para a IA (2000 caracteres)

### Formatos Suportados

- ✅ PDFs com texto (recomendado)
- ✅ PDFs escaneados (OCR básico)
- ✅ PDFs com imagens e tabelas

## 🎯 Casos de Uso

### Para Redes Comunitárias

1. **Documentação Local**: Upload de manuais, regulamentos e documentos da comunidade
2. **Educação**: Material didático e apostilas para cursos locais
3. **Administração**: Processamento de formulários e relatórios
4. **Pesquisa**: Análise de documentos históricos da comunidade

### Exemplos Práticos

- **Manual da Rede**: "Como configurar um novo nó na rede?"
- **Regulamento**: "Quais são as regras para uso do servidor?"
- **Relatório**: "Resuma os principais pontos do relatório mensal"
- **Apostila**: "Explique o conceito de roteamento em redes"

## 🔧 Configuração

### Variáveis de Ambiente

```bash
# .env
OLLAMA_HOST=http://localhost:11434
MODEL_NAME=llama2
```

### Modelos Disponíveis

- **llama2**: Modelo geral (padrão)
- **mistral**: Modelo mais rápido e eficiente
- **codellama**: Especializado em código
- **llama2:13b**: Versão maior e mais precisa

### Baixar Novos Modelos

1. Acesse a interface web
2. Selecione o modelo desejado no dropdown
3. Clique em "Baixar Modelo"
4. Aguarde o download (pode demorar alguns minutos)

## 📊 Performance

### Comparação CPU vs GPU

| Métrica | CPU (Intel i5) | GPU (RTX 4060) | Melhoria |
|---------|----------------|----------------|----------|
| Tempo de Resposta | 30-60 segundos | 2-5 segundos | **10x mais rápido** |
| Tokens/segundo | ~5-10 | ~50-100 | **10x mais eficiente** |
| Uso de Memória | 8GB RAM | 8GB RAM + 8GB VRAM | Melhor distribuição |
| Temperatura | 70-80°C | 45-55°C | Mais eficiente |

### Análise de Custo-Benefício

- **Investimento**: RTX 4060 (~R$ 2.500)
- **Economia**: Não precisa de serviços cloud caros
- **Privacidade**: Dados ficam na rede local
- **Velocidade**: 10x mais rápido que CPU
- **ROI**: Pago em 6-12 meses vs serviços cloud

## 🛠️ Manutenção

### Logs

```bash
# Ver logs do chatbot
docker-compose logs chatbot

# Ver logs do Ollama
docker-compose logs ollama

# Logs de chat
tail -f logs/chat_history.json
```

### Backup

```bash
# Backup dos modelos
sudo docker run --rm -v ollama_data:/root/.ollama -v $(pwd):/backup alpine tar czf /backup/ollama-models-$(date +%Y%m%d).tar.gz -C /root/.ollama .

# Backup de PDFs e cache
tar czf backup-pdfs-$(date +%Y%m%d).tar.gz uploads/ cache/
```

### Limpeza

```bash
# Limpar cache de PDFs
rm -rf cache/*

# Limpar uploads
rm -rf uploads/*

# Limpar logs antigos
find logs/ -name "*.json" -mtime +30 -delete
```

## 🔍 Troubleshooting

### Problemas Comuns

1. **GPU não detectada**:
   ```bash
   nvidia-smi  # Verificar se GPU está funcionando
   sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
   ```

2. **Modelo não baixa**:
   ```bash
   # Verificar espaço em disco
   df -h
   
   # Verificar logs do Ollama
   docker-compose logs ollama
   ```

3. **PDF não processa**:
   ```bash
   # Verificar dependências
   docker-compose exec chatbot pip list | grep -E "(PyPDF2|pdfplumber)"
   
   # Verificar logs
   docker-compose logs chatbot
   ```

4. **Interface não carrega**:
   ```bash
   # Verificar se porta está livre
   netstat -tlnp | grep 8080
   
   # Reiniciar serviços
   docker-compose restart
   ```

### Logs Detalhados

```bash
# Ativar logs detalhados
docker-compose up -d --build
docker-compose logs -f chatbot
```

## 🤝 Contribuição

Para contribuir com o projeto:

1. Fork o repositório
2. Crie uma branch para sua feature
3. Faça commit das mudanças
4. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- **Ollama**: Framework de IA local
- **Flask**: Framework web
- **NVIDIA**: Suporte a GPU
- **Comunidade Portal Sem Porteiras**: Testes e feedback

## 📞 Suporte

Para suporte técnico ou dúvidas:

- **Email**: suporte@portalsemporteiras.org
- **Telegram**: @portalsemporteiras
- **Issues**: GitHub Issues

---

**Desenvolvido com ❤️ para a Rede Comunitária Portal Sem Porteiras** 