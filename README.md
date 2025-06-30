# 🌐 Rede Comunitária - Projeto Educacional de Intranet Local

## 📚 Sobre o Projeto

Este projeto demonstra como criar uma **rede social local** funcionando como uma "mini-internet" dentro de uma rede WiFi mesh comunitária. É uma ferramenta educacional que ensina jovens e adolescentes sobre:

- Como funciona a internet
- Como criar serviços web locais
- Como compartilhar conteúdo em uma rede comunitária
- Conceitos básicos de programação web
- Trabalho colaborativo em tecnologia

## 🎯 Objetivo Educacional

O projeto foi desenvolvido para ser usado em **aulas práticas** onde os alunos podem:
- Ver como a internet funciona "por dentro"
- Criar e compartilhar conteúdo localmente
- Entender conceitos de redes, servidores e clientes
- Desenvolver habilidades técnicas para manutenção de redes comunitárias
- Aprender programação de forma prática e divertida

## 🏗️ Estrutura do Projeto (Evolução Incremental)

O projeto foi desenvolvido em etapas, mostrando a evolução de um servidor simples até uma rede social completa:

### 1. **olamundo/** - Primeiro Servidor Web
```
olamundo/server.py
```
- **O que é**: Um servidor web básico que serve arquivos HTML
- **Como usar**: 
  ```bash
  cd olamundo
  python server.py
  ```
- **Acesso**: `http://IP_DO_COMPUTADOR:8000`
- **Aprendizado**: Conceitos básicos de servidor web e IP local

### 2. **web/** - Versões Simples de Rede Social
```
web/instaSimples.py
web/instav2.py
web/insta.py
```
- **O que é**: Versões incrementais de uma rede social estilo Instagram
- **Evolução**:
  - `instaSimples.py`: Upload de fotos e comentários básicos
  - `instav2.py`: Interface melhorada e mais funcionalidades
  - `insta.py`: Sistema completo com usuários e interações
- **Como usar**:
  ```bash
  cd web
  python instaSimples.py  # ou instav2.py ou insta.py
  ```
- **Aprendizado**: Flask, HTML, CSS, upload de arquivos, banco de dados CSV

### 3. **compose/** - Rede Social Completa
```
compose/
├── app/           # Aplicação principal
├── run.sh         # Script para executar
└── README.md      # Documentação detalhada
```
- **O que é**: Uma rede social completa com todas as funcionalidades
- **Funcionalidades**:
  - Sistema de usuários e login
  - Upload de fotos e PDFs
  - Comentários e curtidas
  - Painel administrativo
  - Timeline personalizada
- **Como usar**:
  ```bash
  cd compose
  chmod +x run.sh
  ./run.sh
  ```
- **Aprendizado**: Flask avançado, SQLite, autenticação, interface responsiva

## 🚀 Como Usar na Rede Comunitária

### Pré-requisitos
- Computador com Python 3.8+
- Conexão na rede WiFi mesh
- Conhecimento básico de terminal

### Passo a Passo

1. **Escolha qual versão usar**:
   - **Iniciantes**: Comece com `olamundo/`
   - **Intermediários**: Use `web/instaSimples.py`
   - **Avançados**: Use `compose/`

2. **Execute o servidor**:
   ```bash
   # Para olamundo
   cd olamundo
   python server.py
   
   # Para web
   cd web
   python instaSimples.py
   
   # Para compose
   cd compose
   ./run.sh
   ```

3. **Acesse de outros dispositivos**:
   - O servidor mostrará o IP local (ex: `192.168.1.100`)
   - Qualquer dispositivo na rede pode acessar: `http://192.168.1.100:8000`
   - Não precisa de internet externa!

4. **Compartilhe o conteúdo**:
   - Faça upload de fotos
   - Escreva comentários
   - Veja o que outros postaram
   - Tudo funciona localmente na rede

## 🎓 Aplicação Educacional

### Para Professores
- **Aula 1**: Conceitos básicos de rede (usando `olamundo/`)
- **Aula 2**: Introdução ao Flask (usando `web/instaSimples.py`)
- **Aula 3**: Desenvolvimento web completo (usando `compose/`)
- **Aula 4**: Manutenção e troubleshooting

### Para Alunos
- **Módulo 1**: "O que é a internet?" - usando servidores simples
- **Módulo 2**: "Como criar uma página web?" - aprendendo HTML e Flask
- **Módulo 3**: "Como fazer uma rede social?" - desenvolvimento completo
- **Módulo 4**: "Como manter uma rede comunitária?" - administração e manutenção

### Conceitos Aprendidos
- **Redes**: IP local, portas, servidores
- **Web**: HTML, CSS, JavaScript
- **Backend**: Python, Flask, banco de dados
- **Sistemas**: Upload de arquivos, autenticação
- **Colaboração**: Trabalho em equipe, compartilhamento

## 🌍 Impacto Comunitário

### Benefícios para a Comunidade
- **Empoderamento tecnológico**: Jovens aprendem a criar e manter sistemas
- **Conectividade local**: Rede social própria da comunidade
- **Economia de dados**: Funciona sem internet externa
- **Preservação cultural**: Conteúdo local e relevante
- **Formação de mão de obra**: Desenvolvedores locais para a rede

### Futuro da Rede Comunitária
- **Manutenção**: Jovens treinados podem manter os sistemas
- **Expansão**: Novos serviços podem ser adicionados
- **Sustentabilidade**: Rede gerida pela própria comunidade
- **Inovação**: Base para novos projetos tecnológicos

## 🔧 Configuração Técnica

### Requisitos do Sistema
- **Sistema Operacional**: Linux, Windows ou macOS
- **Python**: Versão 3.8 ou superior
- **Memória**: Mínimo 2GB RAM
- **Armazenamento**: 1GB livre para uploads

### Configuração de Rede
- **Porta padrão**: 8000 (olamundo/web) ou 5000 (compose)
- **Acesso**: Qualquer dispositivo na rede local
- **Segurança**: Apenas para uso em redes confiáveis

## 📖 Guias de Aprendizado

### Para Iniciantes
1. Comece com `olamundo/server.py`
2. Entenda como funciona um servidor web
3. Experimente acessar de diferentes dispositivos
4. Modifique o HTML para personalizar

### Para Intermediários
1. Use `web/instaSimples.py`
2. Aprenda sobre Flask e templates
3. Adicione novas funcionalidades
4. Experimente com CSS para estilizar

### Para Avançados
1. Use `compose/` (rede social completa)
2. Estude a estrutura do projeto
3. Adicione novas features
4. Otimize para performance

## 🤝 Contribuição e Desenvolvimento

### Como Contribuir
1. **Fork** o projeto
2. **Clone** para sua máquina
3. **Experimente** as diferentes versões
4. **Adicione** novas funcionalidades
5. **Documente** suas mudanças
6. **Compartilhe** com a comunidade

### Ideias para Novos Projetos
- Sistema de notícias locais
- Biblioteca digital comunitária
- Fórum de discussão
- Sistema de eventos
- Mapa colaborativo da comunidade

## 📞 Suporte e Comunidade

### Recursos de Aprendizado
- [Documentação Flask](https://flask.palletsprojects.com/)
- [Tutorial Python](https://docs.python.org/3/tutorial/)
- [HTML/CSS Básico](https://developer.mozilla.org/pt-BR/docs/Web/HTML)

### Comunidade
- **Grupo de Estudos**: Forme grupos para estudar juntos
- **Workshops**: Organize workshops na comunidade
- **Mentoria**: Alunos mais avançados ajudam iniciantes
- **Projetos Colaborativos**: Desenvolvam novos serviços juntos

## 🎉 Conclusão

Este projeto demonstra que **tecnologia pode ser democrática e educacional**. Uma rede comunitária não é apenas sobre conectividade, mas sobre **empoderamento, aprendizado e colaboração**.

Ao ensinar jovens a criar e manter sistemas web locais, estamos:
- **Formando** a próxima geração de desenvolvedores
- **Fortalecendo** a comunidade tecnologicamente
- **Criando** uma base para inovação local
- **Democratizando** o acesso ao conhecimento técnico

**O futuro da internet é local, comunitário e educacional! 🌐✨**

---

*Desenvolvido para fins educacionais e comunitários. Use, aprenda, compartilhe e contribua!* 