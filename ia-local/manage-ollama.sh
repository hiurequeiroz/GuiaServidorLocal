#!/bin/bash

# Script para Gerenciar Container Ollama
# Portal Sem Porteiras - Rede Comunitária

set -e

echo "🤖 Gerenciador do Container Ollama"
echo "🌐 Portal Sem Porteiras - Rede Comunitária"
echo ""

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  start     - Iniciar container Ollama"
    echo "  stop      - Parar container Ollama"
    echo "  restart   - Reiniciar container Ollama"
    echo "  status    - Verificar status do container"
    echo "  logs      - Ver logs do container"
    echo "  models    - Listar modelos disponíveis"
    echo "  backup    - Fazer backup dos modelos"
    echo "  restore   - Restaurar container se necessário"
    echo "  help      - Mostrar esta ajuda"
    echo ""
}

# Função para verificar se container está rodando
is_ollama_running() {
    docker ps --format "table {{.Names}}" | grep -q "^ollama$"
}

# Função para verificar se volume existe
volume_exists() {
    docker volume ls | grep -q "ia-local_ollama_data"
}

# Função para iniciar Ollama
start_ollama() {
    echo "🚀 Iniciando container Ollama..."
    
    if is_ollama_running; then
        echo "✅ Container Ollama já está rodando"
        return 0
    fi
    
    if volume_exists; then
        echo "📦 Usando volume existente ia-local_ollama_data"
        docker run -d \
          --name ollama \
          --restart unless-stopped \
          -v ia-local_ollama_data:/root/.ollama \
          -p 11434:11434 \
          --gpus all \
          ollama/ollama:latest
        echo "✅ Container Ollama iniciado com sucesso"
    else
        echo "❌ Volume ia-local_ollama_data não encontrado"
        echo "💡 Execute primeiro: $0 backup"
        return 1
    fi
}

# Função para parar Ollama
stop_ollama() {
    echo "🛑 Parando container Ollama..."
    if is_ollama_running; then
        docker stop ollama
        docker rm ollama
        echo "✅ Container Ollama parado e removido"
    else
        echo "⚠️  Container Ollama não está rodando"
    fi
}

# Função para reiniciar Ollama
restart_ollama() {
    echo "🔄 Reiniciando container Ollama..."
    stop_ollama
    sleep 2
    start_ollama
}

# Função para verificar status
status_ollama() {
    echo "📊 Status do Container Ollama:"
    echo ""
    
    if is_ollama_running; then
        echo "✅ Container: RODANDO"
        docker ps --filter "name=ollama" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        
        # Verificar conectividade
        if curl -s "http://localhost:11434/api/tags" > /dev/null 2>&1; then
            echo "✅ API: RESPONDENDO"
        else
            echo "❌ API: NÃO RESPONDE"
        fi
        
        # Listar modelos
        echo ""
        echo "📚 Modelos disponíveis:"
        docker exec -it ollama ollama list 2>/dev/null || echo "⚠️  Não foi possível listar modelos"
    else
        echo "❌ Container: PARADO"
    fi
    
    echo ""
    echo "💾 Volume:"
    if volume_exists; then
        echo "✅ ia-local_ollama_data: EXISTE"
        docker volume inspect ia-local_ollama_data --format "{{.Mountpoint}}" 2>/dev/null | xargs ls -la 2>/dev/null || echo "⚠️  Não foi possível verificar conteúdo"
    else
        echo "❌ ia-local_ollama_data: NÃO EXISTE"
    fi
}

# Função para ver logs
logs_ollama() {
    if is_ollama_running; then
        echo "📋 Logs do Container Ollama:"
        docker logs -f ollama
    else
        echo "❌ Container Ollama não está rodando"
        echo "💡 Execute: $0 start"
    fi
}

# Função para listar modelos
list_models() {
    if is_ollama_running; then
        echo "📚 Modelos disponíveis:"
        docker exec -it ollama ollama list
    else
        echo "❌ Container Ollama não está rodando"
        echo "💡 Execute: $0 start"
    fi
}

# Função para backup
backup_ollama() {
    echo "💾 Fazendo backup dos modelos..."
    
    if volume_exists; then
        echo "✅ Volume ia-local_ollama_data já existe"
        echo "📦 Backup automático: os modelos já estão preservados no volume Docker"
        echo "💡 Para backup manual, execute:"
        echo "   docker run --rm -v ia-local_ollama_data:/data -v \$(pwd):/backup alpine tar czf /backup/ollama-backup-\$(date +%Y%m%d).tar.gz -C /data ."
    else
        echo "⚠️  Volume ia-local_ollama_data não existe"
        echo "💡 Execute primeiro: $0 start"
    fi
}

# Função para restaurar
restore_ollama() {
    echo "🔄 Restaurando container Ollama..."
    
    if is_ollama_running; then
        echo "✅ Container Ollama já está rodando"
        return 0
    fi
    
    if volume_exists; then
        echo "📦 Restaurando com volume existente..."
        start_ollama
    else
        echo "❌ Volume ia-local_ollama_data não encontrado"
        echo "💡 Não é possível restaurar sem o volume"
        return 1
    fi
}

# Processar comando
case "${1:-help}" in
    start)
        start_ollama
        ;;
    stop)
        stop_ollama
        ;;
    restart)
        restart_ollama
        ;;
    status)
        status_ollama
        ;;
    logs)
        logs_ollama
        ;;
    models)
        list_models
        ;;
    backup)
        backup_ollama
        ;;
    restore)
        restore_ollama
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ Comando inválido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac 