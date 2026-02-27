import json
import os
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class Handler(BaseHTTPRequestHandler):
    def _send_json(self, payload: dict, status: HTTPStatus = HTTPStatus.OK) -> None:
        encoded = json.dumps(payload).encode("utf-8")
        self.send_response(status.value)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def do_GET(self) -> None:
        if self.path == "/healthz":
            self._send_json({"status": "ok"})
            return

        if self.path == "/":
            self._send_json(
                {
                    "service": "spider-api",
                    "message": "Project Spider local deployment is running",
                    "version": os.getenv("APP_VERSION", "dev"),
                }
            )
            return

        self._send_json({"error": "not found"}, HTTPStatus.NOT_FOUND)

    def log_message(self, fmt: str, *args) -> None:  # noqa: A003
        # Keep container logs concise but useful.
        print(f"{self.address_string()} - {fmt % args}")


def run() -> None:
    port = int(os.getenv("PORT", "8080"))
    server = ThreadingHTTPServer(("0.0.0.0", port), Handler)
    print(f"spider-api listening on :{port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
