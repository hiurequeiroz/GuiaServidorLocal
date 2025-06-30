from flask import Flask, render_template, request, redirect, url_for, send_from_directory
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
        .comentarios { margin-top: 10px; padding: 10px; background: #f9f9f9; border-radius: 5px; text-align: left; }
        .comentario { margin-bottom: 5px; }
        #modal { display: none; position: fixed; z-index: 10; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.9); justify-content: center; align-items: center; }
        #modal img { max-width: 90%; max-height: 90%; border-radius: 10px; }
        #closeModal { position: absolute; top: 15px; right: 25px; font-size: 30px; color: white; cursor: pointer; }
    </style>
    <script>
        function openModal(src) {
            document.getElementById('modalImg').src = src;
            document.getElementById('modal').style.display = 'flex';
        }
        function closeModal(event) {
            if (event.target.id === 'modal' || event.target.id === 'closeModal') {
                document.getElementById('modal').style.display = 'none';
            }
        }
    </script>
</head>
<body>
    <h1>Instagram Local</h1>
    <div id="modal" onclick="closeModal(event)">
        <span id="closeModal">&times;</span>
        <img id="modalImg" src="" alt="Imagem Grande">
    </div>
    {% for post in posts %}
    <div class="post">
        <p><strong>{{ post[0] }}</strong></p>
        <img src="{{ url_for('uploaded_file', filename=post[1]) }}" alt="Imagem postada" onclick="openModal(this.src)">
        <p>{{ post[2] }}</p>
        <div class="comentarios">
            <h4>Comentários:</h4>
            {% for comentario in comentarios %}
                {% if comentario[0] == post[1] %}
                    <p class="comentario"><strong>{{ comentario[1] }}</strong>: {{ comentario[2] }}</p>
                {% endif %}
            {% endfor %}
            <form action="/comentar" method="post">
                <input type="hidden" name="foto" value="{{ post[1] }}">
                <input type="text" name="nome" placeholder="Seu nome" required><br>
                <textarea name="comentario" placeholder="Digite um comentário" required></textarea><br>
                <button type="submit">Comentar</button>
            </form>
        </div>
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
    comentarios = []
    if os.path.exists("posts.csv"):
        with open("posts.csv", "r", encoding="utf-8") as f:
            reader = csv.reader(f)
            posts = list(reader)
    if os.path.exists("comentarios.csv"):
        with open("comentarios.csv", "r", encoding="utf-8") as f:
            reader = csv.reader(f)
            comentarios = list(reader)
    return render_template('index.html', posts=posts, comentarios=comentarios)

@app.route('/comentar', methods=['POST'])
def comentar():
    foto = request.form['foto']
    nome = request.form['nome']
    comentario = request.form['comentario']
    
    with open("comentarios.csv", "a", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([foto, nome, comentario])
    
    return redirect(url_for('home'))

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

if __name__ == '__main__':
    from socket import gethostbyname, gethostname
    local_ip = gethostbyname(gethostname())
    app.run(host='0.0.0.0', port=8000, debug=True)