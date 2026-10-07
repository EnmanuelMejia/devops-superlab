"""Small local lab service. No authentication, storage, or production SLA."""
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = urlsplit(self.path).path
        if path == "/health":
            status, body = 200, {"status": "ok"}
        elif path == "/":
            status, body = 200, {"service": "superlab-health-demo", "scope": "personal local lab"}
        else:
            status, body = 404, {"error": "not found"}
        encoded = json.dumps(body).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(encoded)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(encoded)

    def log_message(self, format, *args):
        # Avoid writing query strings or request details to the exercise logs.
        pass


def create_server(host="127.0.0.1", port=8080):
    return ThreadingHTTPServer((host, port), Handler)


if __name__ == "__main__":
    with create_server(os.environ.get("HOST", "127.0.0.1"), int(os.environ.get("PORT", "8080"))) as server:
        server.serve_forever()
