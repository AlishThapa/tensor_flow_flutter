import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  late CameraImage cameraImage;

  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  var x, y, w, h = 0.0;
  var label = '';

  @override
  void onInit() {
    super.onInit();

    initTflite();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = await CameraController(cameras[0], ResolutionPreset.max);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 20 == 0) {
            cameraCount = 0;
            objectDetector(image);
          }
          update();
        });
      });
      isCameraInitialized(true);
      update();
    } else {
      print('Permission Denied');
    }
  }

  initTflite() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
    initCamera();
  }

  objectDetector(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
      bytesList: image.planes.map(
        (e) {
          return e.bytes;
        },
      ).toList(),
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      numResults: 1,
      threshold: 0.4,
      asynch: true,
    );
    if (detector != null) {
      if (detector.first['confidence'] * 100 > 45) {
        Logger().d('Result is $detector');
      }
      // Logger().d('Result when false is $detector');
    }
  }
}
