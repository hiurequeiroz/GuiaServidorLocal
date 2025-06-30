from flask import Flask, render_template, request, redirect, url_for, send_from_directory, jsonify
import os
import csv
from PIL import Image

# Inicializa a aplicação Flask
app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'  # Define a pasta onde as imagens serão armazenadas
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Criação das pastas e arquivos necessários se não existirem
if not os.path.exists('templates'):
    os.makedirs('templates')
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
if not os.path.exists("comentarios.csv"):
    with open("comentarios.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["foto", "nome", "comentario"])
if not os.path.exists("posts.csv"):
    with open("posts.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["nome", "foto", "comentario"])

# Criação do HTML dinâmico para exibição das postagens
html_content = """<!DOCTYPE html>
<html lang='pt'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Instagram Local</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 20px; margin: 0; }
        h1 { color: #333; font-size: 2em; }
        .post { margin-top: 20px; border-bottom: 1px solid #ccc; padding-bottom: 10px; }
        img { max-width: 100%; height: auto; margin-top: 10px; }
        form { margin-top: 20px; }
        input, textarea { width: 80%; padding: 10px; margin-top: 10px; }
        button { padding: 10px 20px; font-size: 1em; cursor: pointer; }
        .comentarios { margin-top: 10px; padding: 10px; background: #f9f9f9; border-radius: 5px; text-align: left; max-height: 200px; overflow-y: auto; }
        .comentario { margin-bottom: 5px; }
    </style>
</head>
<body>
    <h1>Instagram Local</h1>
    {% for post in posts %}
    <div class="post">
        <p><strong>{{ post[0] }}</strong></p>
        <img src="{{ url_for('uploaded_file', filename=post[1]) }}" alt="Imagem postada">
        <p>{{ post[2] }}</p>
    </div>
    {% endfor %}
</body>
</html>"""

# Salvar o HTML no diretório templates
with open("templates/index.html", "w") as f:
    f.write(html_content)

@app.route('/')
def home():
    """Carrega os posts e renderiza a página inicial."""
    posts = []
    if os.path.exists("posts.csv"):
        with open("posts.csv", "r", encoding="utf-8") as f:
            reader = csv.reader(f)
            posts = list(reader)
    return render_template('index.html', posts=posts)

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    """Serve as imagens armazenadas no diretório uploads."""
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

if __name__ == '__main__':
    from socket import gethostbyname, gethostname
    local_ip = gethostbyname(gethostname())
    app.run(host='0.0.0.0', port=8000, debug=True)