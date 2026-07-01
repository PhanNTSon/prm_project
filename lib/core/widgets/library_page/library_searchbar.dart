import 'package:flutter/material.dart';

import '../inputs/custom_text_field.dart';

class LibrarySearchBar extends StatelessWidget {
  final TextEditingController controller;

  const LibrarySearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomTextField(
        controller: controller,
        hintText: "Search your games...",
      ),
    );
  }
}
