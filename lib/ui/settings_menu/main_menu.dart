import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/domain/bloc/metadata.dart';
import 'package:video_viewer_demo/ui/settings_menu/settings_menu_item.dart';
import 'package:video_viewer_demo/ui/widgets/helpers.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key, required this.items});

  final List<SettingsMenuItem>? items;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VideoViewerController>(context, listen: true);

    final speed = controller.videoPlayerController!.value.playbackSpeed;
    // final metadata = Provider.of<VideoViewerMetadata>(context, listen: false);
    // final List<SettingsMenuItem>? items = metadata.items;

    final source = controller.videoContentList!;

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          if (source.isNotEmpty)
            _MainMenuItem(
              index: 0,
              icon: Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 20,
              ),
              title: 'Quality',
              subtitle: controller.activeSourceName!,
            ),
          _MainMenuItem(
            index: 1,
            icon: Icon(Icons.speed, color: Colors.white, size: 20),
            title: 'Speed',
            subtitle: speed == 1.0 ? 'Normal' : "x$speed",
          ),
          if (source.where((a) => a.quality == controller.activeSourceName).first.videoSource.subtitle != null)
            _MainMenuItem(
              index: 2,
              icon: Icon(
                Icons.closed_caption_outlined,
                color: Colors.white,
                size: 20,
              ),
              title: 'Caption',
              subtitle:
                  controller.activeCaption ?? 'None',
            ),
          if (items != null)
            for (int i = 0; i < items!.length; i++) ...[
              items![i].themed == null
                  ? SplashCircularIcon(
                      onTap: () => Provider.of<VideoViewerController>(context, listen: false)
                          .openSecondarySettingsMenu(i + kDefaultMenus),
                      padding: EdgeInsets.all(24 / 2),
                      child: items![i].mainMenu,
                    )
                  : _MainMenuItem(
                      index: i + kDefaultMenus,
                      icon: items![i].themed!.icon,
                      title: items![i].themed!.title,
                      subtitle: items![i].themed!.subtitle,
                    ),
            ],
        ],
      ),
    );
  }
}

class _MainMenuItem extends StatelessWidget {
  const _MainMenuItem({
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Widget icon;
  final String title, subtitle;
  final int index;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);

    return SplashCircularIcon(
      padding: EdgeInsets.all(24),
      onTap: () => Provider.of<VideoViewerController>(context, listen: false).openSecondarySettingsMenu(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(title, style: textStyle),
          Text(
            subtitle,
            style: textStyle.merge(TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: textStyle.fontSize! - 2,
            )),
          )
        ],
      ),
    );
  }
}
