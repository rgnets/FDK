#!/usr/bin/env python3

import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

def capture_console_logs():
    # Set up Chrome options for headless mode with console logging
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")
    
    # Enable browser logging
    caps = DesiredCapabilities.CHROME
    caps['goog:loggingPrefs'] = {'browser': 'ALL'}
    
    # Create driver
    driver = webdriver.Chrome(options=chrome_options, desired_capabilities=caps)
    
    try:
        print("📱 Loading Flutter app at http://localhost:8081...")
        driver.get("http://localhost:8081")
        
        # Wait for app to load and execute
        print("⏳ Waiting for app to load...")
        time.sleep(10)
        
        # Get console logs
        print("\n📊 Console Logs:")
        print("=" * 60)
        logs = driver.get_log('browser')
        
        for log in logs:
            level = log['level']
            message = log['message']
            # Filter and format relevant logs
            if any(keyword in message for keyword in ['DEVICES_PROVIDER', 'ROOMS_PROVIDER', 'HOME_SCREEN', 'API', 'Error', 'Warning']):
                print(f"[{level}] {message}")
        
        if not logs:
            print("No console logs captured")
            
        # Get page source to verify app loaded
        page_source = driver.page_source
        if 'RG Nets FDK' in page_source:
            print("\n✅ App loaded successfully (found 'RG Nets FDK' in page)")
        else:
            print("\n⚠️ App may not have loaded properly")
            
    finally:
        driver.quit()
        print("\n🏁 Browser closed")

if __name__ == "__main__":
    capture_console_logs()