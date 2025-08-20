import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/ui/settings_menu/settings_menu.dart';
import 'package:video_viewer_demo/ui/overlay/widgets/background.dart';
import 'package:video_viewer_demo/ui/overlay/widgets/bottom.dart';
import 'package:video_viewer_demo/ui/settings_menu/settings_menu_item.dart';
import 'package:video_viewer_demo/ui/widgets/transitions.dart';

class VideoCoreOverlay extends StatelessWidget {
  const VideoCoreOverlay({super.key, required this.items, required this.title});

  final List<SettingsMenuItem>? items;
  final String title;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: true,
    );
    // final metadata = Provider.of<VideoViewerMetadata>(context, listen: false);

    final bool overlayVisible = controller.isShowingOverlay;

    return CustomOpacityTransition(
      visible: !controller.isShowingThumbnail,
      child: Stack(
        children: controller.areControlsLocked
            ? [
                CustomOpacityTransition(
                  visible: overlayVisible,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        controller.areControlsLocked = false;
                      },
                      icon: Icon(Icons.lock, color: Colors.white),
                    ),
                  ),
                ),
              ]
            : [
                CustomSwipeTransition(
                  axisAlignment: 1.0,
                  visible: overlayVisible,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GradientBackground(
                      end: Alignment.topCenter,
                      begin: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomSwipeTransition(
                    visible: overlayVisible,
                    axisAlignment: -1.0,
                    child: OverlayBottom(),
                  ),
                ),
                // AnimatedBuilder(
                //   animation: controller,
                //   builder: (_, __) => CustomOpacityTransition(
                //     visible: overlayVisible && !controller.isBuffering,
                //     child: const Center(
                //       child: PlayAndPause(type: PlayAndPauseType.center),
                //     ),
                //   ),
                // ),
                CustomOpacityTransition(
                  visible: controller.isShowingSettingsMenu,
                  child: SettingsMenu(items: items,),
                ),
                Visibility(
                  visible: controller.isShowing2xSpeedIcon,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 60,
                      height: 22,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(92),
                        borderRadius: BorderRadius.all(Radius.circular(11)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('2x', style: TextStyle(color: Colors.white)),
                          Icon(
                            Icons.fast_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: controller.isShowingPauseMessage,
                  child: AnimatedOpacity(
                    opacity: controller.pauseMessageOpacity,
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 400),
                    onEnd: () {
                      controller.isShowingPauseMessage = false;
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 100,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(92),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pause, color: Colors.white, size: 20),
                            Text(
                              'Paused',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // CustomOpacityTransition(
                //   visible: controller.isShowingPauseMessage,
                //   duration: Duration(
                //     milliseconds: controller.isShowingPauseMessage ? 400 : 0,
                //   ),
                //   // reverseDuration: const Duration(milliseconds: 400),
                //   child: Align(
                //     alignment: Alignment.center,
                //     child: Container(
                //       width: 100,
                //       height: 30,
                //       alignment: Alignment.center,
                //       decoration: BoxDecoration(
                //         color: Colors.black.withAlpha(92),
                //         borderRadius: BorderRadius.all(Radius.circular(15)),
                //       ),
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Icon(Icons.pause, color: Colors.white, size: 20),
                //           Text('Paused', style: TextStyle(color: Colors.white)),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
      ),
    );
  }
}
