import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/ui/widgets/transitions.dart';

class VideoCoreBuffering extends StatelessWidget {
  const VideoCoreBuffering({super.key});

  @override
  Widget build(BuildContext context) {
    final video = Provider.of<VideoViewerController>(context, listen: true);

    return CustomOpacityTransition(
      visible: video.isBuffering,
      child: Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}
