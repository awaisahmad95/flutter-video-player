import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomOpacityTransition extends StatelessWidget {
  const CustomOpacityTransition({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.reverseDuration,
  });

  final bool visible;
  final Widget child;
  final Duration duration;
  final Duration? reverseDuration;

  @override
  Widget build(BuildContext context) {
    return BooleanTween<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      animate: visible,
      curve: Curves.ease,
      duration: duration,
      reverseDuration: reverseDuration,
      builder: (_, opacity, child) => Opacity(
        opacity: opacity,
        child: opacity > 0.0 ? child : null,
      ),
      child: child,
    );
  }
}

class CustomSwipeTransition extends StatelessWidget {
  const CustomSwipeTransition({
    super.key,
    required this.visible,
    required this.child,
    this.axisAlignment = -1.0,
    this.axis = Axis.vertical,
    this.duration = const Duration(milliseconds: 400),
    this.reverseDuration,
  });

  final bool visible;
  final Widget child;
  final double axisAlignment;
  final Axis axis;
  final Duration duration;
  final Duration? reverseDuration;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      child: BooleanTween<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        curve: Curves.ease,
        animate: visible,
        duration: duration,
        reverseDuration: reverseDuration,
        builder: (_, lerp, ___) => Align(
          alignment: (axis == Axis.vertical)
              ? AlignmentDirectional(-1.0, axisAlignment)
              : AlignmentDirectional(axisAlignment, -1.0),
          heightFactor: axis == Axis.vertical ? math.max(lerp, 0.0) : null,
          widthFactor: axis == Axis.horizontal ? math.max(lerp, 0.0) : null,
          child: child,
        ),
      ),
    );
  }
}

class BooleanTween<T> extends StatefulWidget {
  ///It is an AnimatedBuilder.
  ///If it is TRUE, it will execute the Tween from begin to end
  ///(controller.forward()),
  ///if it is FALSE it will execute the Tween from end to begin (controller.reverse())
  const BooleanTween({
    super.key,
    required this.animate,
    required this.builder,
    this.child,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 200),
    this.reverseCurve,
    this.reverseDuration,
    required this.tween,
  });

  ///If it is **TRUE**, it will execute the Tween from begin to end.
  ///
  ///If it is **FALSE** it will execute the Tween from end to begin
  final bool animate;

  ///Called every time the animation changes value.
  ///Return a Widget and receive the interpolation value as a parameter.
  final ValueWidgetBuilder<T> builder;

  final Widget? child;

  /// It is the curve that will carry out the interpolation.
  final Curve curve;

  /// It is the time it takes to execute the animation from beginning to end or vice versa.

  final Duration duration;

  /// It is the curve that will carry out the interpolation.
  final Curve? reverseCurve;

  /// It is the time it takes to execute the animation from beginning to end or vice versa.
  final Duration? reverseDuration;

  /// A linear interpolation between a beginning and ending value.
  ///
  /// [Tween] is useful if you want to interpolate across a range.
  ///
  ///You should use `LerpTween()` instead `Tween<double>(begin: 0.0, end: 1.0)`
  final Tween<T> tween;

  @override
  BooleanTweenState<T> createState() => BooleanTweenState<T>();
}

class BooleanTweenState<T> extends State<BooleanTween<T>>
    with SingleTickerProviderStateMixin {
  late Animation<T> _animation;
  late AnimationController _controller;

  @override
  void didUpdateWidget(BooleanTween oldWidget) {
    super.didUpdateWidget(oldWidget as BooleanTween<T>);
    if (!oldWidget.animate && widget.animate) {
      _controller.forward();
    } else if (oldWidget.animate && !widget.animate) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = AnimationController(
      value: widget.animate ? 1.0 : 0.0,
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );
    _animation = widget.tween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) =>
          widget.builder(context, _animation.value, child),
      child: widget.child,
    );
  }
}
