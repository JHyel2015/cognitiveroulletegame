import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

import 'ruleta_painter.dart';

class Ruleta extends StatefulWidget {
  @override
  _RuletaState createState() => _RuletaState();
}

class _RuletaState extends State<Ruleta> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0.0;
  int _segments = 3;

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

  final List<String> _imagePaths = [
    'assets/image1.png',
    'assets/image2.png',
    'assets/image3.png',
    'assets/image4.png',
    'assets/image5.png',
    'assets/image6.png',
    'assets/image7.png',
    'assets/image8.png',
  ];

  late List<Image> _images;

  @override
  void initState() {
    super.initState();
    _segments = _colors.isEmpty ? _segments : _colors.length;
    _controller = AnimationController(
      duration: Duration(seconds: 5),
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

  Future<void> _loadImages() async {
    _images = _imagePaths.map((path) => Image.asset(path)).toList();
    await Future.wait(_images.map((image) => _loadImage(image)));
    setState(() {});
  }

  Future<void> _loadImage(Image image) {
    final Completer<void> completer = Completer();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        completer.complete();
      }),
    );
    return completer.future;
  }

  void _spin() {
    print('spin ${_controller.isAnimating}');
    print('spin ${_currentAngle % (2 * pi)}');
    if (_controller.isAnimating) return;
    _controller.forward(from: 0);
  }

  void _stop() {
    print('stop ${_controller.isAnimating}');
    print('stop ${_currentAngle % (2 * pi)}');
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

    print('Segmento: ${_labels[segmentIndex]}');
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
    if (_images == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ruleta con Flecha'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ruleta Animada'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: _controller.isAnimating ? _stop : _spin,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(300, 300),
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
