import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/domain/bloc/metadata.dart';
import 'package:video_viewer_demo/main.dart';
import 'package:video_viewer_demo/ui/overlay/widgets/progress_bar.dart';
import 'package:video_viewer_demo/ui/overlay/widgets/background.dart';
import 'package:video_viewer_demo/ui/widgets/helpers.dart';

class OverlayBottom extends StatefulWidget {
  const OverlayBottom({super.key,});

  @override
  OverlayBottomState createState() => OverlayBottomState();
}

class OverlayBottomState extends State<OverlayBottom> with RouteAware {
  ValueNotifier<bool> _showRemainingTimeText = ValueNotifier<bool>(true);

  // @override
  // void initState() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     _initialize();
  //   });
  //
  //   super.initState();
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   routeObserver.subscribe(this, ModalRoute.of(context)!);
  // }
  //
  // @override
  // void didPopNext() {
  //   _initialize();
  // }

  @override
  void dispose() {
    _showRemainingTimeText.dispose();
    super.dispose();
  }

  // void _initialize() async {
  //   final bool? value = prefs.getBool('showRemainingTimeText');
  //   // _showRemainingTimeText.value = value ?? false;
  //   _showRemainingTimeText = ValueNotifier<bool>(value ?? false);
  //
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final bool? value = prefs.getBool('showRemainingTimeText');
    _showRemainingTimeText = ValueNotifier<bool>(value ?? true);

    final controller = Provider.of<VideoViewerController>(
      context,
      listen: true,
    );
    final metadata = Provider.of<VideoViewerMetadata>(context, listen: false);

    final bool isFullscreen = controller.isFullScreen;
    final double padding = 12;
    final EdgeInsets halfPadding = EdgeInsets.symmetric(
      horizontal: padding / 2,
    );

    double seekTimePopupHeight;
    double totalBottomHeight;
    double progressBarHeight;
    double controlsHeight;
    double iconSizeIncrementalFactor;

    if (controller.isFullScreen) {
      double incrementalFactor = 2.4;
      iconSizeIncrementalFactor = 1.2;

      seekTimePopupHeight = 35 * incrementalFactor;
      totalBottomHeight = 40 * incrementalFactor;
      progressBarHeight = 11 * incrementalFactor;
      controlsHeight = 24 * incrementalFactor;
    } else {
      iconSizeIncrementalFactor = 1;

      seekTimePopupHeight = 35;
      totalBottomHeight = 40;
      progressBarHeight = 11;
      controlsHeight = 24;
    }

    if (controller.isFullScreen) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: seekTimePopupHeight),
          SizedBox(
            height: totalBottomHeight,
            child: GradientBackground(
              child: Column(
                children: [
                  SizedBox(
                    height: progressBarHeight,
                    child: Row(
                      children: [
                        SizedBox(width: 12),
                        GestureDetector(
                          // cancel these gestures for this widget
                          onLongPress: () {},
                          onLongPressEnd: (_) {},
                          onDoubleTap: () {},

                          child: ValueListenableBuilder(
                            valueListenable: controller.elapsedTime,
                            builder: (_, Duration elapsedTime, __) {
                              return Text(
                                durationFormatter(controller.position),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            // cancel these gestures for this widget
                            onLongPress: () {},
                            onLongPressEnd: (_) {},
                            onDoubleTap: () {},

                            child: ValueListenableBuilder(
                              valueListenable: controller.elapsedTime,
                              builder: (_, Duration elapsedTime, __) {
                                return VideoProgressBar();
                              },
                            ),
                          ),
                        ),
                        GestureDetector(
                          // cancel these gestures for this widget
                          onLongPress: () {},
                          onLongPressEnd: (_) {},
                          onDoubleTap: () {},

                          child: ValueListenableBuilder(
                            valueListenable: _showRemainingTimeText,
                            builder: (_, bool showRemainingTimeText, __) => Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: GestureDetector(
                                onTap: () async {
                                  _showRemainingTimeText.value =
                                      !showRemainingTimeText;
                                  controller.cancelCloseOverlay();

                                  await prefs.setBool(
                                    'showRemainingTimeText',
                                    _showRemainingTimeText.value,
                                  );
                                },
                                child: ValueListenableBuilder(
                                  valueListenable: controller.elapsedTime,
                                  builder: (_, Duration elapsedTime, __) {
                                    return Text(
                                      showRemainingTimeText
                                          ? durationFormatter(
                                              controller.duration,
                                            )
                                          : durationFormatter(
                                              controller.position -
                                                  controller.duration,
                                            ),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: controlsHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: controlsHeight,
                          child: Row(
                            children: [
                              if (controller.position < controller.duration)
                                GestureDetector(
                                  // cancel these gestures for this widget
                                  onLongPress: () {},
                                  onLongPressEnd: (_) {},
                                  onDoubleTap: () {},

                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: IconButton(
                                      onPressed: () =>
                                          controller.areControlsLocked = true,
                                      icon: Icon(
                                        Icons.lock_open,
                                        color: Colors.white,
                                        size: 21 * iconSizeIncrementalFactor,
                                      ),
                                    ),
                                  ),
                                ),
                              Expanded(child: SizedBox()),
                              // SizedBox(width: padding),
                              GestureDetector(
                                // cancel these gestures for this widget
                                onLongPress: () {},
                                onLongPressEnd: (_) {},
                                onDoubleTap: () {},

                                child: IconButton(
                                  onPressed: () {
                                    controller.openSettingsMenu();
                                    controller.showAndHideOverlay(false);
                                  },
                                  icon: Icon(
                                    Icons.settings_outlined,
                                    color: Colors.white,
                                    size: 20 * iconSizeIncrementalFactor,
                                  ),
                                ),
                              ),
                              // SplashCircularIcon(
                              //   padding: halfPadding,
                              //   onTap: () {
                              //     controller.openSettingsMenu();
                              //     controller.showAndHideOverlay(false);
                              //   },
                              //   child: Icon(
                              //     Icons.settings_outlined,
                              //     color: Colors.white,
                              //     size: 20 * iconSizeIncrementalFactor,
                              //   ),
                              // ),
                              if (metadata.enableChat)
                                GestureDetector(
                                  // cancel these gestures for this widget
                                  onLongPress: () {},
                                  onLongPressEnd: (_) {},
                                  onDoubleTap: () {},

                                  child: IconButton(
                                    onPressed: () =>
                                        controller.isShowingChat = true,
                                    icon: Icon(
                                      Icons.chat_outlined,
                                      color: Colors.white,
                                      size: 20 * iconSizeIncrementalFactor,
                                    ),
                                  ),
                                ),
                              GestureDetector(
                                // cancel these gestures for this widget
                                onLongPress: () {},
                                onLongPressEnd: (_) {},
                                onDoubleTap: () {},

                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: IconButton(
                                    onPressed: () async {
                                      await controller.openOrCloseFullscreen();
                                    },
                                    icon: isFullscreen
                                        ? Icon(
                                            Icons.fullscreen_exit_outlined,
                                            color: Colors.white,
                                            size:
                                                24 * iconSizeIncrementalFactor,
                                          )
                                        : Icon(
                                            Icons.fullscreen_outlined,
                                            color: Colors.white,
                                            size:
                                                24 * iconSizeIncrementalFactor,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              // cancel these gestures for this widget
                              onLongPress: () {},
                              onLongPressEnd: (_) {},
                              onDoubleTap: () =>
                                  controller.videoSeekToNextSeconds(-10),

                              child: IconButton(
                                onPressed: () =>
                                    controller.videoSeekToNextSeconds(-10),
                                icon: Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                            SizedBox(width: 30),
                            GestureDetector(
                              // cancel these gestures for this widget
                              onLongPress: () {},
                              onLongPressEnd: (_) {},
                              onDoubleTap: () {},

                              child: SplashCircularIcon(
                                onTap: controller.playOrPause,
                                child: Icon(
                                  !controller.isPlaying
                                      ? Icons.play_arrow
                                      : Icons.pause,
                                  color: Colors.white,
                                  size: 56.4,
                                ),
                              ),
                            ),
                            SizedBox(width: 30),
                            GestureDetector(
                              // cancel these gestures for this widget
                              onLongPress: () {},
                              onLongPressEnd: (_) {},
                              onDoubleTap: () =>
                                  controller.videoSeekToNextSeconds(10),

                              child: IconButton(
                                onPressed: () =>
                                    controller.videoSeekToNextSeconds(10),
                                icon: Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: seekTimePopupHeight),
          SizedBox(
            height: totalBottomHeight,
            child: GradientBackground(
              child: Column(
                children: [
                  GestureDetector(
                    // cancel these gestures for this widget
                    onLongPress: () {},
                    onLongPressEnd: (_) {},
                    onDoubleTap: () {},

                    child: SizedBox(
                      height: progressBarHeight,
                      child: ValueListenableBuilder(
                        valueListenable: controller.elapsedTime,
                        builder: (_, Duration elapsedTime, __) {
                          return VideoProgressBar();
                        },
                      )
                    ),
                  ),
                  SizedBox(
                    height: controlsHeight,
                    child: Row(
                      children: [
                        Padding(
                          padding: halfPadding,
                          child: GestureDetector(
                            onTap: controller.playOrPause,

                            // cancel these gestures for this widget
                            onLongPress: () {},
                            onLongPressEnd: (_) {},
                            onDoubleTap: () {},

                            child: Icon(
                              !controller.isPlaying
                                  ? Icons.play_arrow
                                  : Icons.pause,
                              color: Colors.white,
                              size: 24 * iconSizeIncrementalFactor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          // cancel these gestures for this widget
                          onLongPress: () {},
                          onLongPressEnd: (_) {},
                          onDoubleTap: () {},

                          child: ValueListenableBuilder(
                            valueListenable: _showRemainingTimeText,
                            builder: (_, bool showRemainingTimeText, __) =>
                                GestureDetector(
                                  onTap: () async {
                                    _showRemainingTimeText.value =
                                        !showRemainingTimeText;
                                    controller.cancelCloseOverlay();

                                    await prefs.setBool(
                                      'showRemainingTimeText',
                                      _showRemainingTimeText.value,
                                    );
                                  },
                                  child: ValueListenableBuilder(
                                    valueListenable: controller.elapsedTime,
                                    builder: (_, Duration elapsedTime, __) {
                                      return Text(
                                        '${durationFormatter(controller.position)} / ${showRemainingTimeText ? durationFormatter(controller.duration) : durationFormatter(controller.position - controller.duration)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        SizedBox(width: padding),
                        Padding(
                          padding: halfPadding,
                          child: GestureDetector(
                            onTap: () {
                              controller.openSettingsMenu();
                              controller.showAndHideOverlay(false);
                            },

                            // cancel these gestures for this widget
                            onLongPress: () {},
                            onLongPressEnd: (_) {},
                            onDoubleTap: () {},

                            child: Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                              size: 20 * iconSizeIncrementalFactor,
                            ),
                          ),
                        ),
                        if (metadata.enableChat)
                          Padding(
                            padding: halfPadding,
                            child: GestureDetector(
                              onTap: () => controller.isShowingChat = true,

                              // cancel these gestures for this widget
                              onLongPress: () {},
                              onLongPressEnd: (_) {},
                              onDoubleTap: () {},

                              child: Icon(
                                Icons.chat_outlined,
                                color: Colors.white,
                                size: 20 * iconSizeIncrementalFactor,
                              ),
                            ),
                          ),
                        if (controller.position < controller.duration)
                          Padding(
                            padding: halfPadding,
                            child: GestureDetector(
                              onTap: () => controller.areControlsLocked = true,

                              // cancel these gestures for this widget
                              onLongPress: () {},
                              onLongPressEnd: (_) {},
                              onDoubleTap: () {},

                              child: Icon(
                                Icons.lock_open,
                                color: Colors.white,
                                size: 21 * iconSizeIncrementalFactor,
                              ),
                            ),
                          ),
                        Padding(
                          padding: halfPadding + EdgeInsets.only(right: 1),
                          child: GestureDetector(
                            onTap: () async {
                              await controller.openOrCloseFullscreen();
                            },

                            // cancel these gestures for this widget
                            onLongPress: () {},
                            onLongPressEnd: (_) {},
                            onDoubleTap: () {},

                            child: isFullscreen
                                ? Icon(
                                    Icons.fullscreen_exit_outlined,
                                    color: Colors.white,
                                    size: 24 * iconSizeIncrementalFactor,
                                  )
                                : Icon(
                                    Icons.fullscreen_outlined,
                                    color: Colors.white,
                                    size: 24 * iconSizeIncrementalFactor,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}
