import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

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
          color: FlavorConfig.instance.variables['appGrey'],
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
