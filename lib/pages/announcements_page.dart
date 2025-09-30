import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_body.dart';
import '../widgets/responsive_widget.dart';
import '../utils/bottom_credits.dart';

import '../utils/theme_colors.dart';
import '../paginated_table/table/announcements_table.dart';
import '../widgets/add_announcement_dialog.dart';
import '../states_management/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnnouncementsPage extends StatelessWidget {
  final String? userId;
  final String? userName;

  const AnnouncementsPage({
    super.key,
    this.userId,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallOrMediumScreen = ResponsiveWidget.isMediumScreen(context) ||
        ResponsiveWidget.isLargeScreen(context);

    return Scaffold(
      backgroundColor: Provider.of<ThemeProvider>(context, listen: false)
              .currentColors['background'] ??
          ThemeColors.background(context),
      appBar: CustomAppBar(
        title: 'Announcements',
        userId: userId,
        userName: userName,
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
                  child: _buildHeaderSection(context),
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

  Widget _buildHeaderSection(BuildContext context) {
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
              FontAwesomeIcons.bullhorn,
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
                  'Announcement Management',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create and manage school announcements and events',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Provider.of<ThemeProvider>(context, listen: false)
                    .currentColors['content'] ??
                ThemeColors.content(context),
            (Provider.of<ThemeProvider>(context, listen: false)
                        .currentColors['content'] ??
                    ThemeColors.content(context))
                .withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => const AddAnnouncementDialog(),
            );
            if (result == true) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Announcement added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add New',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                'Announcement List',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const AnnouncementsTable(),
        ],
      ),
    );
  }
}
