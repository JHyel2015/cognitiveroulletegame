import 'dart:async';

import 'package:cognitiveroulletegame/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'ruleta_painter.dart';

class Ruleta extends StatefulWidget {
  const Ruleta({super.key});

  @override
  State<Ruleta> createState() => _RuletaState();
}

class _RuletaState extends State<Ruleta> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0.0;
  int _segments = 3;
  final logger = AppLogger();

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.pink,
    Colors.cyan,
  ];

  final List<String> _labels = [
    'Premio 1',
    'Premio 2',
    'Premio 3',
    'Premio 4',
    'Premio 5',
    'Premio 6',
    'Premio 7',
    'Premio 8',
  ];

  late List<Image> _images;

  @override
  void initState() {
    super.initState();
    _segments = _colors.isEmpty ? _segments : _colors.length;
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..addListener(() {
        setState(() {
          _currentAngle = _animation.value;
        });
      });

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    );
    _animation =
        Tween<double>(begin: 0, end: 2 * pi * 4).animate(curvedAnimation);
  }

  void _spin() {
    logger.i('spin ${_controller.isAnimating}');
    logger.i('spin ${_currentAngle % (2 * pi)}');
    if (_controller.isAnimating) return;
    _controller.forward(from: 0);
  }

  void _stop() {
    logger.i('stop ${_controller.isAnimating}');
    logger.i('stop ${_currentAngle % (2 * pi)}');
    if (_controller.isAnimating) {
      _controller.stop();
      _showResult();
    }
  }

  void _showResult() {
    final double normalizedAngle = (_currentAngle % (2 * pi));
    final double segmentAngle = (2 * pi / _segments);
    final int segmentIndex =
        (_segments + (normalizedAngle / segmentAngle).floor()) % _segments;

    logger.i('Segmento: ${_labels[segmentIndex]}');
    Future.delayed(const Duration(seconds: 2), () {
      _controller.forward(from: 0);
    });

    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: Text('Resultado'),
    //       content: Text('Segmento: ${_labels[segmentIndex]}'),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //             _controller.forward(from: 0);
    //           },
    //           child: Text('OK'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruleta Animada'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: _controller.isAnimating ? _stop : _spin,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(300, 300),
                painter: RuletaPainter(0.0, _segments, _colors, _images),
              ),
              Transform.rotate(
                angle: _currentAngle,
                child: Image.asset(
                  'assets/flecha.png',
                  width: 60,
                  height: 60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
