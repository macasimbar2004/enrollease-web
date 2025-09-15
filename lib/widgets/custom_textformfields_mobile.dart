import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomTextFormFieldMobile extends StatefulWidget {
  final bool toShowIcon;
  final bool toShow;
  final TextEditingController controller;
  final TextEditingController? ageController; // Add age controller here
  final FocusNode? focusNode;
  final String hintText;
  final Widget? iconData;
  final bool? toShowLabelText;
  final bool? isDateTime;
  final IconData? iconDataSuffix;
  final double? leftPadding;
  final bool toShowPrefixIcon;
  final bool? isPhoneNumber;
  final String? Function(String?)? validator; // Ensure correct type here
  final int? maxLength;
  final bool digitsOnly;

  const CustomTextFormFieldMobile(
      {super.key,
      this.digitsOnly = false,
      required this.toShowIcon,
      required this.toShow,
      required this.controller,
      this.ageController, // Initialize age controller
      this.focusNode,
      required this.hintText,
      this.iconData,
      this.toShowLabelText,
      this.isDateTime,
      this.iconDataSuffix,
      this.leftPadding,
      required this.toShowPrefixIcon,
      this.isPhoneNumber = false, // Default to false if not provided
      this.validator,
      this.maxLength});

  @override
  State<CustomTextFormFieldMobile> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormFieldMobile> {
  late bool _toShow;

  @override
  void initState() {
    super.initState();
    _toShow = widget.toShow;
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
        fontWeight: FontWeight.w900,
        color: Colors.black,
        fontSize: 12.0,
      ),
      obscureText: _toShow,
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: widget.isDateTime == true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
        prefixIcon: widget.toShowPrefixIcon ? widget.iconData : null,
        suffixIcon: widget.toShowIcon && widget.iconDataSuffix != null
            ? IconButton(
                onPressed: widget.isDateTime == true ? _selectDate : null,
                icon: Icon(widget.iconDataSuffix),
              )
            : widget.toShowIcon
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _toShow = !_toShow;
                      });
                    },
                    icon: _toShow ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
                  )
                : null,
        contentPadding: EdgeInsets.only(top: 16.0, bottom: 16, left: widget.leftPadding ?? 10),
        hintText: widget.toShowLabelText != null && widget.toShowLabelText! ? null : widget.hintText,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontSize: 12.0,
        ),
        labelText: widget.toShowLabelText != null && widget.toShowLabelText! ? widget.hintText : null,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontSize: 12.0,
        ),
      ),
      keyboardType: widget.isPhoneNumber == true ? const TextInputType.numberWithOptions() : null,
      maxLength: widget.isPhoneNumber == true && widget.maxLength != null ? widget.maxLength : widget.maxLength,
      inputFormatters: widget.digitsOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : widget.isPhoneNumber == true
              ? [FilteringTextInputFormatter.allow(RegExp(r'^[\d+]*$'))] // Restrict to digits only
              : null,
      validator: widget.validator != null
          ? (value) {
              return widget.validator!(value);
            }
          : null,
    );
  }
}
