# Running the RG Nets Field Deployment Kit

## Quick Start

The app has three different modes for different purposes:

### 1. Development Mode (Mock Data)
```bash
./scripts/run_development.sh
# OR manually:
flutter build web -t lib/main_development.dart
cd build/web && python3 -m http.server 8089
```
- **URL:** http://localhost:8089
- **Purpose:** Development and testing with mock data
- **Authentication:** Not required
- **Data:** Synthetic/mock data

### 2. Staging Mode (Test API)
```bash
./scripts/run_staging.sh
# OR manually:
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8091 -t lib/main_staging.dart
```
- **URL:** http://localhost:8091
- **Purpose:** Testing with real API using read-only test credentials
- **Authentication:** Automatic (uses interurban test credentials)
- **Data:** Real data from test environment (221 APs, 151 ONTs, 1 switch, 141 rooms)

### 3. Production Mode (Customer API)
```bash
./scripts/run_production.sh
# OR manually:
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080 -t lib/main.dart
```
- **URL:** http://localhost:8080
- **Purpose:** Production deployment for actual customer use
- **Authentication:** Required (scan customer QR code)
- **Data:** Real customer data

## Important Notes

### Network Binding Issue
⚠️ **CRITICAL:** When running Flutter web server, you MUST use `--web-hostname=0.0.0.0` to allow external connections.

**Wrong (only localhost access):**
```bash
flutter run -d web-server --web-port=8091 -t lib/main_staging.dart
```

**Correct (accessible from network):**
```bash
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8091 -t lib/main_staging.dart
```

Without the `--web-hostname=0.0.0.0` flag, the server will only bind to localhost and you'll get connection refused errors when trying to access from:
- Different browser tabs
- Other devices on the network
- Docker containers
- Virtual machines

### Debugging Tips

1. **Check if server is running:**
```bash
lsof -i :8091  # Check specific port
```

2. **Kill existing processes:**
```bash
lsof -ti:8091 | xargs kill -9  # Kill process on specific port
```

3. **View console logs:**
- Open browser DevTools (F12)
- Check Console tab for API calls and debug messages
- Look for environment indicators:
  - `🔧 EnvironmentConfig: Setting environment to staging`
  - `📱 DeviceRepositoryImpl: Using STAGING/PRODUCTION MODE`
  - `🌐 API Request: GET https://...`

### Environment Detection

The app detects its environment based on the entry point:
- `main_development.dart` → Development mode (mock data)
- `main_staging.dart` → Staging mode (test API)
- `main.dart` → Production mode (customer API)

### API Endpoints Used

**Staging/Production endpoints:**
- `/api/access_points.json` - Access points (paginated)
- `/api/media_converters.json` - ONTs (paginated)
- `/api/switch_devices.json` - Switches (paginated)
- `/api/wlan_devices.json` - WLAN controllers (paginated)
- `/api/pms_rooms.json` - PMS rooms (paginated)
- `/api/whoami.json` - Authentication check

### Troubleshooting

**Problem: "Unable to connect to port 8091"**
- Solution: Use `--web-hostname=0.0.0.0` flag
- Check: `lsof -i :8091` should show `*:8091` not `localhost:8091`

**Problem: "Seeing mock data in staging mode"**
- Check console for: `EnvironmentConfig: Setting environment to staging`
- Verify: `AppConfig.isDevelopment` should be `false`
- Look for: API request logs in browser console

**Problem: "No devices showing"**
- Check browser console for API errors
- Verify authentication headers are being sent
- Look for pagination handling (multiple pages of data)

## Development Workflow

1. **Start in development mode** for initial feature development
2. **Test in staging mode** to verify API integration
3. **Deploy in production mode** for customer use

## Testing API Connection

Use the provided test scripts to verify API connectivity:
```bash
# Python test
python3 test_api_connection.py

# Shell test
./test_api_connection.sh

# Dart test
dart test_api_connection.dart
```

These scripts will test all API endpoints and show what data is available.