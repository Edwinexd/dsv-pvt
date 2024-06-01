/*
Lace Up & Lead The Way - A pre-race training app and social platform for runners.
Copyright (C) 2024 Group 71 (PVT 7.5) Stockholm University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
*/
import 'package:flutter/material.dart';

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
      style: TextStyle(color: Colors.black),
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
      dropdownColor: Color.fromARGB(255, 255, 92, 0),
      items: items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            //style: TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
    );
  }
}
