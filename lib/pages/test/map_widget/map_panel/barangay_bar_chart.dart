import 'package:flutter/material.dart';
import 'dart:math' as math;

enum BarChartDisplayMode { volume, yieldPerHa }

class MonthlyBarChart extends StatefulWidget {
  final String product;
  final int year;
  final Map<String, Map<String, double>> monthlyData;

  const MonthlyBarChart({
    super.key,
    required this.product,
    required this.year,
    required this.monthlyData,
  });

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  BarChartDisplayMode _displayMode = BarChartDisplayMode.volume;

  bool get _hasAreaData {
    return widget.monthlyData.values.any((data) => 
      (data['areaHarvested'] ?? 0) > 0
    );
  }

  Map<String, double> _getDisplayData() {
    final displayData = <String, double>{};
    
    for (final entry in widget.monthlyData.entries) {
      final month = entry.key;
      final data = entry.value;
      final volume = data['volume'] ?? 0;
      final areaHarvested = data['areaHarvested'] ?? 0;
      
      if (_displayMode == BarChartDisplayMode.volume) {
        displayData[month] = volume;
        // Print volume values
        print('$month Volume: $volume kg');
      } else {
        // Calculate yield per hectare (kg/ha)
        final yieldPerHa = areaHarvested > 0 ? volume / areaHarvested : 0;
        displayData[month] = yieldPerHa.toDouble();
        // Print yield per hectare values
        print('$month Yield per Hectare: $yieldPerHa kg/ha');
      }
    }
    
    return displayData;
  }

  String _getUnit() {
    return _displayMode == BarChartDisplayMode.volume ? 'kg' : 'kg/ha';
  }

  String _getTitle() {
    final modeText = _displayMode == BarChartDisplayMode.volume 
        ? 'Production' 
        : 'Yield per Hectare';
    return '${widget.product} - Monthly $modeText (${widget.year})';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayData = _getDisplayData();
    
    return Container(
      height: 450, // Increased height to accommodate toggle
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_hasAreaData) _buildDisplayModeToggle(theme),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: displayData.isEmpty || displayData.values.every((v) => v == 0)
                ? Center(
                    child: Text(
                      _hasAreaData 
                          ? 'No data available'
                          : _displayMode == BarChartDisplayMode.yieldPerHa
                              ? 'No area data available for yield calculation'
                              : 'No data available',
                      style: TextStyle(color: theme.hintColor),
                      textAlign: TextAlign.center,
                    ),
                  )
                : CustomPaint(
                    painter: BarChartPainter(
                      data: displayData,
                      primaryColor: theme.primaryColor,
                      textColor: theme.textTheme.bodyMedium?.color ?? Colors.black,
                      backgroundColor: theme.canvasColor,
                      isMonthly: true,
                      unit: _getUnit(),
                    ),
                    child: Container(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayModeToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
        color: theme.brightness == Brightness.dark
            ? theme.primaryColor.withOpacity(0.1)
            : Colors.grey.shade50,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: 'Volume',
            icon: Icons.inventory,
            isSelected: _displayMode == BarChartDisplayMode.volume,
            onTap: () => setState(() => _displayMode = BarChartDisplayMode.volume),
            theme: theme,
          ),
          Container(
            width: 1,
            height: 28,
            color: theme.dividerColor,
          ),
          _buildToggleButton(
            label: 'Kg/Ha',
            icon: Icons.agriculture,
            isSelected: _displayMode == BarChartDisplayMode.yieldPerHa,
            onTap: () => setState(() => _displayMode = BarChartDisplayMode.yieldPerHa),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? theme.primaryColor
                  : theme.iconTheme.color?.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : null,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YearlyBarChart extends StatefulWidget {
  final String product;
  final Map<String, Map<String, double>> yearlyData;

  const YearlyBarChart({
    super.key,
    required this.product,
    required this.yearlyData,
  });

  @override
  State<YearlyBarChart> createState() => _YearlyBarChartState();
}

class _YearlyBarChartState extends State<YearlyBarChart> {
  BarChartDisplayMode _displayMode = BarChartDisplayMode.volume;

  bool get _hasAreaData {
    return widget.yearlyData.values.any((data) => 
      (data['areaHarvested'] ?? 0) > 0
    );
  }

  Map<String, double> _getDisplayData() {
    final displayData = <String, double>{};
    
    for (final entry in widget.yearlyData.entries) {
      final year = entry.key;
      final data = entry.value;
      final volume = data['volume'] ?? 0;
      final areaHarvested = data['areaHarvested'] ?? 0;
      
      if (_displayMode == BarChartDisplayMode.volume) {
        displayData[year] = volume;
        // Print volume values
        print('$year Volume: $volume kg');
      } else {
        // Calculate yield per hectare (kg/ha)
        final yieldPerHa = areaHarvested > 0 ? volume / areaHarvested : 0;
        displayData[year] = yieldPerHa.toDouble();
        // Print yield per hectare values
        print('$year Yield per Hectare: $yieldPerHa kg/ha');
      }
    }
    
    return displayData;
  }

  String _getUnit() {
    return _displayMode == BarChartDisplayMode.volume ? 'kg' : 'kg/ha';
  }

  String _getTitle() {
    final modeText = _displayMode == BarChartDisplayMode.volume 
        ? 'Production' 
        : 'Yield per Hectare';
    return '${widget.product} - Yearly $modeText';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayData = _getDisplayData();
    
    return Container(
      height: 450, // Increased height to accommodate toggle
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_hasAreaData) _buildDisplayModeToggle(theme),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: displayData.isEmpty || displayData.values.every((v) => v == 0)
                ? Center(
                    child: Text(
                      _hasAreaData 
                          ? 'No data available'
                          : _displayMode == BarChartDisplayMode.yieldPerHa
                              ? 'No area data available for yield calculation'
                              : 'No data available',
                      style: TextStyle(color: theme.hintColor),
                      textAlign: TextAlign.center,
                    ),
                  )
                : CustomPaint(
                    painter: BarChartPainter(
                      data: displayData,
                      primaryColor: theme.primaryColor,
                      textColor: theme.textTheme.bodyMedium?.color ?? Colors.black,
                      backgroundColor: theme.canvasColor,
                      isMonthly: false,
                      unit: _getUnit(),
                    ),
                    child: Container(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayModeToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
        color: theme.brightness == Brightness.dark
            ? theme.primaryColor.withOpacity(0.1)
            : Colors.grey.shade50,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: 'Volume',
            icon: Icons.inventory,
            isSelected: _displayMode == BarChartDisplayMode.volume,
            onTap: () => setState(() => _displayMode = BarChartDisplayMode.volume),
            theme: theme,
          ),
          Container(
            width: 1,
            height: 28,
            color: theme.dividerColor,
          ),
          _buildToggleButton(
            label: 'Kg/Ha',
            icon: Icons.agriculture,
            isSelected: _displayMode == BarChartDisplayMode.yieldPerHa,
            onTap: () => setState(() => _displayMode = BarChartDisplayMode.yieldPerHa),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? theme.primaryColor
                  : theme.iconTheme.color?.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : null,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Color primaryColor;
  final Color textColor;
  final Color backgroundColor;
  final bool isMonthly;
  final String unit;

  BarChartPainter({
    required this.data,
    required this.primaryColor,
    required this.textColor,
    required this.backgroundColor,
    required this.isMonthly,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = textColor.withOpacity(0.2)
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: textColor,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    final labelTextStyle = TextStyle(
      color: textColor,
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );

    // Chart dimensions
    const leftPadding = 70.0; // Increased for unit display
    const rightPadding = 20.0;
    const topPadding = 30.0; // Increased for value labels
    const bottomPadding = 40.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Find max value for scaling
    final maxValue = data.values.reduce(math.max);
    final minValue = data.values.reduce(math.min);
    final valueRange = maxValue - minValue;
    final adjustedMax = valueRange > 0 ? maxValue + (valueRange * 0.1) : maxValue + 1;

    // Sort data for consistent display
    final sortedEntries = data.entries.toList();
    if (isMonthly) {
      // Sort months chronologically
      final monthOrder = ['January', 'February', 'March', 'April', 'May', 'June',
                         'July', 'August', 'September', 'October', 'November', 'December'];
      sortedEntries.sort((a, b) {
        final aIndex = monthOrder.indexOf(a.key);
        final bIndex = monthOrder.indexOf(b.key);
        return aIndex.compareTo(bIndex);
      });
    } else {
      // Sort years numerically
      sortedEntries.sort((a, b) => a.key.compareTo(b.key));
    }

    // Draw Y-axis unit label
    final unitPainter = TextPainter(
      text: TextSpan(text: '($unit)', style: textStyle.copyWith(fontSize: 10)),
      textDirection: TextDirection.ltr,
    );
    unitPainter.layout();
    canvas.save();
    canvas.translate(20, size.height / 2);
    canvas.rotate(-math.pi / 2);
    unitPainter.paint(canvas, Offset(-unitPainter.width / 2, 0));
    canvas.restore();

    // Draw grid lines and Y-axis labels
    final gridLineCount = 5;
    for (int i = 0; i <= gridLineCount; i++) {
      final y = topPadding + (chartHeight * i / gridLineCount);
      final value = adjustedMax * (1 - i / gridLineCount);
      
      // Draw grid line
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + chartWidth, y),
        gridPaint,
      );

      // Draw Y-axis label
      final textPainter = TextPainter(
        text: TextSpan(
          text: value >= 1000 
              ? '${(value / 1000).toStringAsFixed(1)}k' 
              : value.toStringAsFixed(0),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // Draw bars and X-axis labels
    final barWidth = chartWidth / sortedEntries.length * 0.7;
    final barSpacing = chartWidth / sortedEntries.length * 0.3;

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final barHeight = adjustedMax > 0 ? (entry.value / adjustedMax) * chartHeight : 0;
      
      final barX = leftPadding + (i * chartWidth / sortedEntries.length) + barSpacing / 2;
      final barY = topPadding + chartHeight - barHeight;

      // Create gradient for bars
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.8),
          primaryColor,
        ],
      );

      final gradientPaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(
            barX.toDouble(),
            barY.toDouble(),
            barWidth.toDouble(),
            barHeight.toDouble(),
          ),
        );

      // Draw bar with rounded corners
      if (barHeight > 0) {
        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            barX.toDouble(),
            barY.toDouble(),
            barWidth.toDouble(),
            barHeight.toDouble(),
          ),
          const Radius.circular(4),
        );
        canvas.drawRRect(barRect, gradientPaint);

        // Draw value on top of bar
        final valuePainter = TextPainter(
          text: TextSpan(
            text: entry.value >= 1000 
                ? '${(entry.value / 1000).toStringAsFixed(1)}k'
                : entry.value.toStringAsFixed(1),
            style: textStyle.copyWith(fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        );
        valuePainter.layout();
        valuePainter.paint(
          canvas,
          Offset(
            barX + barWidth / 2 - valuePainter.width / 2,
            barY - valuePainter.height - 4,
          ),
        );
      }

      // Draw X-axis label (abbreviated for monthly)
      final displayLabel = isMonthly 
          ? entry.key.length > 3 ? entry.key.substring(0, 3) : entry.key
          : entry.key;
          
      final labelPainter = TextPainter(
        text: TextSpan(text: displayLabel, style: labelTextStyle),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(
          barX + barWidth / 2 - labelPainter.width / 2,
          topPadding + chartHeight + 8,
        ),
      );
    }

    // Draw chart border
    final borderPaint = Paint()
      ..color = textColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(
      Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) {
    return other is BarChartPainter &&
        other.data == data &&
        other.primaryColor == primaryColor &&
        other.textColor == textColor &&
        other.isMonthly == isMonthly &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(data, primaryColor, textColor, isMonthly, unit);
}