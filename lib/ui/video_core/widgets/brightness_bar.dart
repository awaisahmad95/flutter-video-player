import 'package:flutter/material.dart';
import 'package:video_viewer_demo/ui/widgets/transitions.dart';

class VideoCoreBrightnessBar extends StatelessWidget {
  const VideoCoreBrightnessBar({
    super.key,
    required this.visible,
    required this.progress,
    required this.height,
  });

  final bool visible;
  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomSwipeTransition(
      visible: visible,
      axisAlignment: -1.0,
      axis: Axis.horizontal,
      duration: const Duration(milliseconds: 0),
      reverseDuration: const Duration(milliseconds: 400),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Container(
            width: 35,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(92),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 3),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3,),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: SizedBox(
                    height: height,
                    width: 3,
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        Container(color: Colors.white.withAlpha(51)),
                        Container(
                          height: progress * height,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 3,),
                Icon(
                  Icons.brightness_medium_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(height: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
