# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WordPress management and integration suite for **First America** (https://firstamerica.com/). Enables remote site management, content operations, audits, and database access via SSH + WP-CLI and the WP REST API.

**Site**: https://firstamerica.com (WordPress 6.9.4 on SiteGround)
**Theme**: rekon-child 1.0.0 (parent: rekon 1.0.17)
**PHP**: 8.2.30
**Plugins**: 22 installed (21 active, 1 inactive: zoho-salesiq) + object-cache dropin
**Content**: 189 published posts · 247 published pages
**GitHub**: `msakin-fds/firstamerica.com`

## Environment Setup

**Platform**: Windows 11 Pro, bash (Git Bash)
**SSH Key**: `~/.ssh/firstamerica_ed25519` (ED25519)
**SSH Access**: `u1684-qxgm4olhch1d@ssh.firstamerica.com:18765`
**SSH Alias**: `ssh firstamerica` (configured in `~/.ssh/config`)
**WP Path**: `/home/u1684-qxgm4olhch1d/www/firstamerica.com/public_html`
**WP-CLI**: 2.12.0 at `/usr/local/bin/wp`
**DB**: `dbl5fblujyre1x` · user `uaauvkvibgrol` · host `127.0.0.1` · prefix `zvf_`
**Staging**: `/home/u1684-qxgm4olhch1d/www/staging2.firstamerica.com/`

All credentials live in `.env` (gitignored). Copy from `.env.example` and fill in.

## Quick Start

```bash
pip install -r requirements.txt
cp .env.example .env
# .env already pre-filled — update if credentials rotate
python wp_manager.py       # Test SSH + WP-CLI connection
```

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
wp.db_query("SELECT * FROM zvf_posts LIMIT 5") # Raw SQL via WP-CLI
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
Outputs: WP version, theme, plugins (active/inactive/updates), recent posts.

### `scripts/wp.sh` — Bash Shortcuts

```bash
source scripts/wp.sh

wp_ssh core version      # Any WP-CLI command
wp_info                  # WP version + site URL
wp_plugins               # List all plugins (table)
wp_posts                 # Recent published posts
wp_backup                # DB backup to server (timestamped .sql)
wp_update_all            # Update plugins + core
wp_users                 # List users
wp_activate <slug>       # Activate plugin
wp_deactivate <slug>     # Deactivate plugin
```

## Architecture

```
wp_manager.py          # Core manager (SSH + WP-CLI + REST API)
scripts/
  site_audit.py        # Full audit runner
  wp.sh                # Bash shortcuts (source to use)
reports/               # Audit outputs (gitignored)
.env                   # Credentials (gitignored)
.env.example           # Credentials template
```

**Two access paths:**
- **SSH + WP-CLI** — full server access; database ops, plugin/theme management, file edits. Always append `--allow-root`.
- **WP REST API + Application Password** — content CRUD. SiteGround bot-protection blocks external API calls from unknown IPs; use WP-CLI via SSH for all data operations by default.

## Key Plugins

| Plugin | Purpose |
|---|---|
| Elementor Pro + bdthemes-element-pack | Page builder |
| Yoast SEO (wordpress-seo) | SEO — **has updates available** |
| SG Security + SG CachePress | SiteGround native perf/security |
| WP Security Audit Log | Admin audit trail |
| Contact Form 7 | Contact forms |
| Apus Framework + Apus Rekon | Theme framework for rekon theme |
| Slider Revolution (revslider) | Hero sliders |
| WP Reviews for Google | Google reviews display |
| CallRail | Phone call tracking |
| LLMs Full TXT Generator | LLM sitemap generator |

## Plugins with Available Updates

Run `wp_ssh plugin update --all` to update all at once, or per-plugin:
```bash
wp_ssh plugin update eps-301-redirects contact-form-7 elementor elementor-pro \
  llms-full-txt-generator sg-security wp-reviews-plugin-for-google \
  wp-security-audit-log insert-headers-and-footers duplicate-post wordpress-seo
```

## Users

| Login | Role | Email |
|---|---|---|
| msakin@freshds.com | administrator | msakin@freshds.com |
| fdsthinker@fds.com | administrator | fdsthinker@fds.com |
| Anson.Wu@freshds.com | administrator | Anson.Wu@freshds.com |
| melvieg@firstamerica.com | administrator | melvieg@firstamerica.com |
| rinorobinson | administrator | rino@makoitlab.com |
| joeyf | author | joeyf@firstamerica.com |
| lbury | author | lbury@firstamerica.com |

## Database

- Name: `dbl5fblujyre1x` | User: `uaauvkvibgrol` | Host: `127.0.0.1` | Prefix: `zvf_`
- Password in `.env` as `DB_PASSWORD`
- Access via SSH only — `wp_ssh db query "SELECT ..."` or `wp.db_query(...)` in Python

## Troubleshooting

**WP-CLI commands**: Always pass `--allow-root` — SiteGround's SSH user requires it.

**REST API returns CAPTCHA HTML**: SiteGround bot-protection. Use WP-CLI via SSH instead.

**REST API 401**: Regenerate at WP Admin → Users → Profile → Application Passwords.

**WP path check**: `ssh firstamerica "find /home -name 'wp-config.php' 2>/dev/null"`
