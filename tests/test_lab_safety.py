"""Execute lab scripts against disposable mock commands, never a real cluster."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
GIT_BASH = Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "Git/bin/bash.exe"
BASH = str(GIT_BASH) if os.name == "nt" and GIT_BASH.is_file() else shutil.which("bash")


class LabContextTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.log = self.directory / "calls.txt"
        self.env = dict(os.environ, PATH=str(self.directory) + os.pathsep + os.environ["PATH"], LAB_TEST_LOG=self.log.as_posix())
        self.write_tool("docker", "exit 0\n")
        self.write_tool("kind", 'if [ "$1 $2" = "get clusters" ]; then printf "%s\\n" superlab; else exit 0; fi\n')
        self.write_tool("kubectl", 'printf "%s\\n" "$*" >> "$LAB_TEST_LOG"\n')

    def write_tool(self, name, body):
        path = self.directory / name
        path.write_text("#!/usr/bin/env bash\n" + body, encoding="utf-8", newline="\n")
        path.chmod(0o755)

    def run_script(self, name, *args):
        return subprocess.run([BASH, (ROOT / "scripts" / name).as_posix(), *args], cwd=ROOT, env=self.env, capture_output=True, text=True, timeout=10)

    def test_invalid_environment_never_calls_kubectl(self):
        result = self.run_script("kustomize-apply.sh", "../other-cluster")
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertFalse(self.log.exists())

    def test_missing_lab_never_calls_kubectl(self):
        self.write_tool("kind", "exit 0\n")
        result = self.run_script("kustomize-apply.sh", "dev")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_apply_and_rollout_explicitly_use_lab_context(self):
        result = self.run_script("kustomize-apply.sh", "dev")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.log.read_text().splitlines()
        self.assertEqual(len(calls), 3)
        self.assertTrue(all(call.startswith("--context kind-superlab ") for call in calls))
        self.assertIn("kustomize/overlays/dev", calls[1])
        self.assertIn("rollout status deployment/health-demo", calls[2])

    def test_failed_cluster_creation_stops_before_kubectl(self):
        self.write_tool("kind", 'if [ "$1 $2" = "get clusters" ]; then exit 0; else exit 9; fi\n')
        result = self.run_script("kind-superlab-up.sh")
        self.assertEqual(result.returncode, 9, result.stderr)
        self.assertFalse(self.log.exists())

    def test_existing_lab_check_uses_explicit_context(self):
        result = self.run_script("kind-superlab-up.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.log.read_text().splitlines()
        self.assertEqual(len(calls), 2)
        self.assertTrue(all(call.startswith("--context kind-superlab ") for call in calls))


if __name__ == "__main__":
    unittest.main()
