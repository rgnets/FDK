// Debug script to check what data is being loaded in staging
// Run this in browser console when the app is loaded

console.log('=== STAGING DEBUG SCRIPT ===');
console.log('Looking for Flutter app data...');

// Override console methods to capture Flutter logs
let flutterLogs = [];
const originalLog = console.log;
console.log = function(...args) {
    const message = args.join(' ');
    if (message.includes('🚀') || message.includes('📊') || message.includes('🔧') || 
        message.includes('🏛️') || message.includes('📱') || message.includes('🌐') || 
        message.includes('✅') || message.includes('🚨')) {
        flutterLogs.push(message);
        document.body.insertAdjacentHTML('beforeend', `<div style="background: #f0f0f0; padding: 2px 5px; margin: 1px; font-family: monospace; font-size: 12px;">${message}</div>`);
    }
    originalLog.apply(console, args);
};

// Function to check current data
function checkCurrentData() {
    console.log('=== CHECKING CURRENT DATA ===');
    
    // Try to access Flutter app state
    if (window.flutterCanvasKit) {
        console.log('Flutter CanvasKit detected');
    }
    
    // Look for data in local storage
    console.log('Local Storage keys:', Object.keys(localStorage));
    for (let key of Object.keys(localStorage)) {
        if (key.includes('room') || key.includes('device') || key.includes('api')) {
            console.log(`LocalStorage[${key}]:`, localStorage.getItem(key));
        }
    }
    
    // Try to trigger a manual refresh
    setTimeout(() => {
        console.log('=== CAPTURED FLUTTER LOGS ===');
        flutterLogs.forEach(log => console.log(log));
        
        if (flutterLogs.length === 0) {
            console.log('No Flutter logs captured yet. The app might still be initializing.');
        }
    }, 2000);
}

// Run the check
checkCurrentData();

// Set up periodic checking
setInterval(() => {
    if (flutterLogs.length > 0) {
        console.log(`Captured ${flutterLogs.length} Flutter logs so far`);
    }
}, 5000);