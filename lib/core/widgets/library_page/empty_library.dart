import 'package:flutter/material.dart';

class EmptyLibrary extends StatelessWidget {
  const EmptyLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Your library is empty",
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
