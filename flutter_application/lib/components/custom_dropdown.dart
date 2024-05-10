import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedValue;
  final Function(T?) onChanged;
  final String? labelText;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    this.selectedValue,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: selectedValue,
      onChanged: onChanged,
      style: TextStyle(color: Colors.black),  // Ensures the text in the dropdown field is black
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      dropdownColor: Color.fromARGB(255, 255, 92, 0),  // Orange background for dropdown items
      items: items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString(),
            //style: TextStyle(color: Colors.white),  // White text only for dropdown items
          ),
        );
      }).toList(),
    );
  }
}
