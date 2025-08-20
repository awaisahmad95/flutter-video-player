import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';

class VideoCorePlayer extends StatefulWidget {
  const VideoCorePlayer({super.key});

  @override
  VideoCorePlayerState createState() => VideoCorePlayerState();
}

class VideoCorePlayerState extends State<VideoCorePlayer> {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: true,
    );

    return Center(
      child: AspectRatio(
        aspectRatio: controller.videoPlayerController!.value.aspectRatio,
        child: !controller.isChangingSource
            ? VideoPlayer(controller.videoPlayerController!)
            : Container(
                color: Colors.black,
                child: Center(
                  child: controller.isPlayerInitializationProcessFinished
                      ? Text(
                          'playback error!',
                          style: TextStyle(color: Colors.white),
                        )
                      : SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
      ),
    );
  }
}
