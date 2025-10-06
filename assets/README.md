# Assets Directory Structure

This directory contains all visual assets for the RG Nets Field Deployment Kit Flutter application.

## Directory Structure

```
assets/
├── images/
│   ├── backgrounds/       # Background images for screens
│   ├── logos/             # App and brand logos
│   ├── mockups/           # UI mockup references
│   ├── onboarding/        # Onboarding screen images
│   └── ui_elements/       # UI components and decorative elements
├── icons/
│   ├── navigation/        # Bottom navigation icons
│   ├── status/            # Status indicator icons
│   ├── device_types/      # Icons for different device types
│   └── actions/           # Action button icons
├── animations/
│   └── placeholders/      # Placeholder for animation files
└── fonts/                 # Custom fonts (if needed)
```

## File Naming Conventions

- Use lowercase with underscores: `file_name.png`
- No spaces or special characters
- Descriptive names that indicate usage
- Include size suffix for multiple resolutions: `icon_24.png`, `icon_48.png`

## Image Assets

### Logos
- `fdk_logo.png` - Main app logo (PNG format)
- `fdk_logo.svg` - Main app logo (SVG format)

### Backgrounds
- `scanner_background.png` - Futuristic scanner background

### UI Elements
- `hud_box` - HUD frame element
- `hud_text_box` - HUD text container
- `hud_text_box_alt` - Alternative HUD text container

### Onboarding Screens
- `onboarding_welcome.png` - Welcome screen graphic
- `onboarding_features.png` - Features overview graphic
- `onboarding_connect.png` - Connection guide graphic

### Mockups (Reference Only)
Design mockups for development reference:
- `room_detail_screen.png` - Room details view
- `scanner_screen.png` - Main scanner view
- `scanner_mode_selector.png` - Scanner mode selection
- `device_validation_dialog.png` - Device validation overlay
- `device_registration_dialog.png` - Registration dialog
- `home_dashboard_screen.png` - Home dashboard
- `devices_list_screen.png` - Devices list view
- `device_detail_screen.png` - Device details view

## Required Assets (To Be Created)

### Icons Needed
- [ ] Navigation icons (home, scan, devices, notifications, rooms, settings)
- [ ] Status indicators (online, offline, warning, error, success)
- [ ] Device type icons (AP, ONT, Switch)
- [ ] Action icons (add, edit, delete, refresh, filter, search)

### Animations Needed
- [ ] Loading spinner
- [ ] Scanner animation
- [ ] Success checkmark
- [ ] Error animation
- [ ] Refresh pull animation

### Additional Graphics Needed
- [ ] RG Nets logo (official)
- [ ] App icon (multiple sizes for iOS/Android)
- [ ] Splash screen
- [ ] Empty state illustrations
- [ ] Error state illustrations

## Asset Declaration for pubspec.yaml

```yaml
flutter:
  assets:
    - assets/images/logos/
    - assets/images/backgrounds/
    - assets/images/ui_elements/
    - assets/images/onboarding/
    - assets/icons/navigation/
    - assets/icons/status/
    - assets/icons/device_types/
    - assets/icons/actions/
    - assets/animations/
```

## Platform-Specific Assets

### iOS
- App icons: Need to generate via Asset Catalog
- Launch images: Required for different screen sizes

### Android
- Launcher icons: Multiple densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Adaptive icons: Foreground and background layers
- Splash screen: XML drawable

## Notes
- Mockups in `images/mockups/` are for reference only and should not be included in production builds
- All production images should be optimized for size
- Consider using WebP format for better compression
- SVG files are preferred for icons when possible