import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/ui/widgets/helpers.dart';

enum PlayAndPauseType { center, bottom }

class PlayAndPause extends StatelessWidget {
  const PlayAndPause({super.key, required this.type, this.padding});

  final PlayAndPauseType type;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VideoViewerController>(context, listen: true);
    final bool isPlaying = !controller.isPlaying;

    double height = 40;

    return SplashCircularIcon(
      onTap: controller.playOrPause,
      padding: padding,
      child: type == PlayAndPauseType.bottom
          ? isPlaying
                ? Icon(Icons.play_arrow, color: Colors.white)
                : Icon(Icons.pause, color: Colors.white)
          : controller.position >= controller.duration
          ? Container(
              width: height,
              height: height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Icon(Icons.replay, color: Colors.white),
            )
          : isPlaying
          ? Container(
              width: height,
              height: height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Icon(Icons.play_arrow, color: Colors.white),
            )
          : Container(
              width: height,
              height: height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Icon(Icons.pause, color: Colors.white),
            ),
    );
  }
}
