# 🛠️ Guia de Desenvolvimento - Chatbot IA Local

## Visão Geral

Este guia explica como configurar e trabalhar com o ambiente de desenvolvimento local do Chatbot IA Local.

## 🚀 Setup Inicial

### Pré-requisitos

- **Python 3.11+**: Versão recomendada
- **pip**: Gerenciador de pacotes Python
- **Git**: Controle de versão
- **Ollama** (opcional): Para testar IA local

### Instalação Rápida

```bash
# 1. Clonar repositório
git clone <seu-repo>
cd ia-local

# 2. Configurar ambiente
chmod +x setup_dev.sh
./setup_dev.sh

# 3. Executar aplicação
chmod +x run_dev.sh
./run_dev.sh
```

### Instalação Manual

```bash
# 1. Criar ambiente virtual
python3 -m venv venv

# 2. Ativar ambiente
source venv/bin/activate

# 3. Instalar dependências
pip install -r requirements.txt

# 4. Criar diretórios
mkdir -p uploads cache logs

# 5. Criar .env
cat > .env << EOF
OLLAMA_HOST=http://localhost:11434
MODEL_NAME=llama2
FLASK_ENV=development
FLASK_DEBUG=True
EOF

# 6. Executar
python app.py
```

## 📁 Estrutura do Projeto

```
ia-local/
├── app.py                 # Aplicação principal Flask
├── pdf_processor.py       # Processamento de PDFs
├── requirements.txt       # Dependências Python
├── setup_dev.sh          # Script de setup
├── run_dev.sh            # Script de execução
├── test_pdf.py           # Testes de PDF
├── .env                  # Configurações (criado automaticamente)
├── .gitignore           # Arquivos ignorados pelo Git
├── static/              # Arquivos estáticos
│   ├── css/
│   ├── js/
│   └── image/
├── templates/           # Templates HTML
├── uploads/            # PDFs enviados (criado automaticamente)
├── cache/              # Cache de PDFs (criado automaticamente)
└── logs/               # Logs da aplicação (criado automaticamente)
```

## 🔧 Comandos Úteis

### Desenvolvimento

```bash
# Ativar ambiente virtual
source venv/bin/activate

# Desativar ambiente virtual
deactivate

# Instalar dependências
pip install -r requirements.txt

# Executar aplicação
python app.py

# Executar testes
python test_pdf.py

# Criar PDF de teste
python test_pdf.py --create-pdf
```

### Docker (opcional)

```bash
# Construir imagem
docker build -t chatbot-ia-local .

# Executar container
docker run -p 8080:8080 chatbot-ia-local

# Usar docker-compose
docker-compose up -d
docker-compose logs -f
```

### Ollama (IA Local)

```bash
# Instalar Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Iniciar servidor
ollama serve

# Baixar modelo
ollama pull llama2

# Verificar modelos
ollama list
```

## 🧪 Testes

### Teste Automático

```bash
# Executar todos os testes
python test_pdf.py

# Criar PDF de teste
python test_pdf.py --create-pdf
```

### Teste Manual

1. **Acesse**: http://localhost:8080
2. **Faça upload** de um PDF
3. **Ative o PDF** clicando nele
4. **Faça perguntas** sobre o conteúdo
5. **Verifique respostas** baseadas no documento

### Teste da API

```bash
# Verificar saúde
curl http://localhost:8080/api/health

# Listar PDFs
curl http://localhost:8080/api/pdfs

# Upload de PDF
curl -X POST -F "pdf_file=@teste.pdf" http://localhost:8080/api/upload-pdf

# Chat
curl -X POST -H "Content-Type: application/json" \
  -d '{"message":"Olá","model":"llama2"}' \
  http://localhost:8080/api/chat
```

## 🔍 Debugging

### Logs

```bash
# Ver logs da aplicação
tail -f logs/chat_history.json

# Ver logs do Flask
export FLASK_DEBUG=1
python app.py

# Ver logs do Docker
docker-compose logs -f chatbot
```

### Verificações

```bash
# Verificar dependências
pip list | grep -E "(flask|requests|PyPDF2|pdfplumber)"

# Verificar Ollama
curl http://localhost:11434/api/tags

# Verificar portas
netstat -tlnp | grep 8080

# Verificar arquivos
ls -la uploads/ cache/ logs/
```

## 🐛 Problemas Comuns

### Ambiente Virtual

```bash
# Problema: venv não encontrado
python3 -m venv venv
source venv/bin/activate

# Problema: dependências não instaladas
pip install -r requirements.txt

# Problema: pip desatualizado
pip install --upgrade pip
```

### Ollama

```bash
# Problema: Ollama não responde
ollama serve

# Problema: Modelo não encontrado
ollama pull llama2

# Problema: Porta ocupada
pkill ollama
ollama serve
```

### PDFs

```bash
# Problema: PDF não processa
# Verificar se é um PDF válido
file documento.pdf

# Problema: Dependências PDF
pip install PyPDF2 pdfplumber

# Problema: Cache corrompido
rm -rf cache/*
```

## 📝 Desenvolvimento

### Adicionar Nova Funcionalidade

1. **Criar branch**:
   ```bash
   git checkout -b feature/nova-funcionalidade
   ```

2. **Desenvolver**:
   - Código em `app.py`
   - Templates em `templates/`
   - Estilos em `static/css/`
   - JavaScript em `static/js/`

3. **Testar**:
   ```bash
   python test_pdf.py
   ```

4. **Commit**:
   ```bash
   git add .
   git commit -m "Adiciona nova funcionalidade"
   ```

### Estrutura de Código

```python
# app.py - Endpoints principais
@app.route('/api/nova-funcionalidade', methods=['POST'])
def nova_funcionalidade():
    # Lógica aqui
    pass

# pdf_processor.py - Processamento de PDFs
class PDFProcessor:
    def nova_metodo(self):
        # Lógica aqui
        pass
```

## 🔒 Segurança

### Desenvolvimento

- **Arquivo .env**: Não commitar no Git
- **Uploads**: Validar tipos de arquivo
- **Cache**: Limpar periodicamente
- **Logs**: Não incluir dados sensíveis

### Produção

- **HTTPS**: Usar certificados SSL
- **Firewall**: Configurar regras
- **Backup**: Fazer backup regular
- **Monitoramento**: Logs e métricas

## 📚 Recursos

### Documentação

- **README.md**: Visão geral do projeto
- **PDF_FEATURE.md**: Funcionalidade de PDF
- **PERFORMANCE.md**: Análise de performance
- **DEVELOPMENT.md**: Este guia

### Links Úteis

- **Flask**: https://flask.palletsprojects.com/
- **Ollama**: https://ollama.ai/
- **PyPDF2**: https://pypdf2.readthedocs.io/
- **pdfplumber**: https://github.com/jsvine/pdfplumber

### Comunidade

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Telegram**: @portalsemporteiras

---

**Desenvolvido para a Rede Comunitária Portal Sem Porteiras** 🌐🤖 