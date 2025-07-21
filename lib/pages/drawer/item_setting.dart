import 'package:flutter/material.dart';
import 'package:music_app/repository/app_manager.dart';

class SettingsButton extends StatefulWidget {
  final AppManager appManager;

  const SettingsButton({super.key, required this.appManager});

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  bool isDarkMode = false;

  AppManager get _appManager => widget.appManager;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isDarkMode = !isDarkMode;
              _appManager.themeModeNotifier.value =
                  !_appManager.themeModeNotifier.value;
            });
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey(isDarkMode),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
              child: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
