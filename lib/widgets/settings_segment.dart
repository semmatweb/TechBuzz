import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

class SettingsSegment extends StatelessWidget {
  const SettingsSegment({super.key, required this.segmentName});

  final String segmentName;

  @override
  Widget build(BuildContext context) {
    return Text(
      segmentName.toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 1,
        color: FlavorConfig.instance.variables['appDarkGrey'],
      ),
    );
  }
}
