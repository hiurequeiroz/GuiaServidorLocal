from flask import Flask, render_template, request, redirect, url_for, send_from_directory, jsonify
import os
import csv
from PIL import Image

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Criar diretórios se não existirem
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

# Criar um arquivo HTML básico
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
        img { max-width: 100%; height: auto; margin-top: 10px; cursor: pointer; }
        form { margin-top: 20px; }
        input, textarea { width: 80%; padding: 10px; margin-top: 10px; }
        button { padding: 10px 20px; font-size: 1em; cursor: pointer; }
        .comentarios { margin-top: 10px; padding: 10px; background: #f9f9f9; border-radius: 5px; text-align: left; max-height: 200px; overflow-y: auto; }
        .comentario { margin-bottom: 5px; }
        #modal { display: none; position: fixed; z-index: 10; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.9); justify-content: center; align-items: center; flex-direction: column; }
        #modal img { max-width: 80%; max-height: 70%; border-radius: 10px; }
        #modalComentarios { color: white; background: rgba(0, 0, 0, 0.8); padding: 10px; border-radius: 10px; width: 80%; max-width: 500px; text-align: left; max-height: 150px; overflow-y: auto; }
        #closeModal { position: absolute; top: 15px; right: 25px; font-size: 30px; color: white; cursor: pointer; }
    </style>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            document.getElementById('modal').style.display = 'none';
        });
        function openModal(src, fotoId) {
            document.getElementById('modalImg').src = src;
            document.getElementById('modal').style.display = 'flex';
            carregarComentarios(fotoId);
        }
        function closeModal(event) {
            if (event.target.id === 'modal' || event.target.id === 'closeModal') {
                document.getElementById('modal').style.display = 'none';
                document.getElementById('modalComentarios').innerHTML = '';
            }
        }
        function carregarComentarios(fotoId) {
            fetch('/comentarios/' + fotoId)
                .then(response => response.json())
                .then(data => {
                    let comentariosDiv = document.getElementById('modalComentarios');
                    comentariosDiv.innerHTML = '<h4>Comentários:</h4>';
                    data.forEach(comentario => {
                        comentariosDiv.innerHTML += `<p><strong>${comentario.nome}</strong>: ${comentario.comentario}</p>`;
                    });
                });
        }
    </script>
</head>
<body>
    <h1>Instagram Local</h1>
    <div id="modal" onclick="closeModal(event)">
        <span id="closeModal">&times;</span>
        <img id="modalImg" src="" alt="Imagem Grande">
        <div id="modalComentarios"></div>
    </div>
    {% for post in posts %}
    <div class="post">
        <p><strong>{{ post[0] }}</strong></p>
        <img src="{{ url_for('uploaded_file', filename=post[1]) }}" alt="Imagem postada" onclick="openModal(this.src, '{{ post[1] }}')">
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
    posts = []
    if os.path.exists("posts.csv"):
        with open("posts.csv", "r", encoding="utf-8") as f:
            reader = csv.reader(f)
            posts = list(reader)
    return render_template('index.html', posts=posts)

@app.route('/comentarios/<foto_id>')
def get_comentarios(foto_id):
    comentarios = []
    if os.path.exists("comentarios.csv"):
        with open("comentarios.csv", "r", encoding="utf-8") as f:
            reader = csv.reader(f)
            for row in reader:
                if row[0] == foto_id:
                    comentarios.append({"nome": row[1], "comentario": row[2]})
    return jsonify(comentarios)

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

if __name__ == '__main__':
    from socket import gethostbyname, gethostname
    local_ip = gethostbyname(gethostname())
    app.run(host='0.0.0.0', port=8000, debug=True)