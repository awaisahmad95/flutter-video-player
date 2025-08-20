import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_viewer_demo/domain/bloc/metadata.dart';
import 'package:video_viewer_demo/main.dart';
import 'package:video_viewer_demo/ui/overlay/widgets/background.dart';
import 'package:video_viewer_demo/ui/video_core/widgets/ad.dart';
import 'package:video_viewer_demo/ui/video_core/widgets/brightness_bar.dart';
import 'package:video_viewer_demo/ui/video_core/widgets/forward_and_rewind/forward_and_rewind.dart';
import 'package:video_viewer_demo/ui/video_core/widgets/forward_and_rewind/layout.dart';
import 'package:video_viewer_demo/ui/video_core/widgets/forward_and_rewind/bar.dart';
import 'package:video_viewer_demo/ui/video_core/widgets/volume_bar.dart';
import 'package:video_viewer_demo/ui/video_core/widgets/thumbnail.dart';
import 'package:video_viewer_demo/ui/video_core/widgets/buffering.dart';
import 'package:video_viewer_demo/ui/video_core/widgets/subtitle.dart';
import 'package:video_viewer_demo/ui/video_core/widgets/player.dart';
import 'package:video_viewer_demo/ui/widgets/play_and_pause.dart';
import 'package:video_viewer_demo/ui/widgets/transitions.dart';
import 'package:video_viewer_demo/ui/overlay/overlay.dart';
import 'package:video_viewer_demo/video_viewer.dart';
import 'package:volume_controller/volume_controller.dart';

class VideoViewerCore extends StatefulWidget {
  const VideoViewerCore({super.key});

  @override
  VideoViewerCoreState createState() => VideoViewerCoreState();
}

class VideoViewerCoreState extends State<VideoViewerCore> with RouteAware {
  //------------------------------//
  //REWIND AND FORWARD (VARIABLES)//
  //------------------------------//
  final ValueNotifier<int> _forwardAndRewindSecondsAmount = ValueNotifier<int>(
    1,
  );
  Duration _initialForwardPosition = Duration.zero;
  Offset _dragInitialDelta = Offset.zero;
  Axis _dragDirection = Axis.vertical;
  int _rewindDoubleTapCount = 0;
  int _forwardDoubleTapCount = 0;
  int _defaultRewindAmount = -10;
  int _defaultForwardAmount = 10;
  Timer? _rewindDoubleTapTimer;
  Timer? _forwardDoubleTapTimer;
  bool _showForwardStatus = false;
  Offset _horizontalDragStartOffset = Offset.zero;
  final List<bool> _showAMomentRewindIcons = [false, false];

  //------------------//
  //VOLUME (VARIABLES)//
  //------------------//
  final ValueNotifier<double> _currentVolume = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _currentBrightness = ValueNotifier<double>(0.0);

  StreamSubscription<double>? brightnessStream;
  StreamSubscription<double>? volumeStream;

  bool _showVolumeStatus = false;
  bool _showBrightnessStatus = false;

  Timer? _closeVolumeStatus;
  Timer? _closeBrightnessStatus;

  bool _isVerticalDragStartedOnTheRightHalfOfTheScreen = true;

  bool _isVolumeDragStarted = false;

  //-----------------//
  //SCALE (VARIABLES)//
  //-----------------//
  final ValueNotifier<double> _scale = ValueNotifier<double>(1.0);
  final double _minScale = 1.0;
  double _initialScale = 1.0, _maxScale = 1.0;
  double _oldVolumeValue = 0.0;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _initialize();
  }

  @override
  void dispose() {
    _scale.dispose();
    _currentVolume.dispose();
    _currentBrightness.dispose();
    _closeVolumeStatus?.cancel();
    _closeBrightnessStatus?.cancel();
    _rewindDoubleTapTimer?.cancel();
    _forwardDoubleTapTimer?.cancel();
    _forwardAndRewindSecondsAmount.dispose();
    VolumeController.instance.removeListener();
    _resetApplicationBrightness();
    brightnessStream?.cancel();
    volumeStream?.cancel();
    routeObserver.unsubscribe(this);

    super.dispose();
  }

  void _initialize() {
    Future.delayed(const Duration(seconds: 1), () {
      // hide the volume system UI
      VolumeController.instance.showSystemUI = false;

      volumeStream?.cancel();
      brightnessStream?.cancel();

      volumeStream = VolumeController.instance.addListener((double volume) {
        if (!_isVolumeDragStarted) {
          _setVolume(volume: volume, setSystemVolume: false);
        }
      }, fetchInitialVolume: true);

      brightnessStream = ScreenBrightness
          .instance
          .onSystemScreenBrightnessChanged
          .listen((double value) async {
            _currentBrightness.value = value;
            _setApplicationBrightness(_currentBrightness.value);
          });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final metadata = Provider.of<VideoViewerMetadata>(
          context,
          listen: false,
        );
        _defaultRewindAmount = metadata.rewindAmount;
        _defaultForwardAmount = metadata.forwardAmount;

        await _resetApplicationBrightness();
        _currentBrightness.value = await _getSystemBrightness();
        // await _setApplicationBrightness(_currentBrightness.value);

        setState(() {});
      });
    });
  }

  Future<double> _getSystemBrightness() async {
    try {
      return await ScreenBrightness.instance.system;
    } catch (e) {
      debugPrint(e.toString());
      return 0.0;
    }
  }

  void _setApplicationBrightness(double brightness) {
    try {
      ScreenBrightness.instance.setApplicationScreenBrightness(brightness);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _resetApplicationBrightness() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //-------------//
  //OVERLAY (TAP)//
  //-------------//

  bool _canListenerMove([VideoViewerController? controller]) {
    controller ??= Provider.of<VideoViewerController>(context, listen: false);
    return !(controller.isDraggingProgressBar ||
        controller.activeAd != null ||
        controller.isShowingChat);
  }

  //-------------------------------//
  //FORWARD AND REWIND (DOUBLE TAP)//
  //-------------------------------//
  void _rewind() => _showRewindAndForward(0, _defaultRewindAmount);
  void _forward() => _showRewindAndForward(1, _defaultForwardAmount);

  Future<void> _videoSeekToNextSeconds(int seconds) async {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );
    final int position =
        controller.videoPlayerController!.value.position.inSeconds;
    await controller.seekTo(Duration(seconds: position + seconds));
    if (controller.isPlaying) {
      await controller.play();
    }
  }

  void _showRewindAndForward(int index, int amount) async {
    bool areControlsUnLocked = !Provider.of<VideoViewerController>(
      context,
      listen: false,
    ).areControlsLocked;

    bool isPlayerInitialized = Provider.of<VideoViewerController>(
      context,
      listen: false,
    ).isPlayerInitialized;

    if (areControlsUnLocked && isPlayerInitialized) {
      _videoSeekToNextSeconds(amount);
      if (index == 0) {
        if (!_showAMomentRewindIcons[index]) _rewindDoubleTapCount = 0;
        _rewindDoubleTapTimer?.cancel();
        _rewindDoubleTapCount += 1;

        _rewindDoubleTapTimer = Timer(Duration(milliseconds: 600), () {
          _showAMomentRewindIcons[index] = false;
          setState(() {});
        });
      } else {
        if (!_showAMomentRewindIcons[index]) _forwardDoubleTapCount = 0;
        _forwardDoubleTapTimer?.cancel();
        _forwardDoubleTapCount += 1;

        _forwardDoubleTapTimer = Timer(Duration(milliseconds: 600), () {
          _showAMomentRewindIcons[index] = false;
          setState(() {});
        });
      }
      _showAMomentRewindIcons[index] = true;
      setState(() {});
    }
  }

  //------------------------------------//
  //FORWARD AND REWIND (DRAG HORIZONTAL)//
  //------------------------------------//
  void _forwardDragStart(Offset globalPosition) async {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );
    // await controller.pause();
    if (!controller.isShowingSettingsMenu) {
      Future.delayed(Duration(milliseconds: 50), () {
        if (_canListenerMove(controller)) {
          _showVolumeStatus = false;
          _showBrightnessStatus = false;

          _closeVolumeStatus?.cancel();
          _closeVolumeStatus = null;

          _closeBrightnessStatus?.cancel();
          _closeBrightnessStatus = null;

          _initialForwardPosition = controller.position;
          _horizontalDragStartOffset = globalPosition;
          _showForwardStatus = true;
          setState(() {});
        }
      });
    }
  }

  void _forwardDragUpdate(Offset globalPosition) {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );
    if (!controller.isShowingSettingsMenu) {
      final double diff = _horizontalDragStartOffset.dx - globalPosition.dx;
      final int duration = controller.duration.inSeconds;
      final int position = controller.position.inSeconds;
      final int seconds = -(diff / (200 / duration)).round();
      final int relativePosition = position + seconds;
      if (relativePosition <= duration && relativePosition >= 0) {
        _forwardAndRewindSecondsAmount.value = seconds;
      }
    }
  }

  void _forwardDragEnd() async {
    await _videoSeekToNextSeconds(_forwardAndRewindSecondsAmount.value);
    setState(() => _showForwardStatus = false);
  }

  //----------------------------//
  //VIDEO VOLUME (VERTICAL DRAG)//
  //----------------------------//
  void _setVolume({
    required double volume,
    required bool setSystemVolume,
  }) async {
    volume = double.parse(volume.clamp(0.0, 1.0).toStringAsFixed(2));

    if (volume != _oldVolumeValue) {
      _oldVolumeValue = volume;

      if (setSystemVolume) {
        // set the system volume. The input is a double number in the range [0.0, 1.0].
        VolumeController.instance.setVolume(volume);
        // SoLoud.instance.setGlobalVolume(volume);
      }

      _currentVolume.value = volume;

      if (mounted) {
        Provider.of<VideoViewerController>(
          context,
          listen: false,
        ).videoPlayerController!.setVolume(volume);
      }
    }
  }

  void _volumeDragUpdate(Offset delta) {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );
    if (!controller.isShowingSettingsMenu) {
      _setVolume(
        volume: (_currentVolume.value - (delta.dy / 300)),
        setSystemVolume: true,
      );
    }
  }

  void _volumeDragStart() {
    _isVolumeDragStarted = true;
    // volumeStream?.pause();

    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );
    if (!controller.isShowingSettingsMenu) {
      Future.delayed(Duration(milliseconds: 50), () {
        if (_canListenerMove(controller)) {
          setState(() {
            _closeBrightnessStatus?.cancel();
            _closeBrightnessStatus = null;
            _showBrightnessStatus = false;

            _closeVolumeStatus?.cancel();
            _showVolumeStatus = true;
          });
        }
      });
    }
  }

  Future<void> _volumeDragEnd() async {
    _isVolumeDragStarted = false;
    // volumeStream?.resume();

    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );
    if (!controller.isShowingSettingsMenu && _showVolumeStatus) {
      _currentVolume.value = await VolumeController.instance.getVolume();
      setState(() {
        _closeVolumeStatus = Timer(Duration(milliseconds: 600), () {
          setState(() {
            _closeVolumeStatus?.cancel();
            _closeVolumeStatus = null;
            _showVolumeStatus = false;
          });
        });
      });
    }
  }

  //----------------------------//
  //VIDEO BRIGHTNESS (VERTICAL DRAG)//
  //----------------------------//
  void _setBrightness(double brightness) async {
    brightness = brightness.clamp(0.0, 1.0);

    _setApplicationBrightness(_currentBrightness.value);

    _currentBrightness.value = brightness;
  }

  void _brightnessDragUpdate(Offset delta) {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );
    if (!controller.isShowingSettingsMenu) {
      _setBrightness(_currentBrightness.value - (delta.dy / 300));
    }
  }

  void _brightnessDragStart() {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );
    if (!controller.isShowingSettingsMenu) {
      Future.delayed(Duration(milliseconds: 50), () {
        if (_canListenerMove(controller)) {
          setState(() {
            _closeVolumeStatus?.cancel();
            _closeVolumeStatus = null;
            _showVolumeStatus = false;

            _closeBrightnessStatus?.cancel();
            _showBrightnessStatus = true;
          });
        }
      });
    }
  }

  void _brightnessDragEnd() {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );
    if (!controller.isShowingSettingsMenu && _showBrightnessStatus) {
      setState(() {
        _closeBrightnessStatus = Timer(Duration(milliseconds: 600), () {
          setState(() {
            _closeBrightnessStatus?.cancel();
            _closeBrightnessStatus = null;
            _showBrightnessStatus = false;
          });
        });
      });
    }
  }

  void _closeVolumeBrightnessAndSeekBar() {
    _showVolumeStatus = false;
    _showBrightnessStatus = false;

    _closeVolumeStatus?.cancel();
    _closeBrightnessStatus?.cancel();

    _closeVolumeStatus = null;
    _closeBrightnessStatus = null;

    _showForwardStatus = false;
  }

  void onEpisodeThumbnailTap({required Episode episode}) async {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );

    if (episode.title != VideoViewer.episodeTitle) {
      final List<EpisodeSource> episodeSources = episode.episodeSources;
      final String url = episodeSources.first.url;

      late List<VideoContent> videoContentList;

      if (url.contains("m3u8")) {
        videoContentList = await VideoSource.fromM3u8PlaylistUrl(m3u8: url);
      } else {
        videoContentList = VideoSource.fromNetworkVideoSources(
          episodeSources: episodeSources,
        );
      }

      final VideoContent videoContent = videoContentList.first;

      controller.closeAllSecondarySettingsMenus();
      controller.closeSettingsMenu();

      await controller.pause();

      await controller.changeSource(
        inheritPosition: false, //RESET SPEED TO NORMAL AND POSITION TO ZERO
        videoSource: videoContent.videoSource,
        name: videoContent.quality,
      );

      VideoViewer.episodeTitle = episode.title;
      controller.source = videoContentList;
      setState(() {});
    } else {
      controller.closeAllSecondarySettingsMenus();
      controller.closeSettingsMenu();
    }
    controller.notifyTheListeners();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, Orientation orientation) {
        final VideoPlayerController controller =
            Provider.of<VideoViewerController>(
              context,
              listen: true,
            ).videoPlayerController!;

        final video = Provider.of<VideoViewerController>(
          context,
          listen: false,
        );

        bool isFullScreenLandscape =
            video.isFullScreen && orientation == Orientation.landscape;

        return isFullScreenLandscape
            ? _globalGesture(isFullScreenLandscape)
            : AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: _globalGesture(isFullScreenLandscape),
              );
      },
    );
  }

  //--------//
  //GESTURES//
  //--------//
  Widget _globalGesture(bool canScale) {
    final VideoViewerMetadata metadata = Provider.of<VideoViewerMetadata>(
      context,
      listen: false,
    );

    bool areControlsUnLocked = !Provider.of<VideoViewerController>(
      context,
      listen: false,
    ).areControlsLocked;

    bool isPlayerInitialized = Provider.of<VideoViewerController>(
      context,
      listen: false,
    ).isPlayerInitialized;

    final bool horizontal = metadata.enableHorizontalSwapingGesture;
    final bool vertical = metadata.enableVerticalSwapingGesture;
    final bool scale = metadata.onFullscreenFixLandscape;

    return scale || horizontal || vertical
        ? GestureDetector(
            //--------------//
            //SCALE GESTURES//
            //--------------//
            onScaleStart: scale
                ? (_) {
                    if (areControlsUnLocked && isPlayerInitialized) {
                      _closeVolumeBrightnessAndSeekBar();
                      _initialScale = _scale.value;
                      final size = MediaQuery.of(context).size;
                      final VideoPlayerController video =
                          Provider.of<VideoViewerController>(
                            context,
                            listen: false,
                          ).videoPlayerController!;
                      final double aspectWidth =
                          size.height * video.value.aspectRatio;

                      _initialScale = _scale.value;
                      _maxScale = size.width / aspectWidth;
                    }
                  }
                : null,
            onScaleUpdate: scale
                ? (ScaleUpdateDetails details) {
                    if (areControlsUnLocked && isPlayerInitialized) {
                      final double newScale = _initialScale * details.scale;
                      if (newScale >= _minScale && newScale <= _maxScale) {
                        _scale.value = newScale;
                      }
                    }
                  }
                : null,
            //---------------------------//
            //VOLUME AND FORWARD GESTURES//
            //---------------------------//
            onPanUpdate: horizontal || vertical
                ? (DragUpdateDetails details) {
                    if (areControlsUnLocked && isPlayerInitialized) {
                      // Get the screen width
                      final screenWidth = MediaQuery.of(context).size.width;
                      // Get the starting horizontal position of the drag
                      final startPosition = details.globalPosition.dx;

                      if (startPosition < (screenWidth / 2)) {
                        // Drag started on the left half of the screen
                        _isVerticalDragStartedOnTheRightHalfOfTheScreen = false;
                      } else {
                        // Drag started on the right half of the screen
                        _isVerticalDragStartedOnTheRightHalfOfTheScreen = true;
                      }

                      if (_canListenerMove()) {
                        final Offset position = details.localPosition;
                        final Offset delta = details.delta;
                        if (_dragInitialDelta == Offset.zero) {
                          if (delta.dx.abs() > delta.dy.abs() && horizontal) {
                            _dragDirection = Axis.horizontal;
                            _forwardDragStart(position);
                          } else if (vertical) {
                            _dragDirection = Axis.vertical;
                            if (_isVerticalDragStartedOnTheRightHalfOfTheScreen) {
                              _volumeDragStart();
                            } else {
                              _brightnessDragStart();
                            }
                          }
                          _dragInitialDelta = delta;
                        }
                        switch (_dragDirection) {
                          case Axis.horizontal:
                            if (horizontal) _forwardDragUpdate(position);
                            break;
                          case Axis.vertical:
                            if (vertical) {
                              if (_isVerticalDragStartedOnTheRightHalfOfTheScreen) {
                                _volumeDragUpdate(delta);
                              } else {
                                _brightnessDragUpdate(delta);
                              }
                            }
                            break;
                        }
                      }
                    }
                  }
                : null,
            onPanEnd: horizontal || vertical
                ? (DragEndDetails details) {
                    if (areControlsUnLocked && isPlayerInitialized) {
                      _dragInitialDelta = Offset.zero;
                      switch (_dragDirection) {
                        case Axis.horizontal:
                          if (horizontal) _forwardDragEnd();
                          break;
                        case Axis.vertical:
                          if (vertical) {
                            if (_isVerticalDragStartedOnTheRightHalfOfTheScreen) {
                              _volumeDragEnd();
                            } else {
                              _brightnessDragEnd();
                            }
                          }
                          break;
                      }
                    }
                  }
                : null,
            onLongPress: () async {
              if (areControlsUnLocked && isPlayerInitialized) {
                _closeVolumeBrightnessAndSeekBar();
                final video = Provider.of<VideoViewerController>(
                  context,
                  listen: false,
                );

                if (video.isPlaying) {
                  video.isShowing2xSpeedIcon = true;
                  await video.videoPlayerController!.setPlaybackSpeed(2.0);

                  if (mounted) {
                    Provider.of<VideoViewerController>(
                      context,
                      listen: false,
                    ).showAndHideOverlay(false);
                  }
                }
              }
            },
            onLongPressEnd: (LongPressEndDetails details) async {
              if (areControlsUnLocked && isPlayerInitialized) {
                final video = Provider.of<VideoViewerController>(
                  context,
                  listen: false,
                );

                video.isShowing2xSpeedIcon = false;

                video.notifyTheListeners();

                /// if the video is being played at 2x by holding onto the tap and
                /// if due to connectivity issue the video started buffering while user is still
                /// holding the 2x tap then after releasing the tap,
                /// this while loop will pause the code here until the video is buffering.
                /// otherwise, the previous playback speed (speed before holding the tap to play at 2x)
                /// will be assigned to the player controller while video is still buffering,
                /// so in this case the assigned playback speed will be ignored by the controller,
                /// resulting the video to keep playing at 2x (which should not be the case).
                /// so this while loop will hold the rest of the code from being
                /// executed until video is buffering.
                while (video.isBuffering) {
                  await Future.delayed(const Duration(milliseconds: 500));
                }

                await video.videoPlayerController!.setPlaybackSpeed(
                  video.playbackSpeed,
                );

                video.notifyTheListeners();
              }
            },
            onDoubleTap: () async {
              if (areControlsUnLocked && isPlayerInitialized) {
                _closeVolumeBrightnessAndSeekBar();
                VideoViewerController controller =
                    Provider.of<VideoViewerController>(context, listen: false);

                await controller.playOrPause();

                if (!controller.isPlaying) {
                  controller.showPauseMessage();
                }
              }
            },
            child: _player(),
          )
        : _player();
  }

  Widget _player() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: _scale,
              builder: (_, double scale, __) =>
                  Transform.scale(scale: scale, child: const VideoCorePlayer()),
            ),
            const VideoCoreActiveSubtitleText(),
            // ColoredBox(
            //   color: Colors.amber.withAlpha(100),
            //   child: ClipRect(
            //     clipper: RectangularShapeClipper(),
            //     child: SizedBox(
            //       height: double.infinity,
            //       width: double.infinity,
            //       child: ColoredBox(color: Colors.black12),
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                _closeVolumeBrightnessAndSeekBar();

                Provider.of<VideoViewerController>(
                  context,
                  listen: false,
                ).showAndHideOverlay();
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(height: double.infinity, width: double.infinity),
            ),
            VideoCoreForwardAndRewind(
              showRewind: _showAMomentRewindIcons[0],
              showForward: _showAMomentRewindIcons[1],
              rewindSeconds: _defaultRewindAmount * _rewindDoubleTapCount,
              forwardSeconds: _defaultForwardAmount * _forwardDoubleTapCount,
            ),
            VideoCoreForwardAndRewindLayout(
              rewind: GestureDetector(onDoubleTap: _rewind),
              forward: GestureDetector(onDoubleTap: _forward),
            ),
            Builder(
              builder: (context) {
                final VideoViewerController controller =
                    Provider.of<VideoViewerController>(context, listen: true);
                final VideoViewerMetadata metadata =
                    Provider.of<VideoViewerMetadata>(context, listen: false);
                return Stack(
                  children: [
                    const VideoCoreBuffering(),
                    if (metadata.enableShowReplayIconAtVideoEnd)
                      CustomOpacityTransition(
                        visible:
                            (controller.position >= controller.duration) &&
                            !controller.isShowingOverlay,
                        child: const Center(
                          child: PlayAndPause(type: PlayAndPauseType.center),
                        ),
                      ),
                  ],
                );
              },
            ),
            VideoCoreOverlay(
              title: VideoViewer.episodeTitle,
              items: (media.episodes.length > 1)
                  ? [
                      SettingsMenuItem(
                        themed: SettingsMenuItemThemed(
                          title: "Episodes",
                          subtitle: VideoViewer.episodeTitle,
                          icon: Icon(
                            Icons.view_module_outlined,
                            color: Colors.white,
                          ),
                        ),
                        secondaryMenuWidth: 300,
                        secondaryMenu: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Center(
                            child: Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: [
                                for (Episode episode in media.episodes)
                                  EpisodeThumbnail(
                                    title: episode.title,
                                    url: episode.thumbnail,
                                    onTap: () =>
                                        onEpisodeThumbnailTap(episode: episode),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                  : null,
            ),
            CustomOpacityTransition(
              visible: _showForwardStatus,
              child: ValueListenableBuilder(
                valueListenable: _forwardAndRewindSecondsAmount,
                builder: (_, int seconds, __) => VideoCoreForwardAndRewindBar(
                  seconds: seconds,
                  position: _initialForwardPosition,
                  width: constraints.maxWidth * 0.5,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Builder(
                builder: (_) {
                  final controller = Provider.of<VideoViewerController>(
                    context,
                    listen: true,
                  );
                  return CustomSwipeTransition(
                    visible: controller.isShowingChat,
                    axis: Axis.horizontal,
                    axisAlignment: 1.0,
                    child: GradientBackground(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      child: Chat(),
                    ),
                  );
                },
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _currentVolume,
              builder: (_, double value, __) => VideoCoreVolumeBar(
                visible: _showVolumeStatus,
                progress: value,
                height: constraints.maxHeight * 0.25,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: ValueListenableBuilder(
                  valueListenable: _currentBrightness,
                  builder: (_, double value, __) => VideoCoreBrightnessBar(
                    visible: _showBrightnessStatus,
                    progress: value,
                    height: constraints.maxHeight * 0.25,
                  ),
                ),
              ),
            ),
            const VideoCoreThumbnail(),
            const VideoCoreAdViewer(),
          ],
        );
      },
    );
  }
}
