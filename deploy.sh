#!/bin/bash
set -a
source .env
set +a

hugo --minify

lftp -u "$FTP_USER,$FTP_PASS" "$FTP_HOST" <<EOF
mirror -R --delete --verbose public/ "$FTP_REMOTE_PATH"
bye
EOF