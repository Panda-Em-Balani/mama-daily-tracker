#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Mama Daily Tracker — Deploy Script
# Run this instead of git push directly:  bash deploy.sh
# ═══════════════════════════════════════════════════════════

# Generate a timestamp e.g. 20260609-1430
BUILDTIME=$(date +"%Y%m%d-%H%M")

# Inject timestamp into sw.js
sed -i.bak "s/__BUILDTIME__/${BUILDTIME}/g" sw.js

# Commit and push
git add .
git commit -m "Deploy ${BUILDTIME}"
git push

# Restore the placeholder in sw.js for next deploy
mv sw.js.bak sw.js

echo ""
echo "✅ Deployed version ${BUILDTIME}"
echo "   App will update on next open."
