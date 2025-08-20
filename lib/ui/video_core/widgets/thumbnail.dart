import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/main.dart';
import 'package:video_viewer_demo/ui/widgets/play_and_pause.dart';
import 'package:video_viewer_demo/ui/widgets/transitions.dart';

class VideoCoreThumbnail extends StatelessWidget {
  const VideoCoreThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: true,
    );

    Widget? thumbnail;

    if (media.thumbnail.isNotEmpty) {
      thumbnail = Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: Colors.black, child: SizedBox.expand(),)),
          Positioned.fill(
            child: Image.network(
              media.thumbnail,
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    }

    return CustomOpacityTransition(
      visible: controller.isShowingThumbnail,
      child: Stack(
        children: [
          Positioned.fill(
            child: (thumbnail != null)
                ? thumbnail
                : Container(color: Colors.black),
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                await controller.play();
                controller.showAndHideOverlay();
              },
              child: PlayAndPause(type: PlayAndPauseType.center),
            ),
          ),
          // Positioned.fill(
          //   child: GestureDetector(
          //     onTap: () async {
          //       await controller.play();
          //       controller.showAndHideOverlay();
          //     },
          //     child: Container(
          //       color: Colors.transparent,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
