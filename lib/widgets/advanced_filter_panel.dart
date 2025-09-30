import 'package:enrollease_web/utils/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Configuration for filter options
class FilterOption {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  const FilterOption({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });
}

/// Configuration for a filter field
class FilterField {
  final String key;
  final String label;
  final FilterFieldType type;
  final List<FilterOption> options;
  final String? placeholder;
  final bool multiSelect;
  final bool required;

  const FilterField({
    required this.key,
    required this.label,
    required this.type,
    required this.options,
    this.placeholder,
    this.multiSelect = false,
    this.required = false,
  });
}

/// Types of filter fields
enum FilterFieldType {
  dropdown,
  multiSelect,
  search,
  dateRange,
  checkbox,
}

/// Advanced filter panel widget
class AdvancedFilterPanel extends StatefulWidget {
  final List<FilterField> fields;
  final Map<String, dynamic> initialValues;
  final Function(Map<String, dynamic>) onFiltersChanged;
  final VoidCallback? onClearAll;
  final bool showClearButton;
  final bool showApplyButton;
  final String? title;
  final bool isExpanded;

  const AdvancedFilterPanel({
    super.key,
    required this.fields,
    this.initialValues = const {},
    required this.onFiltersChanged,
    this.onClearAll,
    this.showClearButton = true,
    this.showApplyButton = false,
    this.title,
    this.isExpanded = false,
  });

  @override
  State<AdvancedFilterPanel> createState() => _AdvancedFilterPanelState();
}

class _AdvancedFilterPanelState extends State<AdvancedFilterPanel> {
  late Map<String, dynamic> _currentFilters;
  bool _isExpanded = false;
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    _currentFilters = Map.from(widget.initialValues);
    _isExpanded = widget.isExpanded;
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final field in widget.fields) {
      if (field.type == FilterFieldType.search) {
        _textControllers[field.key] = TextEditingController(
          text: _currentFilters[field.key] as String? ?? '',
        );
      }
    }
  }

  @override
  void didUpdateWidget(AdvancedFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValues != widget.initialValues) {
      _currentFilters = Map.from(widget.initialValues);
      _updateControllers();
    }
  }

  void _updateControllers() {
    for (final field in widget.fields) {
      if (field.type == FilterFieldType.search) {
        final controller = _textControllers[field.key];
        if (controller != null) {
          final newValue = _currentFilters[field.key] as String? ?? '';
          if (controller.text != newValue) {
            controller.text = newValue;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateFilter(String key, dynamic value) {
    setState(() {
      _currentFilters[key] = value;
    });

    if (!widget.showApplyButton) {
      widget.onFiltersChanged(_currentFilters);
    }
  }

  void _clearFilters() {
    setState(() {
      _currentFilters.clear();
      _updateControllers();
    });
    widget.onFiltersChanged(_currentFilters);
    widget.onClearAll?.call();
  }

  void _applyFilters() {
    widget.onFiltersChanged(_currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          // Filter content
          if (_isExpanded) _buildFilterContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.contentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const FaIcon(
              FontAwesomeIcons.filter,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? 'Filters',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_getActiveFilterCount() > 0)
                  Text(
                    '${_getActiveFilterCount()} active',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              if (_getActiveFilterCount() > 0 && widget.showClearButton)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: _clearFilters,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.xmark,
                              color: Colors.red,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Clear',
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filter fields
          ...widget.fields.map((field) => _buildFilterField(field)),

          // Action buttons
          if (widget.showApplyButton) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildFilterField(FilterField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildFieldWidget(field),
        ],
      ),
    );
  }

  Widget _buildFieldWidget(FilterField field) {
    switch (field.type) {
      case FilterFieldType.dropdown:
        return _buildDropdownField(field);
      case FilterFieldType.multiSelect:
        return _buildMultiSelectField(field);
      case FilterFieldType.search:
        return _buildSearchField(field);
      case FilterFieldType.checkbox:
        return _buildCheckboxField(field);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDropdownField(FilterField field) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _currentFilters[field.key] as String?,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
        ),
        dropdownColor: ThemeColors.appBarPrimary(context),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.white,
          size: 20,
        ),
        items: field.options.map((option) {
          return DropdownMenuItem(
            value: option.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  FaIcon(
                    option.icon,
                    color: option.color ?? Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    option.label,
                    style: GoogleFonts.poppins(
                      color: option.color ?? Colors.white,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          _updateFilter(field.key, value);
        },
      ),
    );
  }

  Widget _buildMultiSelectField(FilterField field) {
    final rolesRaw = _currentFilters[field.key];
    final selectedValues =
        rolesRaw is List ? List<String>.from(rolesRaw) : <String>[];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Selected values display
          if (selectedValues.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: selectedValues.map((value) {
                  final option = field.options.firstWhere(
                    (opt) => opt.value == value,
                    orElse: () => FilterOption(value: value, label: value),
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.contentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            option.label,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            final newValues = List<String>.from(selectedValues)
                              ..remove(value);
                            _updateFilter(field.key, newValues);
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Options list
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: field.options.length,
              itemBuilder: (context, index) {
                final option = field.options[index];
                final isSelected = selectedValues.contains(option.value);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final newValues = List<String>.from(selectedValues);
                      if (isSelected) {
                        newValues.remove(option.value);
                      } else {
                        newValues.add(option.value);
                      }
                      _updateFilter(field.key, newValues);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              final newValues =
                                  List<String>.from(selectedValues);
                              if (value == true) {
                                newValues.add(option.value);
                              } else {
                                newValues.remove(option.value);
                              }
                              _updateFilter(field.key, newValues);
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          if (option.icon != null) ...[
                            FaIcon(
                              option.icon,
                              color: option.color ?? Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              option.label,
                              style: GoogleFonts.poppins(
                                color: option.color ?? Colors.white,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(FilterField field) {
    final controller = _textControllers[field.key];
    if (controller == null) return const SizedBox.shrink();

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: field.placeholder ?? 'Search...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.white60,
            size: 20,
          ),
        ),
        onChanged: (value) {
          _updateFilter(field.key, value);
        },
      ),
    );
  }

  Widget _buildCheckboxField(FilterField field) {
    final isChecked = _currentFilters[field.key] as bool? ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            _updateFilter(field.key, !isChecked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    _updateFilter(field.key, value);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                Flexible(
                  child: Text(
                    field.label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _clearFilters,
                child: Center(
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.contentColor,
                  ThemeColors.contentColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _applyFilters,
                child: Center(
                  child: Text(
                    'Apply Filters',
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
        ),
      ],
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    for (final value in _currentFilters.values) {
      if (value != null && value != '' && value != 'All') {
        if (value is List) {
          if (value.isNotEmpty) count++;
        } else {
          count++;
        }
      }
    }
    return count;
  }
}
