import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';

class VideoCoreActiveSubtitleText extends StatelessWidget {
  const VideoCoreActiveSubtitleText({super.key});

  @override
  Widget build(BuildContext context) {
    final subtitle = Provider.of<VideoViewerController>(context, listen: true).activeCaptionData;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          subtitle != null ? subtitle.text : "",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            backgroundColor: Colors.black,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
