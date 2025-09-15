import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/widgets/custom_appbar.dart';
import 'package:enrollease_web/widgets/custom_body.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseAuthProvider _firebaseAuth = FirebaseAuthProvider();
  DateTime? _schoolYearEndDate;

  @override
  void initState() {
    super.initState();
    _loadAdminSettings();
  }

  Future<void> _loadAdminSettings() async {
    try {
      final endDate = await _firebaseAuth.getSchoolYearEndDate();
      debugPrint('Loaded school year end date: $endDate');
      setState(() {
        _schoolYearEndDate = endDate;
      });
    } catch (e) {
      debugPrint('Error loading admin settings: $e');
    }
  }

  Future<void> _selectSchoolYearEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _schoolYearEndDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (picked != null && picked != _schoolYearEndDate) {
      setState(() => _schoolYearEndDate = picked);
    }
  }

  Future<void> _saveSchoolYearEndDate() async {
    if (_schoolYearEndDate == null) {
      DelightfulToast.showError(
          context, 'Error', 'Please select a school year end date');
      return;
    }

    showLoadingDialog(context, 'Saving school year end date...');

    try {
      debugPrint('Saving school year end date: $_schoolYearEndDate');
      final success =
          await _firebaseAuth.setSchoolYearEndDate(_schoolYearEndDate!);
      debugPrint('Save result: $success');

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          DelightfulToast.showSuccess(
              context, 'Success', 'School year end date saved successfully');
        } else {
          DelightfulToast.showError(
              context, 'Error', 'Failed to save school year end date');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        DelightfulToast.showError(
            context, 'Error', 'Failed to save school year end date: $e');
      }
    }
  }

  Future<void> _performAutoPromotion() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Auto-Promotion'),
        content: const Text(
            'This will automatically promote all eligible students to the next grade level. '
            'Students must have passing grades (75% or higher) and zero balance to be promoted. '
            'This action cannot be undone. Do you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.contentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    showLoadingDialog(context, 'Performing auto-promotion...');

    try {
      final success = await _firebaseAuth.performAutoPromotion();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          DelightfulToast.showSuccess(
              context, 'Success', 'Auto-promotion completed successfully');
        } else {
          DelightfulToast.showError(
              context, 'Error', 'Failed to perform auto-promotion');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        DelightfulToast.showError(
            context, 'Error', 'Failed to perform auto-promotion: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.appBarColor,
      appBar: const CustomAppBar(title: 'Admin Panel'),
      body: CustomBody(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // School Year Management Section
                Animate(
                    effects: [
                      FadeEffect(duration: 600.ms),
                      const SlideEffect(
                          begin: Offset(0, 0.2), end: Offset.zero),
                    ],
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSchoolYearSection(),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: _buildSystemInfoSection(),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 30),
                Animate(
                  effects: [
                    FadeEffect(delay: 200.ms, duration: 600.ms),
                    const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero),
                  ],
                  child: _buildAutoPromotionSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolYearSection() {
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
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'School Year Management',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // School Year End Date
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'School Year End Date',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _schoolYearEndDate != null
                                      ? DateFormat('MMMM dd, yyyy')
                                          .format(_schoolYearEndDate!)
                                      : 'No date selected',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: _schoolYearEndDate != null
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        CustomColors.contentColor,
                                        CustomColors.contentColor
                                            .withValues(alpha: 0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: _selectSchoolYearEndDate,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        child: Text(
                                          'Select Date',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Save Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomColors.contentColor,
                  CustomColors.contentColor.withValues(alpha: 0.8),
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
                onTap: _saveSchoolYearEndDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Save School Year End Date',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoPromotionSection() {
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
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Student Auto-Promotion',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Auto-promotion info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Promotion Criteria',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Students will be automatically promoted to the next grade level if they meet the following criteria:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• All academic grades are 75% or higher\n'
                  '• Statement of account balance is zero (fully paid)\n'
                  '• Student is not already at the highest grade level',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Auto-promotion button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomColors.contentColor,
                  CustomColors.contentColor.withValues(alpha: 0.8),
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
                onTap: _performAutoPromotion,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Perform Auto-Promotion',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoSection() {
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
                child: const Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'System Information',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Current school year info
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current School Year',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _schoolYearEndDate != null
                        ? 'Ends on: ${DateFormat('MMMM dd, yyyy').format(_schoolYearEndDate!)}'
                        : 'No end date set',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _schoolYearEndDate != null
                        ? 'Days remaining: ${_schoolYearEndDate!.difference(DateTime.now()).inDays}'
                        : 'Please set an end date',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _schoolYearEndDate != null
                          ? (_schoolYearEndDate!
                                      .difference(DateTime.now())
                                      .inDays <
                                  30
                              ? Colors.red.shade400
                              : Colors.white.withValues(alpha: 0.9))
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
