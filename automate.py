import time
import requests
from websocket import create_connection

DEBUG_PORT = 9222


def get_websocket_url():
    # Fetch the open target pages inside the Devin IDE
    try:
        response = requests.get(f"http://localhost:{DEBUG_PORT}/json")
        pages = response.json()
        # Find the main Devin app window/webview
        for page in pages:
            if "devin" in page.get("url", "").lower():
                return page.get("webSocketDebuggerUrl")
        return pages[0].get("webSocketDebuggerUrl")
    except Exception:
        return None


def send_js_command(ws, expression):
    # Sends raw JS payload to the Devin Chromium compiler
    import json

    payload = {
        "id": 1,
        "method": "Runtime.evaluate",
        "params": {"expression": expression, "userGesture": True},
    }
    ws.send(json.dumps(payload))


def auto_click():
    ws_url = get_websocket_url()
    if not ws_url:
        print("Could not connect to Devin IDE. Is it open with port 9222?")
        return

    print("Successfully connected to Devin IDE backend engine!")
    ws = create_connection(ws_url)

    # JS snippet to find any button with 'run', 'execute', or 'approve' and click it
    click_js = """
    (() => {
        const buttons = document.querySelectorAll('button');
        buttons.forEach(button => {
            const text = button.textContent.trim().toLowerCase();
            if (text === 'run' || text === 'execute' || text === 'approve') {
                if (!button.dataset.autoClicked) {
                    button.dataset.autoClicked = 'true';
                    button.click();
                }
            }
        });
    })();
    """

    while True:
        try:
            send_js_command(ws, click_js)
        except Exception:
            # Reconnect if WS disconnects
            break
        time.sleep(1.0)


if __name__ == "__main__":
    while True:
        auto_click()
        time.sleep(5)
