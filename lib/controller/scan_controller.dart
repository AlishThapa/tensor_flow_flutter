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
  var label = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initCamera();
    loadModel();
  }

  @override
  void dispose() async {
    cameraController.dispose();
    await Tflite.close();
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

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
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
      numResults: 2,
      threshold: 0.1,
      asynch: true,
    );
    detector!.forEach((response) {
      Logger().d("huhuhahahah +${response['label']}");
      label.value += response['label'] + " " + (response['confidence'] as double).toStringAsFixed(2) + "\n";
    });

    // if (detector != null) {
    //   if (detector.first['confidence'] * 100 > 45) {
    Logger().d('Result is ${detector.firstOrNull['label']}');
    //     label = detector.first['label'].toString();
    //   }
    //   update();
    // }
  }
}
