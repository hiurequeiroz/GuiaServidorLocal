// Chatbot de IA Local - JavaScript
class ChatbotUI {
    constructor() {
        this.messageInput = document.getElementById('message-input');
        this.sendButton = document.getElementById('send-button');
        this.chatMessages = document.getElementById('chat-messages');
        this.modelSelect = document.getElementById('model-select');
        this.downloadButton = document.getElementById('download-model');
        this.clearButton = document.getElementById('clear-chat');
        this.exportButton = document.getElementById('export-chat');
        this.loadingOverlay = document.getElementById('loading-overlay');
        this.connectionStatus = document.getElementById('connection-status');
        this.connectionText = document.getElementById('connection-text');
        this.modelInfo = document.getElementById('model-info');
        
        this.setupEventListeners();
        this.checkConnection();
        this.loadAvailableModels();
    }

    setupEventListeners() {
        // Enviar mensagem
        this.sendButton.addEventListener('click', () => this.sendMessage());
        this.messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });

        // Baixar modelo
        this.downloadButton.addEventListener('click', () => this.downloadModel());

        // Limpar chat
        this.clearButton.addEventListener('click', () => this.clearChat());

        // Exportar histórico
        this.exportButton.addEventListener('click', () => this.exportChat());

        // Auto-resize do textarea
        this.messageInput.addEventListener('input', () => {
            this.messageInput.style.height = 'auto';
            this.messageInput.style.height = this.messageInput.scrollHeight + 'px';
        });
    }

    async checkConnection() {
        try {
            const response = await fetch('/api/health');
            const data = await response.json();
            
            if (data.ollama === 'connected') {
                this.connectionStatus.classList.add('connected');
                this.connectionText.textContent = 'Conectado';
                this.modelInfo.textContent = `Modelo: ${this.modelSelect.value}`;
            } else {
                this.connectionStatus.classList.remove('connected');
                this.connectionText.textContent = 'Desconectado';
                this.modelInfo.textContent = 'Modelo: Indisponível';
            }
        } catch (error) {
            this.connectionStatus.classList.remove('connected');
            this.connectionText.textContent = 'Erro de conexão';
            this.modelInfo.textContent = 'Modelo: Indisponível';
        }
    }

    async loadAvailableModels() {
        try {
            const response = await fetch('/api/models');
            const data = await response.json();
            
            if (data.models && data.models.length > 0) {
                this.modelSelect.innerHTML = '';
                data.models.forEach(model => {
                    const option = document.createElement('option');
                    option.value = model;
                    option.textContent = model;
                    this.modelSelect.appendChild(option);
                });
            }
        } catch (error) {
            console.error('Erro ao carregar modelos:', error);
        }
    }

    async sendMessage() {
        const message = this.messageInput.value.trim();
        if (!message) return;

        const selectedModel = this.modelSelect.value;
        
        // Adicionar mensagem do usuário
        this.addMessage(message, 'user');
        this.messageInput.value = '';
        this.messageInput.style.height = 'auto';
        
        // Mostrar loading
        this.showLoading();
        
        try {
            const response = await fetch('/api/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    message: message,
                    model: selectedModel
                })
            });

            const data = await response.json();
            
            if (response.ok) {
                this.addMessage(data.response, 'ai');
            } else {
                this.addMessage(`Erro: ${data.error}`, 'system');
            }
        } catch (error) {
            this.addMessage('Erro de conexão. Verifique se o servidor está rodando.', 'system');
        } finally {
            this.hideLoading();
        }
    }

    addMessage(content, type) {
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${type}`;
        
        const contentDiv = document.createElement('div');
        contentDiv.className = 'message-content';
        
        if (type === 'ai') {
            contentDiv.innerHTML = `<i class="fas fa-robot"></i> ${this.formatMessage(content)}`;
        } else if (type === 'user') {
            contentDiv.innerHTML = `<i class="fas fa-user"></i> ${this.formatMessage(content)}`;
        } else {
            contentDiv.innerHTML = `<i class="fas fa-exclamation-triangle"></i> ${this.formatMessage(content)}`;
        }
        
        messageDiv.appendChild(contentDiv);
        this.chatMessages.appendChild(messageDiv);
        
        // Scroll para a última mensagem
        this.chatMessages.scrollTop = this.chatMessages.scrollHeight;
    }

    formatMessage(message) {
        // Converter quebras de linha em <br>
        return message.replace(/\n/g, '<br>');
    }

    async downloadModel() {
        const selectedModel = this.modelSelect.value;
        
        this.downloadButton.disabled = true;
        this.downloadButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Baixando...';
        
        try {
            const response = await fetch('/api/download-model', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    model: selectedModel
                })
            });

            const data = await response.json();
            
            if (response.ok) {
                this.addMessage(`✅ ${data.message}`, 'system');
                await this.loadAvailableModels();
            } else {
                this.addMessage(`❌ Erro: ${data.error}`, 'system');
            }
        } catch (error) {
            this.addMessage('❌ Erro ao baixar modelo', 'system');
        } finally {
            this.downloadButton.disabled = false;
            this.downloadButton.innerHTML = '<i class="fas fa-download"></i> Baixar Modelo';
        }
    }

    clearChat() {
        if (confirm('Tem certeza que deseja limpar todo o histórico de conversas?')) {
            // Manter apenas a mensagem de boas-vindas
            const welcomeMessage = this.chatMessages.querySelector('.message.system');
            this.chatMessages.innerHTML = '';
            if (welcomeMessage) {
                this.chatMessages.appendChild(welcomeMessage);
            }
        }
    }

    async exportChat() {
        try {
            const response = await fetch('/api/history');
            const data = await response.json();
            
            if (data.history && data.history.length > 0) {
                const exportData = {
                    exportDate: new Date().toISOString(),
                    totalMessages: data.history.length,
                    conversations: data.history
                };
                
                const blob = new Blob([JSON.stringify(exportData, null, 2)], {
                    type: 'application/json'
                });
                
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `chatbot-history-${new Date().toISOString().split('T')[0]}.json`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
                
                this.addMessage('✅ Histórico exportado com sucesso!', 'system');
            } else {
                this.addMessage('ℹ️ Nenhuma conversa para exportar.', 'system');
            }
        } catch (error) {
            this.addMessage('❌ Erro ao exportar histórico', 'system');
        }
    }

    showLoading() {
        this.loadingOverlay.classList.remove('hidden');
        this.sendButton.disabled = true;
    }

    hideLoading() {
        this.loadingOverlay.classList.add('hidden');
        this.sendButton.disabled = false;
    }
}

// Inicializar o chatbot quando a página carregar
document.addEventListener('DOMContentLoaded', () => {
    new ChatbotUI();
    
    // Verificar conexão periodicamente
    setInterval(() => {
        const chatbot = window.chatbot;
        if (chatbot) {
            chatbot.checkConnection();
        }
    }, 30000); // Verificar a cada 30 segundos
}); 