import 'package:enrollease_web/paginated_table/table/registrars_table.dart';
import 'package:enrollease_web/states_management/user_context_provider.dart';
import 'package:enrollease_web/utils/bottom_credits.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/filter_manager.dart';
import 'package:enrollease_web/utils/rbac_service.dart';
import 'package:enrollease_web/widgets/advanced_filter_panel.dart';
import 'package:enrollease_web/widgets/custom_appbar.dart';
import 'package:enrollease_web/widgets/custom_body.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/registrar_dialog.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class FacultyStaff extends StatefulWidget {
  const FacultyStaff({
    super.key,
    this.userId,
    this.userName,
  });
  final String? userId;
  final String? userName;

  @override
  State<FacultyStaff> createState() => _FacultyStaffState();
}

class _FacultyStaffState extends State<FacultyStaff> {
  FirebaseAuthProvider firebaseAuthProvider = FirebaseAuthProvider();

  // Filter state using the new system
  Map<String, dynamic> _currentFilters = {};
  // ignore: unused_field
  FilterCriteria _filterCriteria = const FilterCriteria();

  // Available filter options
  final List<FilterOption> userTypeOptions = [
    const FilterOption(value: 'All', label: 'All Types'),
    const FilterOption(
      value: 'Teacher',
      label: 'Teacher',
      icon: FontAwesomeIcons.chalkboardUser,
    ),
    const FilterOption(
      value: 'Staff',
      label: 'Staff',
      icon: FontAwesomeIcons.users,
    ),
  ];

  final List<FilterOption> roleOptions = [
    const FilterOption(
      value: 'Finance Officer',
      label: 'Finance Officer',
      icon: FontAwesomeIcons.moneyBillWave,
    ),
    const FilterOption(
      value: 'Registrar Officer',
      label: 'Registrar Officer',
      icon: FontAwesomeIcons.userTie,
    ),
    const FilterOption(
      value: 'User Manager',
      label: 'User Manager',
      icon: FontAwesomeIcons.usersGear,
    ),
    const FilterOption(
      value: 'Communications Officer',
      label: 'Communications Officer',
      icon: FontAwesomeIcons.comments,
    ),
    const FilterOption(
      value: 'Attendance Officer',
      label: 'Attendance Officer',
      icon: FontAwesomeIcons.clipboardCheck,
    ),
  ];

  // Filter field configurations
  late final List<FilterField> _filterFields;

  @override
  void initState() {
    super.initState();
    _initializeFilterFields();
  }

  void _initializeFilterFields() {
    _filterFields = [
      FilterField(
        key: 'userType',
        label: 'User Type',
        type: FilterFieldType.dropdown,
        options: userTypeOptions,
      ),
      FilterField(
        key: 'roles',
        label: 'Roles',
        type: FilterFieldType.multiSelect,
        options: roleOptions,
        multiSelect: true,
      ),
    ];
  }

  List<FilterField> _getVisibleFilterFields() {
    final userType = _currentFilters['userType'] as String?;

    return _filterFields.where((field) {
      // Always show userType filter
      if (field.key == 'userType') {
        return true;
      }

      // Only show roles filter when Staff is selected
      if (field.key == 'roles') {
        return userType == 'Staff';
      }

      return true;
    }).toList();
  }

  String? _getUserTypeFilter() {
    final userType = _currentFilters['userType'] as String?;
    return userType == 'All' || userType == null ? null : userType;
  }

  List<String> _getRoleFilters() {
    final rolesRaw = _currentFilters['roles'];
    if (rolesRaw is List) {
      return List<String>.from(rolesRaw);
    }
    return <String>[];
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    if (mounted) {
      setState(() {
        final previousUserType = _currentFilters['userType'] as String?;
        _currentFilters = filters;
        final newUserType = _currentFilters['userType'] as String?;

        // Clear roles filter if user type changed from Staff to something else
        if (previousUserType == 'Staff' && newUserType != 'Staff') {
          _currentFilters['roles'] = [];
        }

        _updateFilterCriteria();
      });
    }
  }

  void _updateFilterCriteria() {
    final userType = _getUserTypeFilter();
    final roles = _getRoleFilters();

    _filterCriteria = FilterManager.createFacultyStaffCriteria(
      userType: userType,
      roles: roles,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallOrMediumScreen = ResponsiveWidget.isMediumScreen(context) ||
        ResponsiveWidget.isLargeScreen(context);
    return Scaffold(
      backgroundColor: CustomColors.appBarColor,
      appBar: CustomAppBar(
        title: 'Faculty & Staff',
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CustomColors.contentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.usersGear,
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
                            'Faculty & Staff Management',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage faculty and staff accounts with role-based access',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
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
          onTap: () async {
            if (!mounted) return;

            showLoadingDialog(context, 'Loading');
            try {
              final idNumber =
                  await firebaseAuthProvider.generateNewIdentification(
                collectionName: 'faculty_staff',
                prefix: 'SDAFS',
                padding: 6,
                includeYear: true,
              );
              if (mounted) {
                Navigator.pop(context); // Close loading dialog
                showDialog(
                  context: context,
                  builder: (context) => RegistrarDialog(
                    id: idNumber,
                    editMode: false,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                Navigator.pop(context); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
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
                  'Add New User',
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
          _buildHeaderWithAdvancedFilters(),
          const SizedBox(height: 20),
          RegistrarsTable(
            userTypeFilter: _getUserTypeFilter(),
            roleFilters: _getRoleFilters(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithAdvancedFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
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
              'Faculty & Staff List',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Advanced Filter Panel
        AdvancedFilterPanel(
          fields: _getVisibleFilterFields(),
          initialValues: _currentFilters,
          onFiltersChanged: _onFiltersChanged,
          title: 'Faculty & Staff Filters',
          isExpanded: true,
        ),
      ],
    );
  }
}
