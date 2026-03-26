import sys
import subprocess
import pyautogui
import win32gui
import time

def set_best_appearance():
    pyautogui.FAILSAFE = False
    pyautogui.PAUSE = 0.05
    subprocess.Popen("SystemPropertiesPerformance.exe")
    time.sleep(0.5)
    hwnd = win32gui.FindWindow(None, "效能選項")
    win32gui.ShowWindow(hwnd, 0)
    pyautogui.hotkey('alt', 'b')
    pyautogui.press('enter')

if __name__ == "__main__":
    sys.exit(set_best_appearance())