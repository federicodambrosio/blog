#!/bin/bash
set -euo pipefail

set -a
source .env
set +a

LOCAL_SHA=$(git rev-parse HEAD)
WORKTREE_STATUS=$(git status --porcelain)

# Warn if there are uncommitted changes
if [ -n "$WORKTREE_STATUS" ]; then
  echo "⚠️  You have uncommitted changes. Commit first for accurate version tracking."
  read -p "Continue anyway? [y/N] " confirm
  [[ "$confirm" == [yY] ]] || exit 1
else
  REMOTE_SHA=$(curl --fail --silent --show-error --location --max-time 15 \
    -H 'Cache-Control: no-cache' \
    "https://blog.dambrosio.nl/version.txt?cache_bust=$(date +%s)-$$")

  if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
    echo "✅ Already deployed ($LOCAL_SHA); skipping."
    exit 0
  fi
fi

hugo --minify
VERSION_MARKER="$LOCAL_SHA"
if [ -n "$WORKTREE_STATUS" ]; then
  VERSION_MARKER="${LOCAL_SHA}-dirty"
fi
printf '%s\n' "$VERSION_MARKER" > public/version.txt

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

echo "✅ Deployed $VERSION_MARKER"
