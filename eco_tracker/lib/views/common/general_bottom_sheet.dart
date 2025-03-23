import 'package:flutter/material.dart';

class GeneralBottomSheet extends StatelessWidget {
  const GeneralBottomSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
      ),
      child: child,
    );
  }
}
