import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/domain/bloc/metadata.dart';
import 'package:video_viewer_demo/ui/settings_menu/settings_menu_item.dart';
import 'package:video_viewer_demo/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:video_viewer_demo/ui/settings_menu/widgets/caption_menu.dart';
import 'package:video_viewer_demo/ui/settings_menu/widgets/quality_menu.dart';
import 'package:video_viewer_demo/ui/settings_menu/widgets/speed_menu.dart';
import 'package:video_viewer_demo/ui/settings_menu/main_menu.dart';
import 'package:video_viewer_demo/ui/widgets/transitions.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key, required this.items});

  final List<SettingsMenuItem>? items;

  @override
  Widget build(BuildContext context) {
    final video = Provider.of<VideoViewerController>(context, listen: true);
    // final meta = Provider.of<VideoViewerMetadata>(context, listen: false);
    // final List<SettingsMenuItem>? items = meta.items;

    final bool main = video.isShowingMainSettingsMenu;
    final List<bool> secondary = video.isShowingSecondarySettingsMenus;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            final controller = Provider.of<VideoViewerController>(
              context,
              listen: false,
            );
            controller.closeSettingsMenu();
            controller.showAndHideOverlay(true);
          },
          child: Container(color: Colors.black.withAlpha(82)),
        ),
        CustomOpacityTransition(
          visible: !main,
          child: GestureDetector(
            onTap: video.closeAllSecondarySettingsMenus,
            child: Container(color: Colors.transparent),
          ),
        ),
        CustomOpacityTransition(visible: main, child: MainMenu(items: items,)), //MAIN MENU
        CustomOpacityTransition(visible: secondary[0], child: QualityMenu()),
        CustomOpacityTransition(visible: secondary[1], child: SpeedMenu()),
        CustomOpacityTransition(visible: secondary[2], child: CaptionMenu()),
        if (items != null)
          for (int i = 0; i < items!.length; i++)
            CustomOpacityTransition(
              visible: secondary[i + kDefaultMenus],
              child: SecondaryMenu(
                width: items![i].secondaryMenuWidth,
                children: [items![i].secondaryMenu],
              ),
            ),
      ],
    );
  }
}
