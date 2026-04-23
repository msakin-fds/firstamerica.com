# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WordPress management and integration suite for **First America** (https://firstamerica.com/). Enables remote site management, content operations, audits, and database access via SSH + WP-CLI and the WP REST API.

**Site**: https://firstamerica.com (WordPress on SiteGround)
**GitHub**: `msakin-fds/firstamerica.com`

## Environment Setup

**Platform**: Windows 11 Pro, bash (Git Bash)
**SSH Key**: `~/.ssh/firstamerica_ed25519` (ED25519)
**SSH Access**: `u1684-qxgm4olhch1d@ssh.firstamerica.com:18765`
**SSH Alias**: `ssh firstamerica` (configured in `~/.ssh/config`)
**WP Path**: `/home/u1684-qxgm4olhch1d/www/firstamerica.com/public_html`
**WordPress admin email**: `fdsthinker@fds.com`

All credentials live in `.env` (copy from `.env.example`). Never commit `.env`.

## Quick Start

```bash
pip install -r requirements.txt
cp .env.example .env
# Fill in DB_PASSWORD from SiteGround -> Site Tools -> Site -> MySQL -> Databases
python wp_manager.py       # Test SSH + WP-CLI connection
```

## SSH Key Setup

The public key must be registered in SiteGround before SSH works:

1. Go to SiteGround -> Site Tools -> Devs -> SSH Keys & Access
2. Add the contents of `~/.ssh/firstamerica_ed25519.pub`
3. Test: `ssh firstamerica "wp --version --allow-root"`

## Tools & Scripts

### `wp_manager.py` — Core Python Interface

```python
from wp_manager import WordPressManager
wp = WordPressManager()

wp.get_site_info()                              # WP version, URL, active theme
wp.list_plugins()                               # All plugins (JSON)
wp.list_posts(limit=10)                         # Recent posts
wp.get_theme_info()                             # Theme list
wp.create_post(title, content, status='draft')  # Create post
wp.db_query("SELECT * FROM wp_posts LIMIT 5")  # Raw SQL via WP-CLI
wp.db_export()                                  # Backup DB to server
wp.run_audit(audit_type='full|core|plugins|security')
wp.run_rest_api('posts', method='GET')          # Direct REST API call
wp.run_ssh_command('any shell command')         # Raw SSH
wp.run_wp_cli('any wp-cli command')             # Raw WP-CLI
```

### `scripts/site_audit.py` — Full Site Audit

```bash
python scripts/site_audit.py
```
Outputs: WP version, theme, plugins (active/inactive), available updates, recent posts.

### `scripts/wp.sh` — Bash Shortcuts

```bash
source scripts/wp.sh

wp_info             # WP version + site URL
wp_plugins          # List all plugins
wp_posts            # Recent published posts
wp_backup           # DB backup to server (timestamped)
wp_update_all       # Update plugins + core
wp_users            # List users
wp_activate foo     # Activate plugin
wp_deactivate foo   # Deactivate plugin
wp_ssh <any-wp-cli-command>
```

## Architecture

```
wp_manager.py          # Core manager (SSH + WP-CLI + REST API)
scripts/
  site_audit.py        # Full audit runner
  wp.sh                # Bash shortcuts (source to use)
reports/               # Audit outputs (gitignored)
.env                   # Credentials (never committed)
.env.example           # Credentials template
```

**Two access paths:**
- **SSH + WP-CLI** — full server access; database ops, plugin/theme management, file edits
- **WP REST API + Application Password** — content CRUD without SSH; blocked by SiteGround bot-protection from external IPs, so run REST calls from server-side or through the Python manager via SSH tunnel

## Database

- Name: `dbl5fblujyre1x` | User: `uaauvkvibgrol` | Host: `127.0.0.1` (server-side only)
- Password comes from SiteGround -> Site Tools -> Site -> MySQL -> Databases (not WP admin password)
- Access only via SSH: `wp_ssh db query "SELECT ..."` or `wp.db_query(...)` in Python

## Troubleshooting

**SSH fails `Permission denied`**: Public key not yet added in SiteGround. See "SSH Key Setup" above.

**WP-CLI not found**: Run `which wp` over SSH — SiteGround ships it at `/usr/local/bin/wp`. Always pass `--allow-root`.

**WP-CLI path wrong**: If `wp` commands fail, check actual WordPress path: `ssh firstamerica "find /home -name 'wp-config.php' 2>/dev/null | head -5"`

**REST API returns CAPTCHA HTML**: SiteGround bot-protection blocks external API calls. Use WP-CLI via SSH for all data operations instead.

**REST API 401**: Regenerate application password at WP Admin -> Users -> Profile -> Application Passwords.
