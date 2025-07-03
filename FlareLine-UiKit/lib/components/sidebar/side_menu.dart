// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:async';

import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_location_href/window_location_href.dart';

class SideMenuWidget extends StatelessWidget {
  dynamic e;
  bool? isDark;
  bool isCollapsed;
  ValueNotifier<String> expandedMenuName;
  static OverlayEntry? _currentTooltip;
  static Timer? _tooltipTimer;
  static Timer? _showTimer; // Add timer for delayed showing

  SideMenuWidget({
    super.key,
    this.e,
    this.isDark,
    required this.expandedMenuName,
    this.isCollapsed = false,
  });

  void setExpandedMenuName(String menuName) {
    if (expandedMenuName.value == menuName) {
      expandedMenuName.value = '';
    } else {
      expandedMenuName.value = menuName;
    }
  }

  bool isSelectedPath(BuildContext context, String path) {
    if (kIsWeb) {
      String? location = href;
      if (location != null) {
        var uri = Uri.dataFromString(location);
        String? routePath = uri.path;
        return routePath.endsWith(path);
      }
    }

    String? routePath = ModalRoute.of(context)?.settings.name;
    return routePath == path;
  }

  @override
  Widget build(BuildContext context) {
    isDark ??= false;
    return _itemMenuWidget(context, e, isDark!);
  }

  Widget _itemMenuWidget(BuildContext context, e, bool isDark) {
    String itemMenuName = e['menuName'] ?? '';
    List? childList = e['childList'];
    bool isSelected = childList != null && childList.isNotEmpty
        ? false
        : isSelectedPath(context, e['path'] ?? '');

    return Column(
      children: [
        Builder(
          builder: (BuildContext itemContext) => InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: isSelected
                    ? (isDark
                        ? const LinearGradient(
                            colors: [Color(0x0C316AFF), Color(0x38306AFF)],
                          )
                        : const LinearGradient(
                            colors: [
                              FlarelineColors.background,
                              FlarelineColors.gray
                            ],
                          ))
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (e['icon'] != null)
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        e['icon'],
                        width: 18,
                        height: 23,
                        color: isDark
                            ? Colors.white
                            : FlarelineColors.darkBlackText,
                      ),
                    ),
                  if (!isCollapsed) ...[
                    Expanded(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: Text(
                          itemMenuName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : FlarelineColors.darkBlackText,
                          ),
                        ),
                      ),
                    ),
                    if (childList != null && childList.isNotEmpty)
                      ValueListenableBuilder(
                        valueListenable: expandedMenuName,
                        builder: (ctx, menuName, child) {
                          bool expanded = menuName == itemMenuName;
                          return AnimatedOpacity(
                            opacity: isCollapsed ? 0 : 1,
                            duration: const Duration(milliseconds: 100),
                            child: Container(
                              width: 24,
                              alignment: Alignment.center,
                              child: Icon(
                                expanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: isDark
                                    ? Colors.white
                                    : FlarelineColors.darkBlackText,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
            onTap: () {
              _removeCurrentTooltip(); // Always remove tooltip on tap
              if (childList != null && childList.isNotEmpty) {
                setExpandedMenuName(itemMenuName);
              } else {
                pushOrJump(context, e);
              }
            },
            onHover: (hovering) {
              if (isCollapsed) {
                if (hovering) {
                  _scheduleTooltipShow(itemContext, e, isDark);
                } else {
                  _scheduleTooltipRemoval();
                }
              }
            },
          ),
        ),
        if (!isCollapsed && childList != null && childList.isNotEmpty)
          ValueListenableBuilder(
            valueListenable: expandedMenuName,
            builder: (ctx, menuName, child) {
              return AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Visibility(
                  visible: menuName == itemMenuName,
                  child: Column(
                    children: childList
                        .map((e) => _itemSubMenuWidget(context, e, isDark))
                        .toList(),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _itemSubMenuWidget(BuildContext context, e, bool isDark) {
    bool isSelected = isSelectedPath(context, e['path'] ?? '');
    String itemMenuName = e['menuName'] ?? '';
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? (isDark ? FlarelineColors.darkBackground : FlarelineColors.gray)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            const SizedBox(width: 40),
            Expanded(
              child: Text(
                itemMenuName,
                style: TextStyle(
                  color: isDark ? Colors.white : FlarelineColors.darkBlackText,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        _removeCurrentTooltip(); // Remove tooltip on tap
        pushOrJump(context, e);
      },
    );
  }

  static void _removeCurrentTooltip() {
    // Cancel all timers
    _tooltipTimer?.cancel();
    _tooltipTimer = null;
    _showTimer?.cancel();
    _showTimer = null;

    // Remove current tooltip
    if (_currentTooltip != null) {
      try {
        if (_currentTooltip!.mounted) {
          _currentTooltip!.remove();
        }
      } catch (e) {
        // Handle potential disposal errors
        debugPrint('Error removing tooltip: $e');
      } finally {
        _currentTooltip = null; // Ensure it's always set to null
      }
    }
  }

  void _scheduleTooltipShow(BuildContext context, dynamic e, bool isDark) {
    // Cancel any existing timers
    _tooltipTimer?.cancel();
    _showTimer?.cancel();

    // Remove existing tooltip immediately
    _removeCurrentTooltip();

    // Schedule showing with a small delay to prevent flickering
    _showTimer = Timer(const Duration(milliseconds: 300), () {
      // Double-check context is still valid
      if (context.mounted) {
        _showCollapsedMenuTooltip(context, e, isDark);
      }
    });
  }

  static void _scheduleTooltipRemoval() {
    // Cancel show timer if hovering stopped before tooltip was shown
    _showTimer?.cancel();
    _showTimer = null;

    // Cancel any existing removal timer
    _tooltipTimer?.cancel();

    // Schedule removal with a small delay
    _tooltipTimer = Timer(const Duration(milliseconds: 100), () {
      _removeCurrentTooltip();
    });
  }

  void _showCollapsedMenuTooltip(BuildContext context, dynamic e, bool isDark) {
    // Always remove existing tooltip first
    _removeCurrentTooltip();

    // Validate context before proceeding
    if (!context.mounted) return;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    // Calculate tooltip position with bounds checking
    double left = offset.dx + renderBox.size.width + 8;
    double top = offset.dy;

    // Adjust if tooltip would go off screen
    const tooltipWidth = 160.0;
    if (left + tooltipWidth > screenSize.width) {
      left = offset.dx - tooltipWidth - 8; // Show on left side instead
    }

    // Ensure tooltip doesn't go off top or bottom of screen
    const tooltipMaxHeight = 200.0;
    if (top + tooltipMaxHeight > screenSize.height) {
      top = screenSize.height - tooltipMaxHeight - 8;
    }
    if (top < 0) {
      top = 8;
    }

    _currentTooltip = OverlayEntry(
      builder: (overlayContext) => Positioned(
        left: left,
        top: top,
        child: MouseRegion(
          onEnter: (_) {
            // Cancel removal when mouse enters tooltip
            _tooltipTimer?.cancel();
            _tooltipTimer = null;
          },
          onExit: (_) {
            _scheduleTooltipRemoval();
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 160,
              constraints: const BoxConstraints(maxWidth: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main menu item
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Text(
                      e['menuName'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (e['childList'] != null && e['childList'].isNotEmpty) ...[
                    Divider(
                      height: 8,
                      thickness: 0.5,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                    ...e['childList'].map<Widget>((child) {
                      return InkWell(
                        onTap: () {
                          _removeCurrentTooltip();
                          // Use the original context for navigation, not overlayContext
                          pushOrJump(context, child);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  child['menuName'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      overlay.insert(_currentTooltip!);
    } catch (e) {
      debugPrint('Error inserting tooltip: $e');
      _currentTooltip = null;
    }
  }

  void pushOrJump(BuildContext context, e) {
    // Remove tooltip when navigating
    _removeCurrentTooltip();

    if (Scaffold.of(context).isDrawerOpen) {
      Scaffold.of(context).closeDrawer();
    }

    String path = e['path'];
    String? routePath = ModalRoute.of(context)?.settings.name;

    if (path == routePath) {
      return;
    }
    Navigator.of(context).pushNamed(path);
  }
}
