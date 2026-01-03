#!/bin/bash

# 1. Restart the Backend Service
echo "🚀 Starting PocketBase Backend..."
sudo systemctl restart prosite

# 2. Kill any old ngrok sessions
killall ngrok > /dev/null 2>&1

# 3. Start ngrok in the background and wait for it to wake up
echo "🌐 Launching Secure Tunnel..."
ngrok http 80 --log=stdout > /dev/null &
sleep 5

# 4. Extract the brand new URL from ngrok
NEW_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^"]*ngrok-free.dev' | head -n 1)

if [ -z "$NEW_URL" ]; then
    echo "❌ Error: Could not get ngrok URL. Is ngrok installed and authenticated?"
    exit 1
fi

echo "🔗 New Live URL: $NEW_URL"

# 5. Inject the new URL into all HTML files automatically
echo "💉 Syncing URL to Frontend Logic..."
sed -i "s|const pb = new PocketBase.*|const pb = new PocketBase('$NEW_URL');|g" ~/enterprise_prosite/pb_public/*.html

echo "✅ PRO-SITE IS LIVE!"
echo "Visit: $NEW_URL"
