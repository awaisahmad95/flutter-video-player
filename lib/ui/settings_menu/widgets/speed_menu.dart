import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:video_viewer_demo/ui/settings_menu/widgets/secondary_menu_item.dart';

class SpeedMenu extends StatelessWidget {
  const SpeedMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final video = Provider.of<VideoViewerController>(context, listen: true);

    final double speed = video.videoPlayerController!.value.playbackSpeed;

    return SecondaryMenu(children: [
      for (double i = 0.5; i <= 2; i += 0.25)
        SecondaryMenuItem(
          onTap: () async {
            final video = Provider.of<VideoViewerController>(context, listen: false);
            await video.videoPlayerController!.setPlaybackSpeed(i);
            video.playbackSpeed = i;
            video.closeAllSecondarySettingsMenus();
          },
          text: i == 1.0 ? 'Normal' : "$i",
          selected: i == speed,
        ),
    ]);
  }
}
