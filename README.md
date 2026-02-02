# Moltbot (OpenClaw) for Unraid

A containerized deployment of [OpenClaw](https://openclaw.ai) (formerly Moltbot/Clawdbot) designed specifically for Unraid.

## 🚀 Quick Start

1. **Install:** Add the container using the Unraid Community App.
2. **Start:** Start the Moltbot app.
3. **Get Token:** Check the App logs. Look for the `Moltbot Startup` banner to find your **Gateway Token**.
   - *Tip: You can copy this token into the "Gateway Token" field in the Unraid template to make it permanent.*
4. **Access:** Open the WebUI.
   - *Required: See below to enable HTTPS.*

---

## HTTPS & Remote Access

Moltbot uses the **WebCrypto API** to secure your chat. Modern browsers **BLOCK** this API on insecure HTTP connections (unless you are using `localhost`).

If you access the bot via IP (e.g., `http://192.168.0.1:18789`), the page may load but immediately disconnect with `Error 1008`.

### Option 1: Tailscale (Recommended)
The easiest way to get valid HTTPS on Unraid is using [Tailscale Serve](https://tailscale.com/kb/1242/serve).

1. **Install Tailscale** on Unraid.
2. **Open Unraid Terminal** (`>_`).
3. Run the serve command (using port 8443 as an example):
   ```bash
   tailscale serve --bg --https=8443 http://localhost:18789
   ```
4. **Update Unraid Template:**
   - Edit the **Public URL** variable in the Moltbot container settings.
   - Set it to your full HTTPS URL: `https://your-machine.tailnet.ts.net:8443` (No trailing slash).
5. Access the bot at that HTTPS URL.

*Note: While `--bg` attempts to save the config, Unraid's ephemeral nature means settings can be lost on reboot. For maximum reliability, use the Unraid **User Scripts** plugin to run the command above "At Startup of Array".*

### Option 2: Nginx Proxy Manager
If using a reverse proxy (like Nginx Proxy Manager or Swag), you **must** enable:
- **Websockets Support**
- **SSL (HTTPS)**

---

## Device Pairing

For security, OpenClaw requires manual approval for any device connecting from a non-local IP (including Tailscale).

1. Connect via your browser. You will see **"Disconnected (1008): Pairing Required"**.
2. **Leave the tab open.**
3. Open the **Unraid Docker Console** for Moltbot.
4. Run this command to see the **Request ID**:
   ```bash
   # We pass the token explicitly since the console session is new
   OPENCLAW_GATEWAY_TOKEN=$(cat /home/node/.openclaw/.generated_token) node dist/index.js devices list
   ```
5. Approve the request (e.g., replace `abcd-1234-efgh-5678` with your ID):
   ```bash
   OPENCLAW_GATEWAY_TOKEN=$(cat /home/node/.openclaw/.generated_token) node dist/index.js devices approve abcd-1234-efgh-5678
   ```
6. Your browser will instantly connect.

---

## 🛠 Troubleshooting

**"Mixed Content" / Blank Page**
- **Cause:** You are accessing via HTTPS, but the app thinks it is HTTP.
- **Fix:** Set the `Public URL` variable in the Unraid template to your exact HTTPS address.

**"Gateway Closed (1008)"**
- **Cause:** Browser security blocking WebSockets.
- **Fix:** Use HTTPS. If testing locally on HTTP, try appending `?token=YOUR_TOKEN` to the URL for the initial connection.
