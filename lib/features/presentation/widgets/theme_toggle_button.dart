import 'package:askcam/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final Color? color;

  const ThemeToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final colors = Theme.of(context).colorScheme;
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final effectiveIsDark = controller.mode == ThemeMode.dark ||
        (controller.mode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    return IconButton(
      tooltip: effectiveIsDark ? 'Light mode' : 'Dark mode',
      icon: Icon(
        effectiveIsDark ? Icons.light_mode : Icons.dark_mode,
        color: color ?? colors.onSurfaceVariant,
      ),
      onPressed: () {
        controller.setThemeMode(
          effectiveIsDark ? ThemeMode.light : ThemeMode.dark,
        );
      },
    );
  }
}
