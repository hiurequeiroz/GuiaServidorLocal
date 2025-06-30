from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "<h1>Boas vindas ao pandavasweb!</h1><p>Este é um servidor Flask acessível na rede local.</p>"

if __name__ == '__main__':
    from socket import gethostbyname, gethostname
    local_ip = gethostbyname(gethostname())
    app.run(host='0.0.0.0', port=8000, debug=True)
