# HUD Tab Bar Implementation Plan

## Overview
Consolidate navigation/filtering across Devices, Alerts, and Locations pages using a unified HUD-style tab bar component.

## Design Specifications

### Visual Design
- **Background**: `assets/images/ui_elements/hud_text_box.png` (slides under active tab)
- **Height**: 48px
- **Tab Count**: Exactly 3 tabs per page
- **Tab Width**: Equal width (33.3% each)
- **Icons**: 14px (very small)
- **Badge Format**: Number directly after label (e.g., "APs 12"), shows "99+" for counts > 99
- **Badge Color**: Grey[500] for all tabs
- **Active Tab**: White text, hud background with blue accent visible
- **Inactive Tabs**: Grey[400] text, no background
- **Animation**: 200ms slide transition

### Tab Configurations

#### Devices Page
```
[APs X] [Switches X] [ONTs X]
```
- Icons: Icons.wifi | Icons.hub | Icons.fiber_manual_record
- First tab (APs) auto-selected by default
- Filter values: 'Access Point' | 'Switch' | 'ONT'

#### Alerts/Notifications Page
```
[All X] [Offline X] [Docs X]
```
- Icons: Icons.list | Icons.error (red) | Icons.description (blue)
- Maps to: all | NotificationPriority.urgent | NotificationPriority.low

#### Locations/Rooms Page
```
[All X] [Ready X] [Issues X]
```
- Icons: Icons.list | Icons.check_circle (green) | Icons.warning (orange)
- Filter logic: all | !hasIssues | hasIssues

## Implementation Steps

### Step 1: Create HUD Tab Bar Widget
**File**: `lib/core/widgets/hud_tab_bar.dart`

```dart
class HUDTab {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final int count;
  final String filterValue; // for filtering logic
  
  const HUDTab({
    required this.label,
    required this.icon,
    required this.count,
    required this.filterValue,
    this.iconColor,
  });
}

class HUDTabBar extends StatefulWidget {
  final List<HUDTab> tabs;
  final int selectedIndex; // Always has a selection (0 by default)
  final Function(int) onTabSelected;
  final VoidCallback? onActiveTabTapped; // scroll to top
  
  const HUDTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onActiveTabTapped,
    super.key,
  });
}
```

**Features**:
- Stack widget with background image layer
- AnimatedPositioned for sliding background
- GestureDetector for each tab
- Tap handling (select or scroll-to-top)

**Widget Structure**:
```dart
Container(
  height: 48,
  child: Stack(
    children: [
      // Background layer - sliding hud_text_box.png
      AnimatedPositioned(
        duration: Duration(milliseconds: 200),
        left: (MediaQuery.of(context).size.width / 3) * selectedIndex,
        width: MediaQuery.of(context).size.width / 3,
        child: Image.asset('assets/images/ui_elements/hud_text_box.png'),
      ),
      // Tabs layer
      Row(
        children: tabs.map((tab) => Expanded(
          child: GestureDetector(
            onTap: () {
              if (index == selectedIndex) {
                onActiveTabTapped?.call();
              } else {
                onTabSelected(index);
              }
            },
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tab.icon, size: 14, color: tab.iconColor ?? textColor),
                  SizedBox(width: 4),
                  Text(tab.label, style: TextStyle(color: textColor)),
                  SizedBox(width: 3),
                  Text(
                    tab.count > 99 ? '99+' : tab.count.toString(),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
      ),
    ],
  ),
)
```

### Step 2: Update Devices Page

**Files to modify**:
1. `lib/features/devices/presentation/screens/devices_screen.dart`
2. `lib/features/devices/presentation/providers/device_ui_state.dart`

**Changes**:
1. Remove existing filter chips section (lines 112-153)
2. Remove DeviceFilterChip imports
3. Add HUDTabBar with 3 tabs
4. Add device type counts calculation
5. Add persistence to deviceUIStateNotifier
6. Implement scroll-to-top with ScrollController
7. Add _getTabIndex helper method

**Code location to replace** (devices_screen.dart:112-153):
```dart
// OLD: Filter chips
Container(
  height: 50,
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: ListView(...)
)

// NEW: HUD Tab Bar
HUDTabBar(
  tabs: [
    HUDTab(
      label: 'APs',
      icon: Icons.wifi,
      count: devices.where((d) => d.type == 'Access Point').length,
      filterValue: 'Access Point',
    ),
    HUDTab(
      label: 'Switches',
      icon: Icons.hub,
      count: devices.where((d) => d.type == 'Switch').length,
      filterValue: 'Switch',
    ),
    HUDTab(
      label: 'ONTs',
      icon: Icons.fiber_manual_record,
      count: devices.where((d) => d.type == 'ONT').length,
      filterValue: 'ONT',
    ),
  ],
  selectedIndex: _getTabIndex(uiState.filterType), // Default to 0 if 'all'
  onTabSelected: (index) {
    final filterValue = ['Access Point', 'Switch', 'ONT'][index];
    ref.read(deviceUIStateNotifierProvider.notifier).setFilterType(filterValue);
  },
  onActiveTabTapped: () => _scrollController.animateTo(0, ...),
)
```

### Step 3: Update Alerts Page

**File**: `lib/features/notifications/presentation/screens/notifications_screen.dart`

**Changes**:
1. Remove existing TabBar (lines 61-110)
2. Keep TabController for content switching
3. Add HUDTabBar
4. Connect to existing tab controller
5. Add scroll-to-top functionality

**Code location to replace** (notifications_screen.dart:61-110):
```dart
// OLD: Material TabBar
TabBar(
  controller: _tabController,
  tabs: [...]
)

// NEW: HUD Tab Bar
HUDTabBar(
  tabs: [
    HUDTab(
      label: 'All',
      icon: Icons.list,
      count: notifications.length,
      filterValue: 'all',
    ),
    HUDTab(
      label: 'Offline',
      icon: Icons.error,
      iconColor: Colors.red,
      count: notifications.where((n) => n.priority == NotificationPriority.urgent).length,
      filterValue: 'urgent',
    ),
    HUDTab(
      label: 'Docs',
      icon: Icons.description,
      iconColor: Colors.blue,
      count: notifications.where((n) => n.priority == NotificationPriority.low).length,
      filterValue: 'low',
    ),
  ],
  selectedIndex: _tabController.index,
  onTabSelected: (index) {
    _tabController.animateTo(index);
  },
  onActiveTabTapped: () => _scrollToTop(),
)
```

### Step 4: Add Filtering to Locations Page

**File**: `lib/features/rooms/presentation/screens/rooms_screen.dart`

**Changes**:
1. Add state management for selected filter
2. Add HUDTabBar after status cards
3. Implement filtering logic
4. Add empty states for filtered results

**New state**:
```dart
class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  int _selectedTabIndex = 0; // 0=All, 1=Ready, 2=Issues
  final ScrollController _scrollController = ScrollController();
  
  List<Room> _filterRooms(List<Room> rooms) {
    switch (_selectedTabIndex) {
      case 1: // Ready
        return rooms.where((r) => !r.hasIssues).toList();
      case 2: // Issues
        return rooms.where((r) => r.hasIssues).toList();
      default: // All
        return rooms;
    }
  }
}
```

**Add after status cards** (line ~87):
```dart
// Add HUD Tab Bar
HUDTabBar(
  tabs: [
    HUDTab(
      label: 'All',
      icon: Icons.list,
      count: rooms.length,
      filterValue: 'all',
    ),
    HUDTab(
      label: 'Ready',
      icon: Icons.check_circle,
      iconColor: Colors.green,
      count: rooms.where((r) => !r.hasIssues).length,
      filterValue: 'ready',
    ),
    HUDTab(
      label: 'Issues',
      icon: Icons.warning,
      iconColor: Colors.orange,
      count: rooms.where((r) => r.hasIssues).length,
      filterValue: 'issues',
    ),
  ],
  selectedIndex: _selectedTabIndex,
  onTabSelected: (index) {
    setState(() => _selectedTabIndex = index);
  },
  onActiveTabTapped: () => _scrollController.animateTo(0, ...),
),
const SizedBox(height: 8),
```

### Step 5: Delete Unused Components

**Files to delete**:
- `lib/features/devices/presentation/widgets/device_filter_chip.dart`

## Testing Plan

1. **Visual Testing**:
   - Verify hud_text_box.png displays correctly
   - Check slide animation smoothness
   - Confirm blue accent line visibility
   - Test icon sizes (14px)
   - Verify badge numbers update

2. **Functional Testing**:
   - Test filtering on each page
   - Verify empty states ("No X found") with appropriate icons
   - Test scroll-to-top on active tab tap
   - Verify persistence when navigating away and back
   - Verify badge shows "99+" for counts > 99

3. **Edge Cases**:
   - Zero counts in badges
   - Counts over 99 display as "99+"
   - Rapid tab switching
   - Screen rotation (if applicable)

## Rollback Plan

If issues arise:
1. Git revert the commit
2. Original implementations are preserved in git history
3. Can selectively revert per page if needed

## Implementation Notes

1. **Performance**: AnimatedPositioned might cause rebuilds - monitor performance
2. **Accessibility**: Ensure tab navigation works with screen readers
3. **Empty States**: Show tab icon with "No [category] found" message
4. **Badge Format**: Display actual count up to 99, then "99+" for larger numbers
5. **Default Selection**: Devices page starts with first tab (APs) selected

## Files to Modify Summary

1. CREATE: `lib/core/widgets/hud_tab_bar.dart`
2. MODIFY: `lib/features/devices/presentation/screens/devices_screen.dart`
3. MODIFY: `lib/features/notifications/presentation/screens/notifications_screen.dart`
4. MODIFY: `lib/features/rooms/presentation/screens/rooms_screen.dart`
5. DELETE: `lib/features/devices/presentation/widgets/device_filter_chip.dart`

## Estimated Changes
- ~200 lines added (new HUD widget)
- ~150 lines modified (updating pages)
- ~60 lines deleted (old filter chips)
- Net: +190 lines