from http.server import BaseHTTPRequestHandler, HTTPServer
import json

notes = [{"id": 1, "text": "Learn HTTP methods"}]


class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, data=None):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()

        if data is not None:
            self.wfile.write(json.dumps(data).encode())

    def read_json(self):
        length = int(self.headers.get("Content-Length", 0))
        return json.loads(self.rfile.read(length) or b"{}")

    def do_GET(self):
        if self.path == "/notes":
            self.send_json(200, notes)
        else:
            self.send_json(404, {"error": "Not found"})

    def do_POST(self):
        if self.path == "/notes":
            data = self.read_json()
            note = {"id": len(notes) + 1, "text": data["text"]}
            notes.append(note)
            self.send_json(201, note)
        else:
            self.send_json(404, {"error": "Not found"})

    def do_PUT(self):
        if self.path == "/notes/1":
            data = self.read_json()
            notes[0]["text"] = data["text"]
            self.send_json(200, notes[0])
        else:
            self.send_json(404, {"error": "Not found"})

    def do_DELETE(self):
        if self.path == "/notes/1":
            notes.pop(0)
            self.send_json(204)
        else:
            self.send_json(404, {"error": "Not found"})


HTTPServer(("127.0.0.1", 8080), Handler).serve_forever()
