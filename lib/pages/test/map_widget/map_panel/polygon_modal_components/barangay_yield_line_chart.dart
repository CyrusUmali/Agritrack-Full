import 'package:flutter/material.dart';
import 'dart:math' as math;

enum LineChartDisplayMode { volume, yieldPerHa }

class MonthlyLineChart extends StatefulWidget {
  final String product;
  final int year;
  final Map<String, Map<String, double>> monthlyData;

  const MonthlyLineChart({
    super.key,
    required this.product,
    required this.year,
    required this.monthlyData,
  });

  @override
  State<MonthlyLineChart> createState() => _MonthlyLineChartState();
}

class _MonthlyLineChartState extends State<MonthlyLineChart> {
  LineChartDisplayMode _displayMode = LineChartDisplayMode.volume;

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
      
      if (_displayMode == LineChartDisplayMode.volume) {
        displayData[month] = volume;
      } else {
        // Calculate yield per hectare (kg/ha)
        displayData[month] = areaHarvested > 0 ? volume / areaHarvested : 0;
      }
    }
    
    return displayData;
  }

  String _getUnit() {
    return _displayMode == LineChartDisplayMode.volume ? 'kg' : 'kg/ha';
  }

  String _getTitle() {
    final modeText = _displayMode == LineChartDisplayMode.volume 
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
                Icons.show_chart,
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
                          : _displayMode == LineChartDisplayMode.yieldPerHa
                              ? 'No area data available for yield calculation'
                              : 'No data available',
                      style: TextStyle(color: theme.hintColor),
                      textAlign: TextAlign.center,
                    ),
                  )
                : CustomPaint(
                    painter: LineChartPainter(
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
            isSelected: _displayMode == LineChartDisplayMode.volume,
            onTap: () => setState(() => _displayMode = LineChartDisplayMode.volume),
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
            isSelected: _displayMode == LineChartDisplayMode.yieldPerHa,
            onTap: () => setState(() => _displayMode = LineChartDisplayMode.yieldPerHa),
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

class YearlyLineChart extends StatefulWidget {
  final String product;
  final Map<String, Map<String, double>> yearlyData;

  const YearlyLineChart({
    super.key,
    required this.product,
    required this.yearlyData,
  });

  @override
  State<YearlyLineChart> createState() => _YearlyLineChartState();
}

class _YearlyLineChartState extends State<YearlyLineChart> {
  LineChartDisplayMode _displayMode = LineChartDisplayMode.volume;

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
      
      if (_displayMode == LineChartDisplayMode.volume) {
        displayData[year] = volume;
      } else {
        // Calculate yield per hectare (kg/ha)
        displayData[year] = areaHarvested > 0 ? volume / areaHarvested : 0;
      }
    }
    
    return displayData;
  }

  String _getUnit() {
    return _displayMode == LineChartDisplayMode.volume ? 'kg' : 'kg/ha';
  }

  String _getTitle() {
    final modeText = _displayMode == LineChartDisplayMode.volume 
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
                Icons.show_chart,
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
                          : _displayMode == LineChartDisplayMode.yieldPerHa
                              ? 'No area data available for yield calculation'
                              : 'No data available',
                      style: TextStyle(color: theme.hintColor),
                      textAlign: TextAlign.center,
                    ),
                  )
                : CustomPaint(
                    painter: LineChartPainter(
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
            isSelected: _displayMode == LineChartDisplayMode.volume,
            onTap: () => setState(() => _displayMode = LineChartDisplayMode.volume),
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
            isSelected: _displayMode == LineChartDisplayMode.yieldPerHa,
            onTap: () => setState(() => _displayMode = LineChartDisplayMode.yieldPerHa),
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

class LineChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Color primaryColor;
  final Color textColor;
  final Color backgroundColor;
  final bool isMonthly;
  final String unit;

  LineChartPainter({
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

    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
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

    // Calculate points for the line chart
    final points = <Offset>[];
    final pointRadius = 5.0;

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final x = leftPadding + (i * chartWidth / (sortedEntries.length - 1));
      final y = topPadding + chartHeight - ((entry.value / adjustedMax) * chartHeight);
      
      points.add(Offset(x, y));
    }

    // Draw the line
    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(path, linePaint);

    // Draw points and value labels
    for (final point in points) {
      // Draw point
      canvas.drawCircle(point, pointRadius, pointPaint);
      canvas.drawCircle(
        point,
        pointRadius,
        Paint()
          ..color = backgroundColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      // Draw value above point
      final index = points.indexOf(point);
      final value = sortedEntries[index].value;
      
      final valuePainter = TextPainter(
        text: TextSpan(
          text: value >= 1000 
              ? '${(value / 1000).toStringAsFixed(1)}k'
              : value.toStringAsFixed(1),
          style: textStyle.copyWith(fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(
          point.dx - valuePainter.width / 2,
          point.dy - valuePainter.height - pointRadius - 4,
        ),
      );
    }

    // Draw X-axis labels
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final x = leftPadding + (i * chartWidth / (sortedEntries.length - 1));

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
          x - labelPainter.width / 2,
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
    return other is LineChartPainter &&
        other.data == data &&
        other.primaryColor == primaryColor &&
        other.textColor == textColor &&
        other.isMonthly == isMonthly &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(data, primaryColor, textColor, isMonthly, unit);
}