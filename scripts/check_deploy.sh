#!/bin/bash
LOCAL_SHA=$(git rev-parse HEAD)
REMOTE_SHA=$(curl -s https://blog.dambrosio.nl/version.txt)

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
  echo "✅ Deployment is in sync ($LOCAL_SHA)"
else
  echo "⚠️  Out of sync:"
  echo "  local:  $LOCAL_SHA"
  echo "  remote: $REMOTE_SHA"
fi
