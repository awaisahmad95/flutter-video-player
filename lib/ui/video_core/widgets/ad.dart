import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/ui/widgets/transitions.dart';

class VideoCoreAdViewer extends StatelessWidget {
  const VideoCoreAdViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final video = Provider.of<VideoViewerController>(context, listen: true);

    return CustomOpacityTransition(
      visible: video.activeAd != null,
      child: Stack(
        children: [
          video.activeAd?.child ?? SizedBox(),
          if (video.activeAd != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Material(
                type: MaterialType.transparency,
                child: Ink(
                  decoration: BoxDecoration(shape: BoxShape.rectangle),
                  child: InkWell(
                    onTap: (video.adTimeWatched ?? Duration.zero) >=
                        video.activeAd!.durationToSkip
                        ? video.skipAd
                        : null,
                    child: Builder(builder: (_) {
                      final int remaining = (video.activeAd!.durationToSkip -
                          (video.adTimeWatched ?? Duration.zero))
                          .inSeconds;
                      // builder signature: final Widget Function(Duration)? skipAdBuilder;
                      // return style.skipAdBuilder?.call(video.adTimeWatched!) ??
                      return Container(
                            padding: const EdgeInsets.all(20),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(
                                remaining > 0
                                    ? "$remaining seconds remaining"
                                    : "Skip ad",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              if (remaining <= 0)
                                Icon(Icons.skip_next, color: Colors.white)
                            ]),
                          );
                    },
                  ),
                ),
              ),
              ),
            ),
        ],
      ),
    );
  }
}
