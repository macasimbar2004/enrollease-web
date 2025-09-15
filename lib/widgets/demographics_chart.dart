import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DemographicsChart extends StatelessWidget {
  const DemographicsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart,
                color: Colors.white70,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                'Student Demographics',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _Legend(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('students').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final docs = snapshot.data!.docs;
                final Map<int, Map<String, int>> byYearGender = {};

                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final Timestamp? ts = data['timestamp'] as Timestamp?;
                  final int year = (ts?.toDate().year) ?? DateTime.now().year;
                  final String gender =
                      (data['gender'] ?? '').toString().toLowerCase();
                  String? normalizedGender;
                  if (gender.startsWith('m')) {
                    normalizedGender = 'Male';
                  } else if (gender.startsWith('f')) {
                    normalizedGender = 'Female';
                  }
                  if (normalizedGender == null) continue; // Skip non M/F

                  byYearGender.putIfAbsent(
                      year, () => {'Male': 0, 'Female': 0});
                  byYearGender[year]![normalizedGender] =
                      (byYearGender[year]![normalizedGender] ?? 0) + 1;
                }

                final years = byYearGender.keys.toList()..sort();
                if (years.isEmpty) {
                  return const Center(
                    child: Text(
                      'No student data available',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return _GroupedBarChart(
                  years: years,
                  data: byYearGender,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendItem(color: Colors.blue, label: 'Male'),
        SizedBox(width: 12),
        _LegendItem(color: Colors.pink, label: 'Female'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _GroupedBarChart extends StatelessWidget {
  final List<int> years;
  final Map<int, Map<String, int>> data;
  const _GroupedBarChart({required this.years, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double chartHeight = constraints.maxHeight;

        final double groupSpacing = 24;
        final double barWidth = 14;
        final double barSpacingInGroup = 10;
        final double leftPadding = 32;
        final double bottomPadding = 28;

        final maxValue = data.values.map((g) {
          final male = g['Male'] ?? 0;
          final female = g['Female'] ?? 0;
          return male > female ? male : female;
        }).fold<int>(0, (prev, e) => e > prev ? e : prev);
        final yMax = (maxValue == 0) ? 1 : maxValue;

        return CustomPaint(
          size: Size(constraints.maxWidth, chartHeight),
          painter: _BarChartPainter(
            years: years,
            data: data,
            groupSpacing: groupSpacing,
            barWidth: barWidth,
            barSpacingInGroup: barSpacingInGroup,
            leftPadding: leftPadding,
            bottomPadding: bottomPadding,
            yMax: yMax,
          ),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<int> years;
  final Map<int, Map<String, int>> data;
  final double groupSpacing;
  final double barWidth;
  final double barSpacingInGroup;
  final double leftPadding;
  final double bottomPadding;
  final int yMax;

  _BarChartPainter({
    required this.years,
    required this.data,
    required this.groupSpacing,
    required this.barWidth,
    required this.barSpacingInGroup,
    required this.leftPadding,
    required this.bottomPadding,
    required this.yMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double chartHeight = size.height - bottomPadding;

    final Paint axisPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1.0;

    // Axes
    canvas.drawLine(
        Offset(leftPadding, 0), Offset(leftPadding, chartHeight), axisPaint);
    canvas.drawLine(Offset(leftPadding, chartHeight),
        Offset(size.width, chartHeight), axisPaint);

    // Y grid lines and labels
    final int ySteps = 4;
    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 1; i <= ySteps; i++) {
      final double y = chartHeight - (chartHeight / ySteps) * i;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y),
          axisPaint..color = Colors.white30);
      final int value = (yMax / ySteps * i).round();
      tp.text = TextSpan(
          text: value.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 10));
      tp.layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - tp.height / 2));
    }

    // Bars
    final Paint malePaint = Paint()..color = Colors.blue;
    final Paint femalePaint = Paint()..color = Colors.pink;

    double x = leftPadding + groupSpacing;
    final double groupTotalWidth = barWidth * 2 + barSpacingInGroup * 1;

    for (final year in years) {
      final male = (data[year]?['Male'] ?? 0).toDouble();
      final female = (data[year]?['Female'] ?? 0).toDouble();
      final double scale = chartHeight / yMax;

      // Male bar
      final double maleLeft = x;
      final double maleTop = chartHeight - male * scale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(maleLeft, maleTop, barWidth, male * scale),
            const Radius.circular(6)),
        malePaint,
      );

      // Female bar
      final double femaleLeft = x + barWidth + barSpacingInGroup;
      final double femaleTop = chartHeight - female * scale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(femaleLeft, femaleTop, barWidth, female * scale),
            const Radius.circular(6)),
        femalePaint,
      );

      // Year label
      final TextPainter yearPainter = TextPainter(
        text: const TextSpan(text: ''),
        textDirection: TextDirection.ltr,
      );
      yearPainter.text = TextSpan(
          text: year.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12));
      yearPainter.layout();
      yearPainter.paint(
          canvas,
          Offset(x + groupTotalWidth / 2 - yearPainter.width / 2,
              chartHeight + 4));

      x += groupTotalWidth + groupSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
