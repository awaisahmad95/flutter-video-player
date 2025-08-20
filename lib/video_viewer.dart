import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/domain/bloc/metadata.dart';
import 'package:video_viewer_demo/domain/entities/video_source.dart';
import 'package:video_viewer_demo/ui/video_core/video_core.dart';
import 'main.dart';
export 'package:video_player/video_player.dart';
export 'package:video_viewer_demo/domain/bloc/controller.dart';
export 'package:video_viewer_demo/domain/entities/ads.dart';
export 'package:video_viewer_demo/ui/settings_menu/settings_menu_item.dart';
export 'package:video_viewer_demo/domain/entities/subtitle.dart';
export 'package:video_viewer_demo/domain/entities/video_source.dart';

class VideoViewer extends StatefulWidget {
  static String episodeTitle = '';

  const VideoViewer({
    super.key,
    required this.videoContentList,
    // this.controller,
    this.looping = false,
    this.autoPlay = false,
    this.defaultAspectRatio = 16 / 9,
    this.rewindAmount = -10,
    this.forwardAmount = 10,
    this.onFullscreenFixLandscape = false,
    this.enableFullscreenScale = true,
    this.enableVerticalSwappingGesture = true,
    this.enableHorizontalSwappingGesture = true,
    this.enableShowReplayIconAtVideoEnd = true,
    this.enableChat = false,
  });

  /// Once the video is initialized, it will be played
  final bool autoPlay;

  ///Sets whether or not the video should loop after playing once.
  final bool looping;

  /// It is an argument where you can change the design of almost the entire VideoViewer
  // final VideoViewerStyle? style;

  /// It is the Aspect Ratio that the widget.style.loading will take when the video
  /// is not initialized yet
  final double defaultAspectRatio;

  /// It is the amount of seconds that the video will be delayed when double tapping.
  final int rewindAmount;

  /// It is the amount of seconds that the video will be advanced when double tapping.
  final int forwardAmount;

  /// Receive a list of all the resources to be played.
  ///
  ///SYNTAX EXAMPLE:
  ///```dart
  ///{
  ///    "720p": VideoSource(video: VideoPlayerController.network("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4")),
  ///    "1080p": VideoSource(video: VideoPlayerController.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")),
  ///}
  ///```
  final List<VideoContent> videoContentList;

  ///If it is `true`, when entering the fullscreen it will be fixed
  ///in landscape mode and it will not be possible to rotate it in portrait.
  ///If it is `false`, you can rotate the entire screen in any position.
  final bool onFullscreenFixLandscape;

  ///It's the custom language can you set to the VideoViewer.
  ///
  ///**EXAMPLE:** SETTING THE SPANISH LANGUAGE TO THE VIDEOVIEWER
  ///```dart
  /// //WAY 1
  /// language: VideoViewerLanguage.es
  /// //WAY 2
  /// language: VideoViewerLanguage(quality: "Calidad", speed: "Velocidad", ...)
  /// //WAY 3
  /// language: VideoViewerLanguage.fromString("es")
  /// ```
  // final VideoViewerLanguage language;

  /// Controls a platform video viewer, and provides updates when the state is
  /// changing.
  ///
  /// Instances must be initialized with initialize.
  ///...
  /// The video is displayed in a Flutter app by creating a [VideoPlayer] widget.
  ///
  /// To reclaim the resources used by the player call [dispose].
  ///
  /// After [dispose] all further calls are ignored.
  // final VideoViewerController? controller;

  ///When the video is fullscreen and landscape mode, It's able to scale itself until the screen boundaries
  final bool enableFullscreenScale;

  ///On VerticalSwappingGesture the video is able to control the **video volume** or **device volume**.
  final bool enableVerticalSwappingGesture;

  ///On HorizontalSwappingGesture the video is able to control the forward and rewind of itself
  final bool enableHorizontalSwappingGesture;

  //If true, it will add the chat icon to bottom bar. The icon on tap it will show the chat widget.
  final bool enableChat;

  //When the video end, it show a replay icon. If its false, it will never show.
  final bool enableShowReplayIconAtVideoEnd;

  @override
  VideoViewerState createState() => VideoViewerState();
}

class VideoViewerState extends State<VideoViewer> {
  late VideoViewerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    _controller = VideoViewerController();
    _initVideoViewer();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initVideoViewer() async {
    _controller.looping = widget.looping;
    // _controller.isShowingThumbnail = _style.thumbnail != null;
    await _controller.initialize(widget.videoContentList, autoPlay: widget.autoPlay);

    if (!mounted) return;

    setState(() {
      if (_controller.isPlayerInitialized) {
        _initialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? thumbnail;

    if (media.thumbnail.isNotEmpty) {
      thumbnail = Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: Colors.black, child: SizedBox.expand()),
          ),
          Positioned.fill(
            child: Image.network(
              media.thumbnail,
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    }

    return _initialized
        ? MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _controller),
              Provider(
                create: (_) => VideoViewerMetadata(
                  rewindAmount: widget.rewindAmount,
                  forwardAmount: widget.forwardAmount,
                  defaultAspectRatio: widget.defaultAspectRatio,
                  onFullscreenFixLandscape: widget.onFullscreenFixLandscape,
                  enableFullscreenScale: widget.enableFullscreenScale,
                  enableVerticalSwapingGesture:
                      widget.enableVerticalSwappingGesture,
                  enableHorizontalSwapingGesture:
                      widget.enableHorizontalSwappingGesture,
                  enableChat: widget.enableChat,
                  enableShowReplayIconAtVideoEnd:
                      widget.enableShowReplayIconAtVideoEnd,
                  // items: widget.items,
                ),
              ),
            ],
            builder: (context, child) {
              _controller.context = context;
              return VideoViewerCore();
            },
          )
        : _controller.isPlayerInitializationProcessFinished
        ? AspectRatio(
            aspectRatio: widget.defaultAspectRatio,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: Colors.black),
                ),
                Center(
                  child: Text(
                    'Unable to play this video.',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        : AspectRatio(
            aspectRatio: widget.defaultAspectRatio,
            child: Stack(
              children: [
                Positioned.fill(
                  child: (thumbnail != null)
                      ? thumbnail
                      : Container(color: Colors.black),
                ),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
