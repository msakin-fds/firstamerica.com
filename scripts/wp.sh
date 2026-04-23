#!/usr/bin/env bash
# Bash shortcuts for firstamerica.com WordPress management
# Usage: source scripts/wp.sh

SSH_KEY="${SSH_KEY:-$HOME/.ssh/firstamerica_ed25519}"
SSH_OPTS="-i $SSH_KEY -p 18765 -o StrictHostKeyChecking=no"
SSH_USER="u1684-qxgm4olhch1d"
SSH_HOST="ssh.firstamerica.com"
WP_PATH="/home/u1684-qxgm4olhch1d/www/firstamerica.com/public_html"

# Run any WP-CLI command
wp_ssh() {
  ssh $SSH_OPTS "${SSH_USER}@${SSH_HOST}" "cd ${WP_PATH} && wp $* --allow-root"
}

# Shortcuts
alias wp_info='wp_ssh core version && wp_ssh option get siteurl'
alias wp_plugins='wp_ssh plugin list --format=table'
alias wp_posts='wp_ssh post list --post_status=publish --format=table'
alias wp_backup='wp_ssh db export backup_$(date +%Y%m%d).sql && echo "Backup saved on server"'
alias wp_update_all='wp_ssh plugin update --all && wp_ssh core update'
alias wp_users='wp_ssh user list --format=table'

wp_activate()   { wp_ssh plugin activate "$1"; }
wp_deactivate() { wp_ssh plugin deactivate "$1"; }

echo "firstamerica.com WP shortcuts loaded. Try: wp_info, wp_plugins, wp_posts"
