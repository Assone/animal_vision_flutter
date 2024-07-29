import 'dart:ui' as ui;

import 'package:animal_vision/SwitchAnimalVision.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: Center(
          child: AnimalVisionCamera(cameras: cameras),
        ),
      ),
    );
  }
}

class AnimalVisionCamera extends StatefulWidget {
  final List<CameraDescription> cameras;

  const AnimalVisionCamera({Key? key, required this.cameras}) : super(key: key);

  @override
  _AnimalVisionCameraState createState() => _AnimalVisionCameraState();
}

class _AnimalVisionCameraState extends State<AnimalVisionCamera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String _currentVision = 'cat';
  int _cameraFrameCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture.then((_) {
      _controller.startImageStream((CameraImage image) {
        setState(() {
          _cameraFrameCount++;
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: FutureBuilder(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              Expanded(
                  child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: .5,
                  child: Transform.scale(
                    scale: 1.5,
                    child: CameraPreview(_controller),
                  ),
                ),
              )),
              Expanded(
                  child: ClipRect(
                child: Align(
                  alignment: Alignment.center,
                  heightFactor: .5,
                  child: Stack(
                    children: [
                      Transform.scale(
                        scale: 1.5,
                        child: ShaderBuilder(
                          assetKey: 'shaders/animal_vision.frag',
                          (context, shader, child) => AnimatedSampler(
                            (ui.Image image, Size size, Canvas canvas) {
                              shader
                                ..setFloat(0, size.width)
                                ..setFloat(1, size.height)
                                ..setFloat(2, _getVisionMode())
                                ..setImageSampler(0, image);
                              canvas.drawRect(
                                  Offset.zero & size, Paint()..shader = shader);
                            },
                            key: ValueKey(_cameraFrameCount),
                            child: CameraPreview(_controller),
                          ),
                        ),
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: SwitchAnimalVision(
                              currentAnimal: _currentVision,
                              onChange: (value) =>
                                  {setState(() => _currentVision = value)}))
                    ],
                  ),
                ),
              )),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }

  double _getVisionMode() {
    switch (_currentVision) {
      case 'cat':
        return 0.0;
      case 'dog':
        return 1.0;
      case 'parrot':
        return 2.0;
      default:
        return 0.0;
    }
  }
}
