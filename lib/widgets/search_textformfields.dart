import 'package:flutter/material.dart';

class SearchTextformfields extends StatefulWidget {
  final Function(String)? onSearch;

  const SearchTextformfields({super.key, this.onSearch});

  @override
  SearchTextformfieldsState createState() => SearchTextformfieldsState();
}

class SearchTextformfieldsState extends State<SearchTextformfields> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.trim();
    if (widget.onSearch != null) {
      widget.onSearch!(query); // Call the onSearch function with the query
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}
