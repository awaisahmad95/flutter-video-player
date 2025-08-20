import 'package:flutter/material.dart';

class SplashCircularIcon extends StatelessWidget {
  const SplashCircularIcon({
    super.key,
    required this.child,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  });

  final Widget? child;
  final void Function() onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    required this.selected,
  });

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold).merge(
              TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        if (selected) Icon(Icons.done, color: Colors.white, size: 20),
      ]),
    );
  }
}

class CustomInkWell extends StatelessWidget {
  const CustomInkWell({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.white.withAlpha(51),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

String durationFormatter(Duration duration) {
  final int hours = duration.inHours;
  final String formatter =
  [if (hours != 0) hours, duration.inMinutes, duration.inSeconds]
      .map((seg) => seg.abs().remainder(60).toString().padLeft(2, '0'))
      .join(':');
  return duration.inSeconds < 0 ? "-$formatter" : formatter;
}
