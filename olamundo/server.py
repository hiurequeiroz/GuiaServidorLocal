import http.server
import socketserver
import socket

PORT = 8000

# Obtém o endereço IP local automaticamente
hostname = socket.gethostname()
local_ip = socket.gethostbyname(hostname)

Handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer(("0.0.0.0", PORT), Handler) as httpd:
    print(f"Servidor rodando em http://{local_ip}:{PORT}")
    httpd.serve_forever()