import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/domain/entities/video_source.dart';
import 'package:video_viewer_demo/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:video_viewer_demo/ui/settings_menu/widgets/secondary_menu_item.dart';

class QualityMenu extends StatelessWidget {
  const QualityMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final video = Provider.of<VideoViewerController>(context, listen: true);

    final activeSourceName = video.activeSourceName;

    return SecondaryMenu(
      children: [
        for (VideoContent videoContent in video.videoContentList!)
          SecondaryMenuItem(
            onTap: () async {
              final video = Provider.of<VideoViewerController>(
                context,
                listen: false,
              );
              video.closeAllSecondarySettingsMenus();
              video.closeSettingsMenu();
              if (videoContent.quality != activeSourceName) {
                bool isPlaying = video.isPlaying;

                await video.pause();

                await video.changeSource(
                  videoSource: videoContent.videoSource,
                  name: videoContent.quality,
                  autoPlay: isPlaying,
                );
              }
            },
            text: videoContent.quality,
            selected: videoContent.quality == activeSourceName,
          ),
      ],
    );
  }
}
