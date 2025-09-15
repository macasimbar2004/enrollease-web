import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomTextFormField extends StatefulWidget {
  final bool toShowIcon;
  final bool toShowPassword;
  final TextEditingController controller;
  final TextEditingController? ageController; // Add age controller here
  final FocusNode? focusNode;
  final String? hintText;
  final IconData? iconData;
  final bool? toShowLabelText;
  final bool? isDateTime;
  final IconData? iconDataSuffix;
  final double? leftPadding;
  final bool toShowPrefixIcon;
  final bool isPhoneNumber;
  final String? Function(String?)? validator;
  final int? maxLength;
  final bool? toFillColor;
  final Color? fillColor;
  final bool? maxLine;
  final bool onlyDigits;
  final bool isReadOnly; // Add read-only parameter

  const CustomTextFormField(
      {super.key,
      this.onlyDigits = false,
      required this.toShowIcon,
      required this.toShowPassword,
      required this.controller,
      this.ageController, // Initialize age controller
      this.focusNode,
      this.hintText,
      this.iconData,
      this.toShowLabelText,
      this.isDateTime,
      this.iconDataSuffix,
      this.leftPadding,
      required this.toShowPrefixIcon,
      this.isPhoneNumber = false, // Default to false if not provided
      this.validator,
      this.maxLength,
      this.toFillColor = false,
      this.fillColor,
      this.maxLine,
      this.isReadOnly = false});
  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _toShow;

  @override
  void initState() {
    super.initState();
    _toShow = widget.toShowPassword;
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      // Format the selected date and set it in the controller
      String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
      widget.controller.text = formattedDate;

      // Calculate age
      int currentYear = DateTime.now().year;
      int selectedYear = pickedDate.year;
      int age = currentYear - selectedYear;

      // Set calculated age in ageController if provided
      if (widget.ageController != null) {
        widget.ageController!.text = age.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        color: Colors.black,
        fontSize: 16.0,
      ),
      maxLines: widget.maxLine == true ? null : 1,
      obscureText: _toShow,
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: widget.isDateTime == true || widget.isReadOnly,
      decoration: InputDecoration(
        filled: widget.toFillColor,
        fillColor: widget.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        prefixIcon: widget.toShowPrefixIcon
            ? Icon(widget.iconData, size: 22, color: Colors.grey.shade600)
            : null,
        suffixIcon: widget.isDateTime == true
            ? IconButton(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today,
                    size: 22, color: Colors.blue),
                tooltip: 'Select Date',
              )
            : widget.toShowIcon && widget.iconDataSuffix != null
                ? IconButton(
                    onPressed: null,
                    icon: Icon(widget.iconDataSuffix,
                        size: 22, color: Colors.grey.shade600),
                  )
                : widget.toShowIcon
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _toShow = !_toShow;
                          });
                        },
                        icon: _toShow
                            ? Icon(Icons.visibility,
                                size: 22, color: Colors.grey.shade600)
                            : Icon(Icons.visibility_off,
                                size: 22, color: Colors.grey.shade600),
                      )
                    : null,
        contentPadding: EdgeInsets.symmetric(
            vertical: 16.0, horizontal: widget.leftPadding ?? 16.0),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade600,
          fontSize: 14.0,
        ),
        labelText: widget.toShowLabelText != null ? widget.hintText : null,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
          fontSize: 14.0,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      keyboardType: widget.onlyDigits || widget.isPhoneNumber
          ? const TextInputType.numberWithOptions()
          : null,
      maxLength: widget.isPhoneNumber ? 11 : widget.maxLength,
      inputFormatters: widget.onlyDigits || widget.isPhoneNumber
          ? [FilteringTextInputFormatter.digitsOnly] // Restrict to digits only
          : null,
      validator: widget.validator,
    );
  }
}

TextFormField customTextFormField2(
    TextEditingController controller,
    TextStyle? style,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    InputDecoration? decoration,
    {bool enabled = true,
    String? Function(String?)? validator,
    FocusNode? focusNode, // Add the FocusNode as an optional parameter
    dynamic Function(String)? onChanged,
    TextInputType? keyboardType}) {
  return TextFormField(
    controller: controller,
    style: style,
    maxLength: maxLength,
    maxLengthEnforcement: MaxLengthEnforcement.enforced,
    inputFormatters: inputFormatters,
    decoration: decoration,
    enabled: enabled,
    validator: validator,
    focusNode: focusNode, // Assign the passed FocusNode
    onChanged: onChanged,
    keyboardType: keyboardType,
  );
}

class MyFormFieldWidget extends StatelessWidget {
  final String hintText;

  const MyFormFieldWidget({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: false, // Makes the TextFormField non-interactive
      decoration: InputDecoration(
        hintText: hintText, // Displays generated ID as hint
        hintStyle: TextStyle(
            color: Colors.grey.shade600), // Match the style of other fields
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Match other fields
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        isDense: true, // Make it more compact
      ),
    );
  }
}

TextFormField buildTextField({
  String? initialValue,
  String? labelText,
}) {
  return TextFormField(
    initialValue: initialValue,
    enabled: false,
    style: const TextStyle(
      color: Colors.black,
      fontSize: 14.0,
    ),
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        fontSize: 14.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.white, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      // Improve padding to match other fields
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      // Set a reasonable constraint to avoid overflow
      isDense: true,
    ),
  );
}
