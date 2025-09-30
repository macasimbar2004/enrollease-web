import 'package:enrollease_web/paginated_table/table/balance_acc_forms_table.dart';
import 'package:enrollease_web/utils/bottom_credits.dart';

import 'package:enrollease_web/utils/theme_colors.dart';
import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:enrollease_web/widgets/custom_appbar.dart';
import 'package:enrollease_web/widgets/custom_body.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StatementOfAccount extends StatefulWidget {
  final String? userId;
  final String? userName;
  const StatementOfAccount({
    super.key,
    this.userId,
    this.userName,
  });

  @override
  State<StatementOfAccount> createState() => _StatementOfAccountState();
}

class _StatementOfAccountState extends State<StatementOfAccount> {
  late final List<DateTimeRange> dates;
  late DateTimeRange selectedDate;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    dates = List.generate(10, (i) {
      return DateTimeRange(
        start: DateTime(DateTime.now().year - (i + 1)),
        end: DateTime(
          DateTime.now().year - (i),
        ),
      );
    });
    selectedDate = dates.first;
  }

  @override
  Widget build(BuildContext context) {
    final isSmallOrMediumScreen = ResponsiveWidget.isMediumScreen(context) ||
        ResponsiveWidget.isLargeScreen(context);
    return Scaffold(
      backgroundColor: Provider.of<ThemeProvider>(context, listen: false)
              .currentColors['background'] ??
          ThemeColors.background(context),
      appBar: CustomAppBar(
        title: 'Statement of Account',
        userId: widget.userId,
        userName: widget.userName,
      ),
      body: CustomBody(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Animate(
                  effects: [
                    FadeEffect(duration: 600.ms),
                    const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero),
                  ],
                  child: _buildHeaderSection(),
                ),
                const SizedBox(height: 30),
                Animate(
                  effects: [
                    FadeEffect(delay: 200.ms, duration: 600.ms),
                    const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero),
                  ],
                  child: _buildTableSection(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isSmallOrMediumScreen
          ? bottomCredits(context)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (Provider.of<ThemeProvider>(context, listen: false)
                          .currentColors['content'] ??
                      ThemeColors.content(context))
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const FaIcon(
              FontAwesomeIcons.fileInvoiceDollar,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statement of Account',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View and manage student account statements',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildSchoolYearFilter(),
        ],
      ),
    );
  }

  Widget _buildSchoolYearFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.calendar,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            'School Year:',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButton<DateTimeRange>(
              borderRadius: BorderRadius.circular(8),
              value: selectedDate,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              underline: const SizedBox.shrink(),
              items: dates.map((e) {
                return DropdownMenuItem<DateTimeRange>(
                  value: e,
                  child: Text(
                    '${DateFormat('yyyy').format(e.start)} - ${DateFormat('yyyy').format(e.end)}',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedDate = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.table,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Account Statements',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          BalanceAccountsTable(
            range: selectedDate,
            userId: widget.userId!,
          ),
        ],
      ),
    );
  }
}
