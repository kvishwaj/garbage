import time
import pyautogui
import pygetwindow as gw

# Standard Windows Safeguard: Slam mouse pointer to any of your screen's 4 corners to kill script
pyautogui.FAILSAFE = True

print("Looking for running Devin IDE...")


def get_devin_window_region():
    # Find the active Devin window on the OS
    windows = gw.getWindowsWithTitle("Devin")
    if windows:
        devin_win = windows[0]
        # Return bounding box: (left, top, width, height)
        return (
            devin_win.left,
            devin_win.top,
            devin_win.width,
            devin_win.height,
        )
    return None


while True:
    region = get_devin_window_region()

    if region:
        try:
            # Look for the button ONLY inside the Devin IDE window area
            button_box = pyautogui.locateOnScreen(
                "run_button.png", region=region, confidence=0.8
            )

            if button_box:
                # 1. Store your current screen working coordinates
                orig_x, orig_y = pyautogui.position()

                # 2. Extract click target center
                click_target = pyautogui.center(button_box)

                # 3. Teleport mouse, click, and return in milliseconds
                pyautogui.click(click_target)
                pyautogui.moveTo(orig_x, orig_y)

                print("Automatically approved Devin's action!")
                time.sleep(4.0)  # Cooldown to match engine render cycle

        except pyautogui.ImageNotFoundException:
            pass  # Button is not visible right now
        except Exception as e:
            print(f"Error: {e}")

    else:
        print("Devin IDE window not found. Please make sure the app is open.")
        time.sleep(5.0)

    # Scan the window twice a second
    time.sleep(0.5)
