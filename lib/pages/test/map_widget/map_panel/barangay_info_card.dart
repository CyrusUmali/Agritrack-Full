import 'package:flutter/material.dart';
import '../polygon_manager.dart';

class BarangayInfoCard {
  static Widget build({
    required BuildContext context,
    required PolygonData barangay,
    required ThemeData theme,
    bool elevated = true,
  }) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 12 : 8),
        vertical: isMobile ? 8 : (isTablet ? 6 : 4),
      ),
      elevation: elevated ? (isMobile ? 3 : 2) : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 10),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 10),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 14 : 12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              _buildHeader(
                  context, barangay, theme, isMobile, isTablet, isDesktop),

              SizedBox(height: isMobile ? 12 : (isTablet ? 10 : 8)),

              // Stats Grid - responsive layout
              _buildStatsGrid(context, theme, isMobile, isTablet, isDesktop),

              // Description
              if (barangay.description != null) ...[
                SizedBox(height: isMobile ? 12 : (isTablet ? 10 : 8)),
                _buildDescription(
                    context, barangay, theme, isMobile, isTablet, isDesktop),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHeader(
    BuildContext context,
    PolygonData barangay,
    ThemeData theme,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          color: theme.colorScheme.primary,
          size: isMobile ? 20 : (isTablet ? 18 : 16),
        ),
        SizedBox(width: isMobile ? 8 : (isTablet ? 6 : 4)),
        Expanded(
          child: Text(
            barangay.name,
            style: _getTitleTextStyle(theme, isMobile, isTablet, isDesktop),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static TextStyle? _getTitleTextStyle(
    ThemeData theme,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    if (isMobile) {
      return theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      );
    } else if (isTablet) {
      return theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      );
    } else {
      return theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        fontSize: 16,
      );
    }
  }

  static Widget _buildStatsGrid(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final crossAxisCount = isMobile ? 2 : 3;
    final childAspectRatio = isMobile ? 3.0 : (isTablet ? 2.8 : 2.5);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: isMobile ? 8 : (isTablet ? 6 : 4),
      crossAxisSpacing: isMobile ? 8 : (isTablet ? 6 : 4),
      children: [
        _buildStatItem(
          icon: Icons.landscape,
          label: 'Area',
          value: ' hectares',
          theme: theme,
          isMobile: isMobile,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        _buildStatItem(
          icon: Icons.home_work_outlined,
          label: 'Farms',
          value: '0',
          theme: theme,
          isMobile: isMobile,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        _buildStatItem(
          icon: Icons.people_outline,
          label: 'Farmers',
          value: '0',
          theme: theme,
          isMobile: isMobile,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
      ],
    );
  }

  static Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return Tooltip(
      message: '$label: $value',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isMobile ? 18 : (isTablet ? 16 : 14),
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(width: isMobile ? 8 : (isTablet ? 6 : 4)),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style:
                      _getLabelTextStyle(theme, isMobile, isTablet, isDesktop),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style:
                      _getValueTextStyle(theme, isMobile, isTablet, isDesktop),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static TextStyle? _getLabelTextStyle(
    ThemeData theme,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    if (isMobile) {
      return theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      );
    } else {
      return theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
        fontSize: isTablet ? 12 : 11,
      );
    }
  }

  static TextStyle? _getValueTextStyle(
    ThemeData theme,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    if (isMobile) {
      return theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
      );
    } else {
      return theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: isTablet ? 13 : 12,
      );
    }
  }

  static Widget _buildDescription(
    BuildContext context,
    PolygonData barangay,
    ThemeData theme,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Text(
      barangay.description!,
      style: _getDescriptionTextStyle(theme, isMobile, isTablet, isDesktop),
      maxLines: isMobile ? 3 : (isTablet ? 2 : 2),
      overflow: TextOverflow.ellipsis,
    );
  }

  static TextStyle? _getDescriptionTextStyle(
    ThemeData theme,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
      fontSize: isMobile ? 14 : (isTablet ? 13 : 12),
    );
  }
}
