import 'package:flutter/material.dart';
import 'package:video_viewer_demo/ui/widgets/helpers.dart';

class SecondaryMenuItem extends StatelessWidget {
  const SecondaryMenuItem({
    super.key,
    required this.onTap,
    required this.text,
    required this.selected,
  });

  final VoidCallback onTap;
  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: CustomText(
          text: text,
          selected: selected,
        ),
      ),
    );
  }
}
