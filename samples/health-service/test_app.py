import json
import threading
import unittest
from urllib.error import HTTPError
from urllib.request import Request, urlopen
from app import create_server


class HealthServiceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = create_server(port=0)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.base = f"http://127.0.0.1:{cls.server.server_port}"

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()

    def test_health_is_json_and_not_cached(self):
        with urlopen(self.base + "/health", timeout=3) as response:
            self.assertEqual(response.status, 200)
            self.assertEqual(json.load(response), {"status": "ok"})
            self.assertEqual(response.headers["Cache-Control"], "no-store")
            self.assertIn("application/json", response.headers["Content-Type"])

    def test_root_declares_local_scope(self):
        with urlopen(self.base, timeout=3) as response:
            self.assertEqual(json.load(response)["scope"], "personal local lab")

    def test_unknown_route_is_404(self):
        with self.assertRaises(HTTPError) as error:
            urlopen(self.base + "/missing", timeout=3)
        self.assertEqual(error.exception.code, 404)
        self.assertEqual(json.load(error.exception), {"error": "not found"})
        error.exception.close()

    def test_write_methods_are_not_available(self):
        with self.assertRaises(HTTPError) as error:
            urlopen(Request(self.base + "/health", data=b"{}", method="POST"), timeout=3)
        self.assertEqual(error.exception.code, 501)
        error.exception.close()


if __name__ == "__main__":
    unittest.main()
