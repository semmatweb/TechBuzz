import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.stateText});

  final String stateText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        stateText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).textTheme.displayLarge!.color,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
