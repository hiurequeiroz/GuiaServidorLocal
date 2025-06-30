#!/usr/bin/env python3
"""
Processador de PDFs para o Chatbot de IA Local
Extrai texto de PDFs para uso como contexto nas conversas
"""

import os
import json
import hashlib
from datetime import datetime
import PyPDF2
import pdfplumber
from typing import Dict, List, Optional

class PDFProcessor:
    def __init__(self, upload_dir: str = 'uploads', cache_dir: str = 'cache'):
        self.upload_dir = upload_dir
        self.cache_dir = cache_dir
        self.cache_file = os.path.join(cache_dir, 'pdf_cache.json')
        
        # Criar diretórios se não existirem
        os.makedirs(upload_dir, exist_ok=True)
        os.makedirs(cache_dir, exist_ok=True)
        
        # Carregar cache existente
        self.cache = self._load_cache()
    
    def _load_cache(self) -> Dict:
        """Carrega cache de PDFs processados"""
        if os.path.exists(self.cache_file):
            try:
                with open(self.cache_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                return {}
        return {}
    
    def _save_cache(self):
        """Salva cache de PDFs processados"""
        try:
            with open(self.cache_file, 'w', encoding='utf-8') as f:
                json.dump(self.cache, f, ensure_ascii=False, indent=2)
        except Exception as e:
            print(f"Erro ao salvar cache: {e}")
    
    def _get_file_hash(self, file_path: str) -> str:
        """Gera hash do arquivo para cache"""
        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    
    def extract_text_from_pdf(self, file_path: str) -> Dict:
        """
        Extrai texto de um PDF usando múltiplos métodos
        Retorna dicionário com texto e metadados
        """
        file_hash = self._get_file_hash(file_path)
        
        # Verificar cache
        if file_hash in self.cache:
            cached_data = self.cache[file_hash]
            # Verificar se o arquivo ainda existe
            if os.path.exists(cached_data['file_path']):
                return cached_data
        
        try:
            # Extrair texto usando PyPDF2
            text_pypdf2 = ""
            try:
                with open(file_path, 'rb') as file:
                    pdf_reader = PyPDF2.PdfReader(file)
                    for page in pdf_reader.pages:
                        text_pypdf2 += page.extract_text() + "\n"
            except Exception as e:
                print(f"Erro PyPDF2: {e}")
            
            # Extrair texto usando pdfplumber (mais robusto)
            text_pdfplumber = ""
            try:
                with pdfplumber.open(file_path) as pdf:
                    for page in pdf.pages:
                        page_text = page.extract_text()
                        if page_text:
                            text_pdfplumber += page_text + "\n"
            except Exception as e:
                print(f"Erro pdfplumber: {e}")
            
            # Usar o melhor resultado
            if text_pdfplumber.strip():
                final_text = text_pdfplumber
            elif text_pypdf2.strip():
                final_text = text_pypdf2
            else:
                final_text = ""
            
            # Extrair metadados
            metadata = self._extract_metadata(file_path)
            
            # Preparar resultado
            result = {
                'file_path': file_path,
                'file_name': os.path.basename(file_path),
                'file_size': os.path.getsize(file_path),
                'text': final_text,
                'text_length': len(final_text),
                'pages': metadata.get('pages', 0),
                'title': metadata.get('title', ''),
                'author': metadata.get('author', ''),
                'subject': metadata.get('subject', ''),
                'processed_at': datetime.now().isoformat(),
                'file_hash': file_hash
            }
            
            # Salvar no cache
            self.cache[file_hash] = result
            self._save_cache()
            
            return result
            
        except Exception as e:
            return {
                'error': f'Erro ao processar PDF: {str(e)}',
                'file_path': file_path,
                'file_name': os.path.basename(file_path)
            }
    
    def _extract_metadata(self, file_path: str) -> Dict:
        """Extrai metadados do PDF"""
        try:
            with open(file_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)
                info = pdf_reader.metadata
                
                return {
                    'pages': len(pdf_reader.pages),
                    'title': info.get('/Title', ''),
                    'author': info.get('/Author', ''),
                    'subject': info.get('/Subject', ''),
                    'creator': info.get('/Creator', ''),
                    'producer': info.get('/Producer', '')
                }
        except:
            return {'pages': 0}
    
    def get_uploaded_pdfs(self) -> List[Dict]:
        """Lista todos os PDFs processados"""
        pdfs = []
        for file_hash, data in self.cache.items():
            if os.path.exists(data['file_path']):
                pdfs.append({
                    'hash': file_hash,
                    'name': data['file_name'],
                    'size': data['file_size'],
                    'pages': data.get('pages', 0),
                    'text_length': data.get('text_length', 0),
                    'processed_at': data.get('processed_at', ''),
                    'title': data.get('title', ''),
                    'author': data.get('author', '')
                })
        
        # Ordenar por data de processamento (mais recente primeiro)
        pdfs.sort(key=lambda x: x['processed_at'], reverse=True)
        return pdfs
    
    def get_pdf_context(self, file_hash: str, max_length: int = 2000) -> Optional[str]:
        """
        Obtém contexto do PDF para usar no chat
        Limita o tamanho para não sobrecarregar o modelo
        """
        if file_hash not in self.cache:
            return None
        
        data = self.cache[file_hash]
        text = data.get('text', '')
        
        if not text:
            return None
        
        # Limitar tamanho do contexto
        if len(text) > max_length:
            text = text[:max_length] + "..."
        
        return f"Contexto do PDF '{data['file_name']}':\n{text}\n\n"
    
    def delete_pdf(self, file_hash: str) -> bool:
        """Remove PDF do cache e arquivo"""
        if file_hash not in self.cache:
            return False
        
        try:
            file_path = self.cache[file_hash]['file_path']
            
            # Remover arquivo
            if os.path.exists(file_path):
                os.remove(file_path)
            
            # Remover do cache
            del self.cache[file_hash]
            self._save_cache()
            
            return True
        except Exception as e:
            print(f"Erro ao deletar PDF: {e}")
            return False
    
    def clear_cache(self):
        """Limpa todo o cache"""
        self.cache = {}
        self._save_cache() 