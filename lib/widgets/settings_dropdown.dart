import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import '../theme.dart';

class SettingsDropdown extends StatelessWidget {
  const SettingsDropdown({
    super.key,
    required this.settingName,
    required this.settingIcon,
    required this.dropdownHintText,
    required this.dropdownList,
    required this.onChanged,
  });

  final String settingName;
  final IconData settingIcon;
  final String dropdownHintText;
  final List<DropDownValueModel> dropdownList;
  final void Function(dynamic)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              foregroundColor: Theme.of(context).iconTheme.color!,
              backgroundColor: AppTheme.isDark
                  ? Theme.of(context).canvasColor
                  : FlavorConfig.instance.variables['appLightGrey'],
              child: Icon(settingIcon),
            ),
            const SizedBox(width: 10),
            Text(
              settingName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Flexible(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 4,
            child: DropDownTextField(
                textFieldDecoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).canvasColor,
                  hintText: dropdownHintText,
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: AppTheme.isDark
                        ? BorderSide.none
                        : BorderSide(
                            color:
                                FlavorConfig.instance.variables['appLightGrey'],
                            width: 2,
                          ),
                  ),
                ),
                clearOption: false,
                onChanged: onChanged,
                dropdownColor: Theme.of(context).canvasColor,
                dropDownIconProperty: IconProperty(
                  icon: Icons.keyboard_arrow_down,
                ),
                textStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                listTextStyle: TextStyle(
                  color: AppTheme.isDark
                      ? Colors.white
                      : FlavorConfig.instance.variables['appBlack'],
                  fontWeight: FontWeight.w500,
                ),
                dropDownList: dropdownList),
          ),
        ),
      ],
    );
  }
}
