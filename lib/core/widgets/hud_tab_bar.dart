import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';

/// Model class for HUD tab data
class HUDTab {
  const HUDTab({
    required this.label,
    required this.icon,
    required this.count,
    required this.filterValue,
    this.iconColor,
  });
  
  final String label;
  final IconData icon;
  final Color? iconColor;
  final int count;
  final String filterValue;
}

/// HUD-style tab bar with sliding background
class HUDTabBar extends StatefulWidget {
  const HUDTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onActiveTabTapped,
    this.height = 48,
    this.showFullCount = false,
    super.key,
  }) : assert(tabs.length == 3, 'HUDTabBar requires exactly 3 tabs');
  
  final List<HUDTab> tabs;
  final int selectedIndex;
  final void Function(int) onTabSelected;
  final VoidCallback? onActiveTabTapped;
  final double height;
  final bool showFullCount;

  @override
  State<HUDTabBar> createState() => _HUDTabBarState();
}

class _HUDTabBarState extends State<HUDTabBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: widget.selectedIndex.toDouble(),
      end: widget.selectedIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    LoggerService.debug(
      'HUDTabBar initialized with ${widget.tabs.length} tabs, selected: ${widget.selectedIndex}',
      tag: 'HUDTabBar',
    );
  }

  @override
  void didUpdateWidget(HUDTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      LoggerService.debug(
        'HUDTabBar selection changed from ${oldWidget.selectedIndex} to ${widget.selectedIndex}',
        tag: 'HUDTabBar',
      );
      _animateToIndex(widget.selectedIndex);
    }
  }

  void _animateToIndex(int index) {
    _slideAnimation = Tween<double>(
      begin: _previousIndex.toDouble(),
      end: index.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _previousIndex = index;
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / 3;

    LoggerService.debug(
      'Building HUDTabBar - Screen width: $screenWidth, Tab width: $tabWidth',
      tag: 'HUDTabBar',
    );

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Positioned(
                left: _slideAnimation.value * tabWidth,
                width: tabWidth,
                height: widget.height,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/images/ui_elements/hud_text_box.png'),
                      fit: BoxFit.fill,
                      colorFilter: ColorFilter.mode(
                        Colors.blue.withValues(alpha: 0.3),
                        BlendMode.modulate,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Tabs
          Row(
            children: List.generate(widget.tabs.length, (index) {
              final tab = widget.tabs[index];
              final isSelected = index == widget.selectedIndex;
              
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    LoggerService.debug(
                      'Tab tapped: ${tab.label} (index: $index, selected: $isSelected)',
                      tag: 'HUDTabBar',
                    );
                    
                    if (isSelected) {
                      // Tap on active tab - scroll to top
                      widget.onActiveTabTapped?.call();
                      LoggerService.debug('Active tab tapped - triggering scroll to top', tag: 'HUDTabBar');
                    } else {
                      // Select new tab
                      widget.onTabSelected(index);
                      LoggerService.debug('New tab selected: ${tab.label}', tag: 'HUDTabBar');
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: widget.height > 48
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tab.icon,
                              size: widget.height > 60 ? 20 : 16,
                              color: tab.iconColor ?? (isSelected ? Colors.white : Colors.grey[400]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.count.toString(),
                              style: TextStyle(
                                fontSize: widget.height > 60 ? 20 : 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey[300],
                              ),
                            ),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.grey[400],
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tab.icon,
                              size: 14,
                              color: tab.iconColor ?? (isSelected ? Colors.white : Colors.grey[400]),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.showFullCount || tab.count <= 99 ? tab.count.toString() : '99+',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}