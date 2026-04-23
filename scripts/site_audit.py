"""Full site audit for firstamerica.com."""

import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from wp_manager import WordPressManager


def run_audit():
    wp = WordPressManager()
    try:
        print("=== firstamerica.com Site Audit ===\n")

        info = wp.get_site_info()
        print(f"WordPress version : {info['version']}")
        print(f"Site URL          : {info['url']}")
        print(f"Active theme      : {info['theme']}\n")

        plugins = wp.list_plugins()
        active = [p for p in plugins if p.get("status") == "active"]
        print(f"Plugins: {len(plugins)} total, {len(active)} active")
        for p in plugins:
            flag = "[INACTIVE]" if p.get("status") != "active" else ""
            print(f"  {p.get('name','?')} {p.get('version','?')} {flag}")

        print()
        out, _, _ = wp.run_wp_cli("core check-update")
        print("Core updates:", out.strip() or "None available")

        print()
        out, _, _ = wp.run_wp_cli("plugin update --dry-run --all 2>&1 | head -20")
        print("Plugin updates:\n", out.strip())

        posts = wp.list_posts(limit=5)
        print(f"\nRecent posts ({len(posts)}):")
        for p in posts:
            print(f"  [{p.get('ID')}] {p.get('post_title')} ({p.get('post_status')})")

    finally:
        wp.close()


if __name__ == "__main__":
    run_audit()
