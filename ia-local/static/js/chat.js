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
        this.clearPdfsButton = document.getElementById('clear-pdfs');
        this.loadingOverlay = document.getElementById('loading-overlay');
        this.connectionStatus = document.getElementById('connection-status');
        this.connectionText = document.getElementById('connection-text');
        this.modelInfo = document.getElementById('model-info');
        this.pdfStatus = document.getElementById('pdf-status');
        this.pdfInfo = document.getElementById('pdf-info');
        
        // PDF elements
        this.uploadPdfBtn = document.getElementById('upload-pdf-btn');
        this.pdfList = document.getElementById('pdf-list');
        this.pdfModal = document.getElementById('pdf-modal');
        this.closeModal = document.getElementById('close-modal');
        this.modalPdfInput = document.getElementById('modal-pdf-input');
        this.modalSelectBtn = document.getElementById('modal-select-btn');
        this.uploadZone = document.getElementById('upload-zone');
        this.uploadProgress = document.getElementById('upload-progress');
        this.progressFill = document.getElementById('progress-fill');
        this.progressText = document.getElementById('progress-text');
        
        this.activePdfHash = null;
        this.pdfs = [];
        
        this.setupEventListeners();
        this.checkConnection();
        this.loadAvailableModels();
        this.loadPDFs();
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

        // Limpar PDFs
        this.clearPdfsButton.addEventListener('click', () => this.clearPDFs());

        // Auto-resize do textarea
        this.messageInput.addEventListener('input', () => {
            this.messageInput.style.height = 'auto';
            this.messageInput.style.height = this.messageInput.scrollHeight + 'px';
        });

        // PDF upload
        this.uploadPdfBtn.addEventListener('click', () => this.showPDFModal());
        this.closeModal.addEventListener('click', () => this.hidePDFModal());
        this.modalSelectBtn.addEventListener('click', () => this.modalPdfInput.click());
        this.modalPdfInput.addEventListener('change', (e) => this.handlePDFUpload(e));

        // Drag and drop
        this.uploadZone.addEventListener('dragover', (e) => {
            e.preventDefault();
            this.uploadZone.style.borderColor = '#667eea';
        });

        this.uploadZone.addEventListener('dragleave', (e) => {
            e.preventDefault();
            this.uploadZone.style.borderColor = '#dee2e6';
        });

        this.uploadZone.addEventListener('drop', (e) => {
            e.preventDefault();
            this.uploadZone.style.borderColor = '#dee2e6';
            const files = e.dataTransfer.files;
            if (files.length > 0 && files[0].type === 'application/pdf') {
                this.uploadPDFFile(files[0]);
            }
        });

        // Modal backdrop click
        this.pdfModal.addEventListener('click', (e) => {
            if (e.target === this.pdfModal) {
                this.hidePDFModal();
            }
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

    async loadPDFs() {
        try {
            const response = await fetch('/api/pdfs');
            const data = await response.json();
            
            if (data.pdfs) {
                this.pdfs = data.pdfs;
                this.renderPDFList();
            }
        } catch (error) {
            console.error('Erro ao carregar PDFs:', error);
        }
    }

    renderPDFList() {
        if (this.pdfs.length === 0) {
            this.pdfList.innerHTML = `
                <div class="pdf-empty">
                    <i class="fas fa-file-pdf"></i>
                    <p>Nenhum PDF carregado</p>
                    <p>Faça upload de um PDF para começar</p>
                </div>
            `;
            return;
        }

        this.pdfList.innerHTML = this.pdfs.map(pdf => `
            <div class="pdf-item ${pdf.hash === this.activePdfHash ? 'active' : ''}" data-hash="${pdf.hash}">
                <div class="pdf-item-header">
                    <div>
                        <div class="pdf-item-title">${pdf.name}</div>
                        <div class="pdf-item-meta">
                            <span><i class="fas fa-file"></i> ${this.formatFileSize(pdf.size)}</span>
                            <span><i class="fas fa-copy"></i> ${pdf.pages} páginas</span>
                            <span><i class="fas fa-text-width"></i> ${this.formatTextLength(pdf.text_length)}</span>
                        </div>
                    </div>
                    <div class="pdf-item-actions">
                        <button class="pdf-action-btn delete" onclick="chatbot.deletePDF('${pdf.hash}')" title="Remover PDF">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
            </div>
        `).join('');

        // Add click listeners
        this.pdfList.querySelectorAll('.pdf-item').forEach(item => {
            item.addEventListener('click', (e) => {
                if (!e.target.closest('.pdf-action-btn')) {
                    const hash = item.dataset.hash;
                    this.setActivePDF(hash);
                }
            });
        });
    }

    setActivePDF(hash) {
        this.activePdfHash = hash;
        this.renderPDFList();
        this.updatePDFStatus();
        
        // Add system message about active PDF
        const pdf = this.pdfs.find(p => p.hash === hash);
        if (pdf) {
            this.addMessage(`📄 PDF ativo: "${pdf.name}" - Agora a IA responderá baseada neste documento.`, 'system');
        }
    }

    updatePDFStatus() {
        if (this.activePdfHash) {
            const pdf = this.pdfs.find(p => p.hash === this.activePdfHash);
            if (pdf) {
                this.pdfStatus.style.display = 'flex';
                this.pdfInfo.textContent = `PDF: ${pdf.name}`;
            }
        } else {
            this.pdfStatus.style.display = 'none';
        }
    }

    formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    formatTextLength(length) {
        if (length < 1000) return length + ' chars';
        return (length / 1000).toFixed(1) + 'k chars';
    }

    showPDFModal() {
        this.pdfModal.classList.remove('hidden');
    }

    hidePDFModal() {
        this.pdfModal.classList.add('hidden');
        this.uploadZone.style.display = 'block';
        this.uploadProgress.style.display = 'none';
        this.modalPdfInput.value = '';
    }

    handlePDFUpload(event) {
        const file = event.target.files[0];
        if (file) {
            this.uploadPDFFile(file);
        }
    }

    async uploadPDFFile(file) {
        if (file.type !== 'application/pdf') {
            this.addMessage('❌ Apenas arquivos PDF são permitidos.', 'system');
            return;
        }

        if (file.size > 16 * 1024 * 1024) { // 16MB
            this.addMessage('❌ Arquivo muito grande. Máximo 16MB.', 'system');
            return;
        }

        const formData = new FormData();
        formData.append('pdf_file', file);

        // Show progress
        this.uploadZone.style.display = 'none';
        this.uploadProgress.style.display = 'block';
        this.progressFill.style.width = '0%';
        this.progressText.textContent = 'Enviando PDF...';

        try {
            const response = await fetch('/api/upload-pdf', {
                method: 'POST',
                body: formData
            });

            const data = await response.json();

            if (response.ok) {
                this.progressFill.style.width = '100%';
                this.progressText.textContent = 'PDF processado com sucesso!';
                
                setTimeout(() => {
                    this.hidePDFModal();
                    this.addMessage(`✅ ${data.message}`, 'system');
                    this.loadPDFs();
                }, 1000);
            } else {
                this.addMessage(`❌ Erro: ${data.error}`, 'system');
                this.hidePDFModal();
            }
        } catch (error) {
            this.addMessage('❌ Erro ao fazer upload do PDF', 'system');
            this.hidePDFModal();
        }
    }

    async deletePDF(hash) {
        if (!confirm('Tem certeza que deseja remover este PDF?')) {
            return;
        }

        try {
            const response = await fetch(`/api/pdfs/${hash}`, {
                method: 'DELETE'
            });

            const data = await response.json();

            if (response.ok) {
                this.addMessage(`✅ ${data.message}`, 'system');
                
                // Remove from active if it was active
                if (this.activePdfHash === hash) {
                    this.activePdfHash = null;
                    this.updatePDFStatus();
                }
                
                this.loadPDFs();
            } else {
                this.addMessage(`❌ Erro: ${data.error}`, 'system');
            }
        } catch (error) {
            this.addMessage('❌ Erro ao remover PDF', 'system');
        }
    }

    async clearPDFs() {
        if (!confirm('Tem certeza que deseja remover todos os PDFs?')) {
            return;
        }

        try {
            // Remove each PDF
            for (const pdf of this.pdfs) {
                await fetch(`/api/pdfs/${pdf.hash}`, {
                    method: 'DELETE'
                });
            }

            this.activePdfHash = null;
            this.updatePDFStatus();
            this.loadPDFs();
            this.addMessage('✅ Todos os PDFs foram removidos.', 'system');
        } catch (error) {
            this.addMessage('❌ Erro ao limpar PDFs', 'system');
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
                    model: selectedModel,
                    pdf_context: this.activePdfHash
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
                const chatText = data.history.map(entry => {
                    const timestamp = new Date(entry.timestamp).toLocaleString('pt-BR');
                    return `[${timestamp}] Usuário: ${entry.user_message}\n[${timestamp}] IA: ${entry.ai_response}\n\n`;
                }).join('');
                
                const blob = new Blob([chatText], { type: 'text/plain;charset=utf-8' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `chat_history_${new Date().toISOString().split('T')[0]}.txt`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
                
                this.addMessage('✅ Histórico exportado com sucesso!', 'system');
            } else {
                this.addMessage('ℹ️ Nenhum histórico para exportar.', 'system');
            }
        } catch (error) {
            this.addMessage('❌ Erro ao exportar histórico', 'system');
        }
    }

    showLoading() {
        this.loadingOverlay.classList.remove('hidden');
    }

    hideLoading() {
        this.loadingOverlay.classList.add('hidden');
    }
}

// Inicializar chatbot quando a página carregar
let chatbot;
document.addEventListener('DOMContentLoaded', () => {
    chatbot = new ChatbotUI();
    
    // Verificar conexão periodicamente
    setInterval(() => {
        if (chatbot) {
            chatbot.checkConnection();
        }
    }, 30000); // Verificar a cada 30 segundos
}); 