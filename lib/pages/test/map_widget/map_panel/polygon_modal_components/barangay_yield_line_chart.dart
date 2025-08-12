import 'package:flutter/material.dart';
import 'dart:math' as math;

class MonthlyLineChart extends StatelessWidget {
  final String product;
  final int year;
  final Map<String, double> monthlyData;

  const MonthlyLineChart({
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
                Icons.show_chart,
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
                    painter: LineChartPainter(
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

class YearlyLineChart extends StatelessWidget {
  final String product;
  final Map<String, double> yearlyData;

  const YearlyLineChart({
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
                Icons.show_chart,
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
                    painter: LineChartPainter(
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

class LineChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Color primaryColor;
  final Color textColor;
  final Color backgroundColor;
  final bool isMonthly;

  LineChartPainter({
    required this.data,
    required this.primaryColor,
    required this.textColor,
    required this.backgroundColor,
    required this.isMonthly,
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
          text: value.toStringAsFixed(1),
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

      // Draw X-axis label
      final labelPainter = TextPainter(
        text: TextSpan(text: entry.key, style: labelTextStyle),
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
        other.isMonthly == isMonthly;
  }

  @override
  int get hashCode => Object.hash(data, primaryColor, textColor, isMonthly);
}