import 'package:flutter/material.dart';

class KaraokeText1 extends StatefulWidget {
  const KaraokeText1({super.key});

  @override
  _KaraokeTextState createState() => _KaraokeTextState();
}

class _KaraokeTextState extends State<KaraokeText1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _animationProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animationProgress = Tween<double>(begin: 0, end: 1).animate(_controller);
    _animation = CurvedAnimation(
      curve: Curves.easeInSine,
      reverseCurve: Curves.easeOutSine,
      parent: _animationProgress,
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return DefaultTextStyle(
              style: TextStyle(
                fontSize: 20 + 3 * _animation.value,
              ),
              child: child!,
            );
          },
          child: const Text(
            'Chung ta khong thuoc ve nhau',
            style: TextStyle(color: Colors.white),
          ),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ClipRect(
              clipper: KaraokeTextClipper(
                progress: _animation.value,
                isLeft: true,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 20 + 3 * _animation.value,
                ),
                child: child!,
              ),
            );
          },
          child: const Text(
            'Chung ta khong thuoc ve nhau',
            style: TextStyle(color: Colors.red),
          ),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ClipRect(
              clipper: KaraokeTextClipper(
                progress: _animation.value,
                isLeft: false,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 20 + 3 * _animation.value,
                ),
                child: child!,
              ),
            );
          },
          child: const Text(
            'Chung ta khong thuoc ve nhau',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

class KaraokeTextClipper extends CustomClipper<Rect> {
  final double progress;
  final bool isLeft;

  KaraokeTextClipper({
    required this.progress,
    required this.isLeft,
  });

  @override
  Rect getClip(Size size) {
    if (isLeft) {
      return Rect.fromLTWH(
        size.width / 2 * (1 - progress),
        0,
        size.width / 2 * progress,
        size.height,
      );
    } else {
      return Rect.fromLTWH(
        size.width / 2,
        0,
        size.width / 2 * progress,
        size.height,
      );
    }
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
