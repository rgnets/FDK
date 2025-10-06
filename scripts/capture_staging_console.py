#!/usr/bin/env python3

import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def capture_console():
    # Configure Chrome options
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--disable-web-security')
    chrome_options.set_capability('goog:loggingPrefs', {'browser': 'ALL'})
    
    # Create driver
    driver = webdriver.Chrome(options=chrome_options)
    
    try:
        print("Loading Flutter app...")
        driver.get("http://localhost:5003")
        
        # Wait for app to load
        time.sleep(5)
        
        # Get console logs
        logs = driver.get_log('browser')
        
        print("\n" + "="*70)
        print("CONSOLE OUTPUT FROM STAGING APP")
        print("="*70)
        
        for log in logs:
            level = log['level']
            message = log['message']
            # Filter out noise
            if 'favicon' not in message and 'fonts.googleapis' not in message:
                print(f"[{level}] {message}")
        
        # Navigate to devices page
        print("\nNavigating to devices page...")
        driver.get("http://localhost:5003/#/devices")
        time.sleep(3)
        
        # Get new logs
        new_logs = driver.get_log('browser')
        if new_logs:
            print("\n" + "="*70)
            print("LOGS AFTER NAVIGATING TO DEVICES")
            print("="*70)
            for log in new_logs:
                message = log['message']
                if 'DEVICE' in message or 'API' in message or 'Error' in message:
                    print(f"[{log['level']}] {message}")
    
    finally:
        driver.quit()

if __name__ == "__main__":
    capture_console()