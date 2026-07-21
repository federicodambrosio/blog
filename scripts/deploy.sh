#!/bin/bash
set -euo pipefail

set -a
source .env
set +a

# Warn if there are uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️  You have uncommitted changes. Commit first for accurate version tracking."
  read -p "Continue anyway? [y/N] " confirm
  [[ "$confirm" == [yY] ]] || exit 1
fi

hugo --minify
git rev-parse HEAD > public/version.txt

# echo "Running dry-run first..."
# lftp -u "$FTP_USER,$FTP_PASS" "$FTP_HOST" <<EOF
# mirror -R --delete --dry-run --verbose public/ "$FTP_REMOTE_PATH"
# bye
# EOF

# read -p "Review the dry-run output above. Proceed with real deploy? [y/N] " confirm
# [[ "$confirm" == [yY] ]] || { echo "Aborted."; exit 1; }

lftp -u "$FTP_USER,$FTP_PASS" "$FTP_HOST" <<EOF
mirror -R --delete --verbose public/ "$FTP_REMOTE_PATH"
bye
EOF

echo "✅ Deployed $(git rev-parse HEAD)"
