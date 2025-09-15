import 'package:flutter/material.dart';
import '../paginated_table/table/students_table.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_body.dart';
import '../utils/colors.dart';
import '../utils/bottom_credits.dart';
import '../widgets/responsive_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StudentsPage extends StatefulWidget {
  final String userId;
  final String? userName;

  const StudentsPage({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallOrMediumScreen = ResponsiveWidget.isMediumScreen(context) ||
        ResponsiveWidget.isLargeScreen(context);
    
    return Scaffold(
      backgroundColor: CustomColors.appBarColor,
      appBar: CustomAppBar(
        title: 'Students',
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
              color: CustomColors.contentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const FaIcon(
              FontAwesomeIcons.graduationCap,
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
                  'Student Management',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View and manage student records and information',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
                     ),
           _buildSearchField(),
         ],
       ),
     );
   }

   Widget _buildSearchField() {
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
             FontAwesomeIcons.magnifyingGlass,
             color: Colors.white,
             size: 14,
           ),
           const SizedBox(width: 8),
           SizedBox(
             width: 200,
             child: TextField(
               controller: _searchController,
               style: GoogleFonts.poppins(
                 color: Colors.white,
                 fontSize: 14,
               ),
               decoration: InputDecoration(
                 hintText: 'Search students...',
                 hintStyle: GoogleFonts.poppins(
                   color: Colors.white70,
                   fontSize: 14,
                 ),
                 border: InputBorder.none,
                 contentPadding: const EdgeInsets.symmetric(horizontal: 8),
               ),
             ),
           ),
         ],
       ),
     );
   }

  Widget _buildTableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
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
                'Student List',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
                 SizedBox(
           height: 600, // Fixed height to prevent layout issues
           child: StudentsTable(
             userId: widget.userId,
             searchController: _searchController,
           ),
         ),
      ],
    );
  }
}
