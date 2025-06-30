#!/usr/bin/env python3
"""
Processador de PDFs para o Chatbot de IA Local
Extrai texto de PDFs para uso como contexto nas conversas
Suporte a OCR para PDFs de imagem
"""

import os
import json
import hashlib
from datetime import datetime
import PyPDF2
import pdfplumber
import pytesseract
from pdf2image import convert_from_path
from PIL import Image
from typing import Dict, List, Optional

class PDFProcessor:
    def __init__(self, upload_dir: str = 'uploads', cache_dir: str = 'cache', enable_ocr: bool = True):
        self.upload_dir = upload_dir
        self.cache_dir = cache_dir
        self.cache_file = os.path.join(cache_dir, 'pdf_cache.json')
        self.enable_ocr = enable_ocr
        
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
    
    def _extract_text_normal(self, file_path: str) -> str:
        """Extrai texto usando métodos normais (PyPDF2 + pdfplumber)"""
        text = ""
        
        # Tentar PyPDF2
        try:
            with open(file_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)
                for page in pdf_reader.pages:
                    page_text = page.extract_text()
                    if page_text:
                        text += page_text + "\n"
        except Exception as e:
            print(f"Erro PyPDF2: {e}")
        
        # Se PyPDF2 não funcionou, tentar pdfplumber
        if not text.strip():
            try:
                with pdfplumber.open(file_path) as pdf:
                    for page in pdf.pages:
                        page_text = page.extract_text()
                        if page_text:
                            text += page_text + "\n"
            except Exception as e:
                print(f"Erro pdfplumber: {e}")
        
        return text
    
    def _extract_text_with_ocr(self, file_path: str, max_pages: int = 10) -> str:
        """Extrai texto usando OCR (Tesseract)"""
        if not self.enable_ocr:
            return ""
        
        try:
            print(f"🔄 Processando OCR para {os.path.basename(file_path)}...")
            
            # Converter PDF para imagens
            images = convert_from_path(file_path, first_page=1, last_page=min(max_pages, 10))
            
            text = ""
            total_pages = len(images)
            
            for i, image in enumerate(images):
                print(f"  📄 Processando página {i+1}/{total_pages}...")
                
                # Configurar Tesseract para português
                config = '--oem 3 --psm 6 -l por+eng'
                
                # Extrair texto da imagem
                page_text = pytesseract.image_to_string(image, config=config)
                
                if page_text.strip():
                    text += f"--- Página {i+1} ---\n{page_text.strip()}\n\n"
                
                # Limitar processamento para não sobrecarregar
                if i >= max_pages - 1:
                    text += f"\n[Processamento limitado a {max_pages} páginas para performance]"
                    break
            
            print(f"✅ OCR concluído: {len(text)} caracteres extraídos")
            return text
            
        except Exception as e:
            print(f"❌ Erro no OCR: {e}")
            return ""
    
    def _is_pdf_image_based(self, file_path: str) -> bool:
        """Detecta se o PDF é baseado em imagem (sem texto extraível)"""
        # Tentar extrair texto normal
        normal_text = self._extract_text_normal(file_path)
        
        # Se não conseguiu extrair texto ou extraiu muito pouco, provavelmente é imagem
        if not normal_text.strip() or len(normal_text.strip()) < 100:
            return True
        
        return False
    
    def extract_text_from_pdf(self, file_path: str) -> Dict:
        """
        Extrai texto de um PDF usando múltiplos métodos
        Detecta automaticamente se é PDF de texto ou imagem
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
            # Extrair metadados primeiro
            metadata = self._extract_metadata(file_path)
            
            # Detectar tipo de PDF
            is_image_based = self._is_pdf_image_based(file_path)
            
            # Extrair texto baseado no tipo
            if is_image_based and self.enable_ocr:
                print(f"📷 PDF detectado como imagem, usando OCR...")
                final_text = self._extract_text_with_ocr(file_path)
                extraction_method = "ocr"
            else:
                print(f"📄 PDF detectado como texto, extraindo normalmente...")
                final_text = self._extract_text_normal(file_path)
                extraction_method = "normal"
            
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
                'file_hash': file_hash,
                'extraction_method': extraction_method,
                'is_image_based': is_image_based
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
                    'author': data.get('author', ''),
                    'extraction_method': data.get('extraction_method', 'unknown'),
                    'is_image_based': data.get('is_image_based', False)
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
        
        method_info = ""
        if data.get('extraction_method') == 'ocr':
            method_info = " (processado com OCR)"
        
        return f"Contexto do PDF '{data['file_name']}'{method_info}:\n{text}\n\n"
    
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