import 'package:flutter/material.dart';

import '../mahas_type.dart';

class MahasSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const MahasSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(
          borderRadius: MahasBorderRadius.small,
        ),
      ),
    );
  }
}
