import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/ui/widgets/helpers.dart';
import 'package:video_viewer_demo/ui/widgets/transitions.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({super.key});

  @override
  VideoProgressBarState createState() => VideoProgressBarState();
}

class VideoProgressBarState extends State<VideoProgressBar> {
  final ValueNotifier<Duration> _progressBarDraggingBuffer =
      ValueNotifier<Duration>(Duration.zero);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => ValueNotifier<int>(1000)),
        ListenableProvider.value(value: _progressBarDraggingBuffer),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: LayoutBuilder(
          builder: (_, constraints) {
            final VideoViewerController controller = Provider.of<VideoViewerController>(context, listen: true);

            final Duration position = controller.position;
            final Duration end = controller.duration;
            final double width = constraints.maxWidth;

            return ValueListenableBuilder(
              valueListenable: _progressBarDraggingBuffer,
              builder: (_, Duration value, ___) {
                final Duration draggingPosition =
                    controller.isDraggingProgressBar ? value : position;
                final double progressWidth =
                    (draggingPosition.inMilliseconds / end.inMilliseconds) *
                        width;

                return _ProgressBarGesture(
                  width: width,
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      _ProgressBar(width: width, color: Colors.white.withAlpha(100)),
                      _ProgressBar(
                        color: Colors.white,
                        width: (controller.maxBuffering.inMilliseconds /
                                end.inMilliseconds) *
                            width,
                      ),
                      _ProgressBar(width: progressWidth, color: Colors.red),
                      _DotIsDragging(width: width, dotPosition: progressWidth),
                      _Dot(width: width, dotPosition: progressWidth),
                      CustomOpacityTransition(
                        visible: controller.isDraggingProgressBar,
                        child: CustomPaint(
                          painter: _TextPositionPainter(
                            position: draggingPosition,
                            width: progressWidth,
                            style: TextStyle(
                                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProgressBarGesture extends StatefulWidget {
  const _ProgressBarGesture({
    required this.child,
    required this.width,
  });

  final Widget child;
  final double width;

  @override
  __ProgressBarGestureState createState() => __ProgressBarGestureState();
}

class __ProgressBarGestureState extends State<_ProgressBarGesture> {
  VideoViewerController get playerController {
  return Provider.of<VideoViewerController>(context, listen: false);
}

  ValueNotifier<Duration> get videoPosition {
    return Provider.of<ValueNotifier<Duration>>(context, listen: false);
  }

  set animationMilliseconds(int value) {
    Provider.of<ValueNotifier<int>>(context, listen: false).value = value;
  }

  void _seekToRelativePosition(Offset local, [bool showText = false]) {
    final controller = Provider.of<VideoViewerController>(context, listen: false);
    final Duration duration = controller.duration;
    final double localPos = local.dx / widget.width;
    final Duration position = duration * localPos;

    if (position >= Duration.zero && position <= duration) {
      videoPosition.value = position;
    }
  }

  Future<void> play() async {
    animationMilliseconds = 1000;
    await Provider.of<VideoViewerController>(context, listen: false).play();
  }

  Future<void> pause() async {
    animationMilliseconds = 0;
    await Provider.of<VideoViewerController>(context, listen: false).videoPlayerController?.pause();
  }

  void _startDragging() {
    Provider.of<VideoViewerController>(context, listen: false).isDraggingProgressBar = true;

    Provider.of<VideoViewerController>(
      context,
      listen: false,
    ).isBuffering = true;
  }

  Future<void> _endDragging() async {
    final controller = Provider.of<VideoViewerController>(context, listen: false);
    await controller.seekTo(controller.beginRange + videoPosition.value);
    controller.isDraggingProgressBar = false;
    if (controller.activeAd == null) {
      if (controller.isPlaying) {
        await play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        if (playerController.isPlayerInitialized) {
          _startDragging();
          // pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (playerController.isPlayerInitialized) {
          _seekToRelativePosition(details.localPosition, true);
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (playerController.isPlayerInitialized) {
          _endDragging();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (playerController.isPlayerInitialized) {
          _startDragging();
          _seekToRelativePosition(details.localPosition);
        }
        // pause();
      },
      onTapUp: (TapUpDetails details) {
        if (playerController.isPlayerInitialized) {
          _seekToRelativePosition(details.localPosition);
          _endDragging();
        }
      },
      child: widget.child,
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.width,
    required this.color,
  });

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    // final animation = Provider.of<ValueNotifier<int>>(context);

    final controller = Provider.of<VideoViewerController>(context, listen: false,);

    return AnimatedContainer(
      width: width,
      height: controller.isFullScreen ? 4 : 2,
      // duration: Duration(milliseconds: animation.value),
      duration: Duration(milliseconds: 0),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    );
  }
}

class _DotIsDragging extends StatelessWidget {
  const _DotIsDragging({
    required this.width,
    required this.dotPosition,
  });

  final double dotPosition;
  final double width;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VideoViewerController>(context, listen: true);

    return BooleanTween(
      animate: controller.isDraggingProgressBar &&
          (dotPosition > 5) &&
          (dotPosition < width - 5),
      tween: Tween<double>(begin: 0, end: 0.4),
      builder: (_, double value, __) => _Dot(
        width: width,
        dotPosition: dotPosition,
        opacity: value,
        multiplicator: 2,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.width,
    required this.dotPosition,
    this.opacity = 1,
    this.multiplicator = 1,
  });

  final double dotPosition;
  final int multiplicator;
  final double? width, opacity;

  @override
  Widget build(BuildContext context) {
    final animation = Provider.of<ValueNotifier<int>>(context);

    final controller = Provider.of<VideoViewerController>(context, listen: false,);

    double dotSize = controller.isFullScreen ? 7 : 5;

    final double dotWidth = dotSize * 2;
    final double width = dotPosition < dotSize
        ? dotWidth
        : dotPosition + dotSize * multiplicator;

    return ValueListenableBuilder(
      valueListenable: animation,
      builder: (_, int value, __) {
        return AnimatedContainer(
          width: width,
          duration: Duration(milliseconds: 0),
          // duration: Duration(milliseconds: value),
          alignment: Alignment.centerRight,
          child: Container(
            height: dotWidth * multiplicator,
            width: dotWidth * multiplicator,
            decoration: BoxDecoration(
              color: Colors.red.withAlpha((255 * opacity!).toInt()),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _TextPositionPainter extends CustomPainter {
  _TextPositionPainter({this.width, this.position, this.style,});

  final Duration? position;
  final TextStyle? style;
  final double? width;

  @override
  void paint(Canvas canvas, Size size) {
    final text = durationFormatter(position!);
    final textStyle = ui.TextStyle(
      color: style!.color,
      fontSize: style!.fontSize! + 1,
      fontFamily: style!.fontFamily,
      fontWeight: style!.fontWeight,
      fontStyle: style!.fontStyle,
      fontFamilyFallback: style!.fontFamilyFallback,
      fontFeatures: style!.fontFeatures,
      foreground: style!.foreground,
      background: style!.background,
      letterSpacing: style!.letterSpacing,
      wordSpacing: style!.wordSpacing,
      height: style!.height,
      locale: style!.locale,
      textBaseline: style!.textBaseline,
      decorationColor: style!.decorationColor,
      decoration: style!.decoration,
      decorationStyle: style!.decorationStyle,
      decorationThickness: style!.decorationThickness,
      shadows: style!.shadows,
    );

    final paragraphStyle = ui.ParagraphStyle(textDirection: TextDirection.ltr);
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);

    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: 100));

    final height = 5;
    final double padding = 12;
    final minWidth = paragraph.minIntrinsicWidth;
    final doubleHeight = height * 2;
    final offset = Offset(
      width! - (minWidth / 2),
      -(padding * 2) - doubleHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offset.dx - doubleHeight,
          offset.dy - height,
          minWidth + height * 4,
          paragraph.height + doubleHeight,
        ),
        BorderRadius.all(Radius.circular(5)).topLeft,
      ),
      Paint()..color = Colors.black.withAlpha(92),
    );
    canvas.drawParagraph(paragraph, offset);
  }

  @override
  bool shouldRebuildSemantics(_TextPositionPainter oldDelegate) => false;

  @override
  bool shouldRepaint(_TextPositionPainter oldDelegate) => true;
}
