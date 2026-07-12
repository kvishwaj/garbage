# pip install pyautogui opencv-python pillow pygetwindow
import time
import pyautogui
import pygetwindow as gw

# Standard Windows Safe-guard: Slam your mouse into any corner of the screen to kill the script execution
pyautogui.FAILSAFE = True

# Target Devin IDE Window
WINDOW_TITLE_KEYWORD = "Devin"
IMAGE_PATH = "run_button.png"

print("Sequential Auto-Clicker initiated...")
print("Analyzing screen for queued 'Run' buttons...")


def get_devin_window_bounds():
    # Attempt to locate the Devin IDE window to focus our scan
    windows = gw.getWindowsWithTitle(WINDOW_TITLE_KEYWORD)
    if windows:
        win = windows[0]
        # Returns (left, top, width, height)
        return (win.left, win.top, win.width, win.height)
    return None


while True:
    region = get_devin_window_bounds()

    if region:
        try:
            # Find ALL instances of the purple Run button within the Devin window
            # confidence=0.8 permits minor display rendering differences
            button_matches = list(
                pyautogui.locateAllOnScreen(
                    IMAGE_PATH, region=region, confidence=0.8
                )
            )

            if button_matches:
                print(f"Found {len(button_matches)} Run button(s) on screen.")

                # SORT logic: Sort elements by their 'top' coordinate (Y-axis) ascending.
                # This guarantees matches[0] is the top-most button on your screen.
                button_matches.sort(key=lambda box: box.top)
                target_button = button_matches[0]

                # 1. Save where your physical mouse cursor was
                orig_x, orig_y = pyautogui.position()

                # 2. Find center of the top-most button
                click_point = pyautogui.center(target_button)

                # 3. Fast-travel mouse, click, and return to where you were working
                pyautogui.click(click_point)
                pyautogui.moveTo(orig_x, orig_y)

                print("Clicked the top-most 'Run' button!")

                # Cooldown period (6 seconds) to allow the command to execute
                # and prevent double-triggering before the UI updates
                time.sleep(6.0)

        except pyautogui.ImageNotFoundException:
            pass  # No buttons visible on screen right now
        except Exception as e:
            print(f"Error encountered: {e}")

    else:
        print(f"Could not find window containing '{WINDOW_TITLE_KEYWORD}'")
        time.sleep(5.0)

    # Re-check screen state every 1 second
    time.sleep(1.0)
