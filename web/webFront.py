from flask import Flask, render_template
import os

app = Flask(__name__, static_folder='assets')

# Criar diretório de templates se não existir
if not os.path.exists('templates'):
    os.makedirs('templates')

# Criar um arquivo HTML básico
html_content = """<!DOCTYPE html>
<html lang='pt'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Página Inicial</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 20px; margin: 0; }
        h1 { color: #333; font-size: 2em; }
        .logo { max-width: 120px; height: auto; margin-bottom: 10px; }
        .banner { max-width: 100%; height: auto; margin-top: 10px; }
        @media (max-width: 600px) {
            body { padding: 10px; }
            h1 { font-size: 1.5em; }
            .logo { max-width: 100px; }
            .banner { margin-top: 5px; }
        }
    </style>
</head>
<body>
    <img src="{{ url_for('static', filename='logo.png') }}" alt="Logo" class="logo">
    <h1>PandavasWeb!</h1>
    <p>Essa é uma página que não está na internet.</p>
    <img src="{{ url_for('static', filename='banner.png') }}" alt="Banner" class="banner">
    <p>Essa atividade tem o objetivo de mostrar que podemos ter uma página web sem estar necessariamente conectados na Internet.
    E não só pagina web como muito mais</p>
</body>
</html>"""

# Salvar o HTML no diretório templates
with open("templates/index.html", "w") as f:
    f.write(html_content)

@app.route('/')
def home():
    return render_template('index.html')

if __name__ == '__main__':
    from socket import gethostbyname, gethostname
    local_ip = gethostbyname(gethostname())
    app.run(host='0.0.0.0', port=8000, debug=True)