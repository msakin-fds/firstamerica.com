"""WordPress manager for firstamerica.com — SSH + WP-CLI + REST API."""

import os
import json
import base64
import subprocess
from pathlib import Path
from dotenv import load_dotenv

import paramiko
import requests

load_dotenv()

SSH_KEY_PATH = os.path.expanduser(os.getenv("SSH_KEY_PATH", "~/.ssh/firstamerica_ed25519"))
SSH_USER     = os.getenv("SSH_USER", "u1684-qxgm4olhch1d")
SSH_HOST     = os.getenv("SSH_HOST", "ssh.firstamerica.com")
SSH_PORT     = int(os.getenv("SSH_PORT", "18765"))
WP_PATH      = os.getenv("WP_PATH", "/home/u1684-qxgm4olhch1d/www/firstamerica.com/public_html")
WP_URL       = os.getenv("WP_URL", "https://firstamerica.com")
REST_USER    = os.getenv("WP_REST_USER", "")
REST_PASS    = os.getenv("WP_REST_PASSWORD", "")


class WordPressManager:
    def __init__(self):
        self._ssh: paramiko.SSHClient | None = None

    # ── SSH ──────────────────────────────────────────────────────────────────

    def _connect(self) -> paramiko.SSHClient:
        if self._ssh and self._ssh.get_transport() and self._ssh.get_transport().is_active():
            return self._ssh
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(
            SSH_HOST, port=SSH_PORT, username=SSH_USER,
            key_filename=SSH_KEY_PATH, timeout=15
        )
        self._ssh = client
        return client

    def run_ssh_command(self, cmd: str) -> tuple[str, str, int]:
        ssh = self._connect()
        _, stdout, stderr = ssh.exec_command(cmd)
        exit_code = stdout.channel.recv_exit_status()
        return stdout.read().decode(), stderr.read().decode(), exit_code

    def run_wp_cli(self, wp_cmd: str) -> tuple[str, str, int]:
        return self.run_ssh_command(f"cd {WP_PATH} && wp {wp_cmd} --allow-root 2>&1")

    def close(self):
        if self._ssh:
            self._ssh.close()

    # ── WP-CLI helpers ────────────────────────────────────────────────────────

    def get_site_info(self) -> dict:
        out, _, _ = self.run_wp_cli("core version")
        version = out.strip()
        url, _, _ = self.run_wp_cli("option get siteurl")
        theme, _, _ = self.run_wp_cli("theme list --status=active --format=json")
        return {"version": version, "url": url.strip(), "theme": theme.strip()}

    def list_plugins(self) -> list:
        out, _, _ = self.run_wp_cli("plugin list --format=json")
        try:
            return json.loads(out)
        except json.JSONDecodeError:
            return []

    def list_posts(self, limit: int = 10, post_type: str = "post") -> list:
        out, _, _ = self.run_wp_cli(
            f"post list --post_type={post_type} --posts_per_page={limit} --format=json"
        )
        try:
            return json.loads(out)
        except json.JSONDecodeError:
            return []

    def get_theme_info(self) -> list:
        out, _, _ = self.run_wp_cli("theme list --format=json")
        try:
            return json.loads(out)
        except json.JSONDecodeError:
            return []

    def create_post(self, title: str, content: str, post_type: str = "post",
                    status: str = "draft") -> str:
        out, err, code = self.run_wp_cli(
            f'post create --post_title="{title}" --post_content="{content}" '
            f'--post_type={post_type} --post_status={status} --porcelain'
        )
        return out.strip() if code == 0 else f"Error: {err}"

    def db_query(self, sql: str) -> str:
        out, err, code = self.run_wp_cli(f'db query "{sql}"')
        return out if code == 0 else f"Error: {err}"

    def db_export(self, filename: str = "backup.sql") -> str:
        out, err, code = self.run_wp_cli(f"db export {filename}")
        return out if code == 0 else f"Error: {err}"

    def run_audit(self, audit_type: str = "full") -> dict:
        results: dict = {}
        if audit_type in ("full", "core"):
            results["core"], _, _ = self.run_wp_cli("core check-update")
        if audit_type in ("full", "plugins"):
            results["plugins"] = self.list_plugins()
        if audit_type in ("full", "security"):
            results["users"], _, _ = self.run_wp_cli("user list --format=json")
        return results

    # ── REST API ──────────────────────────────────────────────────────────────

    def _rest_headers(self) -> dict:
        token = base64.b64encode(f"{REST_USER}:{REST_PASS}".encode()).decode()
        return {"Authorization": f"Basic {token}", "Content-Type": "application/json"}

    def run_rest_api(self, endpoint: str, method: str = "GET", data: dict | None = None):
        url = f"{WP_URL}/wp-json/wp/v2/{endpoint}"
        resp = requests.request(method, url, headers=self._rest_headers(), json=data, timeout=15)
        resp.raise_for_status()
        return resp.json()


if __name__ == "__main__":
    wp = WordPressManager()
    try:
        info = wp.get_site_info()
        print("Site info:", json.dumps(info, indent=2))
    finally:
        wp.close()
