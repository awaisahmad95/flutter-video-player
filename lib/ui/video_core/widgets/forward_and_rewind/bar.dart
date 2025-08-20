import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/ui/widgets/helpers.dart';

class VideoCoreForwardAndRewindBar extends StatelessWidget {
  const VideoCoreForwardAndRewindBar({
    super.key,
    required this.seconds,
    required this.position,
    required this.width,
  });

  final int seconds;
  final Duration position;
  final double width;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VideoViewerController>(
      context,
      listen: false,
    );

    final Duration duration = controller.duration;
    final double height = 5;
    final int relativePosition = position.inSeconds + seconds;

    return Center(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(71),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              durationFormatter(Duration(seconds: relativePosition)),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: height,
              width: width,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  Container(
                    height: height,
                    width: ((relativePosition / duration.inSeconds) * width)
                        .clamp(0.0, width),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  CustomPaint(
                    size: Size.infinite,
                    painter: _InitialPositionIdentifierPainter(
                      position:
                          (position.inSeconds / duration.inSeconds) * width,
                      color: Colors.red,
                      width: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialPositionIdentifierPainter extends CustomPainter {
  _InitialPositionIdentifierPainter({
    required this.color,
    required this.position,
    this.width = 2.0,
  });

  final Color color;
  final double position;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final RRect rect = RRect.fromRectAndRadius(
      Offset(position, -size.height / 2) & Size(width, size.height * 2),
      Radius.circular(width),
    );
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(_InitialPositionIdentifierPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_InitialPositionIdentifierPainter oldDelegate) =>
      false;
}
