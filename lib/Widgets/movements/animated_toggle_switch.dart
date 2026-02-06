import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';

class AnimatedToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AnimatedToggleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<AnimatedToggleSwitch> createState() => _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState extends State<AnimatedToggleSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: widget.value
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : Colors.grey[300]!.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: widget.value
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : Colors.grey[300]!.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: widget.value ? AppTheme.primaryColor : Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment:
                    widget.value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
