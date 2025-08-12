import 'package:flutter/material.dart';
import 'dart:math' as math;

class MonthlyBarChart extends StatelessWidget {
  final String product;
  final int year;
  final Map<String, double> monthlyData;

  const MonthlyBarChart({
    super.key,
    required this.product,
    required this.year,
    required this.monthlyData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 400,
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
              Text(
                '$product - Monthly Production ($year)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: monthlyData.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  )
                : CustomPaint(
                    painter: BarChartPainter(
                      data: monthlyData,
                      primaryColor: theme.primaryColor,
                      textColor: theme.textTheme.bodyMedium?.color ?? Colors.black,
                      backgroundColor: theme.canvasColor,
                      isMonthly: true,
                    ),
                    child: Container(),
                  ),
          ),
        ],
      ),
    );
  }
}

class YearlyBarChart extends StatelessWidget {
  final String product;
  final Map<String, double> yearlyData;

  const YearlyBarChart({
    super.key,
    required this.product,
    required this.yearlyData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 400,
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
              Text(
                '$product - Yearly Production',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: yearlyData.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  )
                : CustomPaint(
                    painter: BarChartPainter(
                      data: yearlyData,
                      primaryColor: theme.primaryColor,
                      textColor: theme.textTheme.bodyMedium?.color ?? Colors.black,
                      backgroundColor: theme.canvasColor,
                      isMonthly: false,
                    ),
                    child: Container(),
                  ),
          ),
        ],
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

  BarChartPainter({
    required this.data,
    required this.primaryColor,
    required this.textColor,
    required this.backgroundColor,
    required this.isMonthly,
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
    const leftPadding = 60.0;
    const rightPadding = 20.0;
    const topPadding = 20.0;
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
      final monthOrder = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  sortedEntries.sort((a, b) {
    final aIndex = monthOrder.indexOf(a.key.substring(0, 3));
    final bIndex = monthOrder.indexOf(b.key.substring(0, 3));
    return aIndex.compareTo(bIndex);
  });
    } else {
      // Sort years numerically
      sortedEntries.sort((a, b) => a.key.compareTo(b.key));
    }

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
        text: TextSpan(text: value.toStringAsFixed(0), style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // Draw bars and X-axis labels
    final barWidth = chartWidth / sortedEntries.length * 0.8;
    final barSpacing = chartWidth / sortedEntries.length * 0.2;

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final barHeight = (entry.value / adjustedMax) * chartHeight;
      
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
          Rect.fromLTWH(barX, barY, barWidth, barHeight),
        );

      // Draw bar with rounded corners
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(barRect, gradientPaint);

      // Draw value on top of bar
      final valuePainter = TextPainter(
        text: TextSpan(
          text: entry.value.toStringAsFixed(1),
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

      // Draw X-axis label
      final labelPainter = TextPainter(
        text: TextSpan(text: entry.key, style: labelTextStyle),
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
        other.isMonthly == isMonthly;
  }

  @override
  int get hashCode => Object.hash(data, primaryColor, textColor, isMonthly);
}