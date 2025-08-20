import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/domain/entities/subtitle.dart';
import 'package:video_viewer_demo/domain/entities/video_source.dart';
import 'package:video_viewer_demo/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:video_viewer_demo/ui/settings_menu/widgets/secondary_menu_item.dart';
import 'package:video_viewer_demo/ui/widgets/helpers.dart';

class CaptionMenu extends StatelessWidget {
  const CaptionMenu({super.key});

  void onTap(
    BuildContext context,
    VideoViewerSubtitle? subtitle,
    String subtitleName,
  ) async {
    final video = Provider.of<VideoViewerController>(context, listen: false);
    video.closeAllSecondarySettingsMenus();
    await video.changeSubtitle(subtitle: subtitle, subtitleName: subtitleName);
  }

  @override
  Widget build(BuildContext context) {
    final video = Provider.of<VideoViewerController>(context, listen: true);

    final activeSourceName = video.activeSourceName;
    final activeCaption = video.activeCaption;
    final none = 'None';

    return SecondaryMenu(
      children: [
        CustomInkWell(
          onTap: () => onTap(context, null, none),
          child: CustomText(
            text: none,
            selected: activeCaption == none || activeCaption == null,
          ),
        ),
        for (VideoContent videoContent in video.videoContentList!)
          if (videoContent.quality == activeSourceName && videoContent.videoSource.subtitle != null)
            for (MapEntry<String, VideoViewerSubtitle> subtitle in videoContent.videoSource.subtitle!.entries)
              SecondaryMenuItem(
                onTap: () {
                  onTap(context, subtitle.value, subtitle.key);
                },
                text: subtitle.key,
                selected: subtitle.key == activeCaption,
              ),
      ],
    );
  }
}
