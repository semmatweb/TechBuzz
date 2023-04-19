import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

class FailedState extends StatelessWidget {
  const FailedState({
    super.key,
    required this.stateIcon,
    required this.stateText,
    required this.onPressed,
  });

  final IconData stateIcon;
  final String stateText;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            stateIcon,
            color: Colors.red,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            stateText,
            style: TextStyle(
              color: FlavorConfig.instance.variables['appBlack'],
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton.icon(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  FlavorConfig.instance.variables['appPrimaryAccentColor'],
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).primaryColor,
            ),
            label: Text(
              'Retry',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
