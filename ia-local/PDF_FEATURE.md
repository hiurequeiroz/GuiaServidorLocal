# 📄 Funcionalidade de PDF - Chatbot IA Local

## Visão Geral

A funcionalidade de PDF permite que usuários façam upload de documentos PDF e conversem com a IA baseada no conteúdo desses documentos. Isso é especialmente útil para redes comunitárias que precisam processar documentação local, manuais, regulamentos e outros materiais.

## 🎯 Casos de Uso

### Para Redes Comunitárias

1. **Documentação Local**
   - Manuais de configuração de rede
   - Regulamentos da comunidade
   - Procedimentos operacionais
   - Guias de troubleshooting

2. **Educação e Treinamento**
   - Apostilas de cursos
   - Material didático
   - Tutoriais técnicos
   - Documentação de projetos

3. **Administração**
   - Relatórios mensais
   - Formulários de cadastro
   - Políticas de uso
   - Documentos de reuniões

4. **Pesquisa e Análise**
   - Documentos históricos
   - Estudos técnicos
   - Análises de performance
   - Relatórios de incidentes

## 🔧 Como Funciona

### 1. Upload de PDF
- Interface drag-and-drop ou seleção de arquivo
- Validação de tipo e tamanho (máximo 16MB)
- Processamento automático em background

### 2. Extração de Texto
- **PyPDF2**: Extração básica de texto
- **pdfplumber**: Extração avançada com suporte a tabelas
- **Fallback**: Se um método falha, tenta o outro
- **Cache**: Resultados são cacheados para evitar reprocessamento

### 3. Processamento de Contexto
- Limitação de 2000 caracteres para não sobrecarregar a IA
- Preservação de estrutura e formatação
- Extração de metadados (título, autor, páginas)

### 4. Integração com Chat
- Contexto do PDF é incluído no prompt da IA
- IA responde baseada no conteúdo do documento
- Histórico inclui referência ao PDF usado

## 📊 Especificações Técnicas

### Limitações
- **Tamanho máximo**: 16MB por arquivo
- **Contexto máximo**: 2000 caracteres
- **Formatos**: Apenas PDF
- **Cache**: Ilimitado (limitado pelo espaço em disco)

### Performance
- **Processamento**: 1-5 segundos por PDF (depende do tamanho)
- **Cache**: Processamento instantâneo para PDFs já processados
- **Memória**: ~50MB por PDF em cache

### Segurança
- **Validação**: Tipo de arquivo e tamanho
- **Isolamento**: PDFs ficam em diretório separado
- **Limpeza**: Arquivos removidos quando PDF é deletado

## 🎮 Como Usar

### Interface Web

1. **Acesse a interface**: http://localhost:8080
2. **Clique em "Upload PDF"** no painel lateral
3. **Selecione um arquivo PDF** ou arraste para a área
4. **Aguarde o processamento** (barra de progresso)
5. **Clique no PDF** na lista para ativá-lo
6. **Faça perguntas** sobre o conteúdo do documento

### Exemplos de Perguntas

```
"Resuma o conteúdo deste documento"
"Quais são os principais pontos do manual?"
"Explique o procedimento de configuração"
"Liste as regras mencionadas no documento"
"Qual é o objetivo deste relatório?"
```

### Comandos via API

```bash
# Listar PDFs
curl http://localhost:8080/api/pdfs

# Upload de PDF
curl -X POST -F "pdf_file=@documento.pdf" http://localhost:8080/api/upload-pdf

# Chat com PDF
curl -X POST -H "Content-Type: application/json" \
  -d '{"message":"Resuma o documento","pdf_context":"hash_do_pdf"}' \
  http://localhost:8080/api/chat

# Obter contexto
curl http://localhost:8080/api/pdfs/hash_do_pdf/context

# Remover PDF
curl -X DELETE http://localhost:8080/api/pdfs/hash_do_pdf
```

## 🛠️ Manutenção

### Backup de PDFs

```bash
# Backup completo
tar czf backup-pdfs-$(date +%Y%m%d).tar.gz uploads/ cache/

# Backup apenas cache (metadados)
tar czf backup-cache-$(date +%Y%m%d).tar.gz cache/
```

### Limpeza

```bash
# Limpar cache
rm -rf cache/*

# Limpar uploads
rm -rf uploads/*

# Limpar logs antigos
find logs/ -name "*.json" -mtime +30 -delete
```

### Monitoramento

```bash
# Verificar espaço usado
du -sh uploads/ cache/

# Verificar número de PDFs
ls uploads/ | wc -l

# Verificar cache
ls cache/ | wc -l
```

## 🔍 Troubleshooting

### Problemas Comuns

1. **PDF não processa**
   ```bash
   # Verificar dependências
   docker-compose exec chatbot pip list | grep -E "(PyPDF2|pdfplumber)"
   
   # Verificar logs
   docker-compose logs chatbot | grep -i pdf
   ```

2. **Texto não extraído**
   - PDF pode ser uma imagem escaneada
   - PDF pode ter proteção contra cópia
   - PDF pode estar corrompido

3. **Upload falha**
   ```bash
   # Verificar tamanho do arquivo
   ls -lh arquivo.pdf
   
   # Verificar espaço em disco
   df -h
   ```

4. **Contexto muito grande**
   - Sistema limita automaticamente a 2000 caracteres
   - PDFs muito grandes podem ter conteúdo truncado

### Logs Úteis

```bash
# Logs de upload
docker-compose logs chatbot | grep -i "upload"

# Logs de processamento
docker-compose logs chatbot | grep -i "pdf"

# Logs de erro
docker-compose logs chatbot | grep -i "error"
```

## 📈 Melhorias Futuras

### Planejadas
- [ ] Suporte a OCR para PDFs escaneados
- [ ] Processamento de tabelas e imagens
- [ ] Busca semântica no conteúdo
- [ ] Anotações e marcações
- [ ] Compartilhamento de PDFs entre usuários

### Possíveis
- [ ] Suporte a outros formatos (DOCX, TXT)
- [ ] Processamento em lote
- [ ] Indexação avançada
- [ ] Integração com sistemas externos

## 🧪 Testes

### Script de Teste Automático

```bash
# Executar testes
python test_pdf.py

# Criar PDF de teste
python test_pdf.py --create-pdf
```

### Teste Manual

1. **Criar PDF de teste** com conteúdo conhecido
2. **Fazer upload** via interface web
3. **Verificar processamento** na lista de PDFs
4. **Ativar PDF** clicando nele
5. **Fazer perguntas** sobre o conteúdo
6. **Verificar respostas** baseadas no documento

## 📚 Exemplos Práticos

### Manual de Rede
```
PDF: "Manual_Configuracao_Rede.pdf"
Pergunta: "Como configurar um novo nó na rede?"
Resposta: Baseada nas instruções do manual
```

### Regulamento
```
PDF: "Regulamento_Comunidade.pdf"
Pergunta: "Quais são as regras para uso do servidor?"
Resposta: Baseada no regulamento
```

### Relatório
```
PDF: "Relatorio_Mensal.pdf"
Pergunta: "Resuma os principais pontos do relatório"
Resposta: Baseada no conteúdo do relatório
```

---

**Desenvolvido para a Rede Comunitária Portal Sem Porteiras** 🌐🤖 