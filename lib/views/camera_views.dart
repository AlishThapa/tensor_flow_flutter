import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tflite_new/controller/scan_controller.dart';

class CameraPreviewPage extends StatefulWidget {
  const CameraPreviewPage({super.key});

  @override
  State<CameraPreviewPage> createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<CameraPreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GetBuilder<ScanController>(
            init: ScanController(),
            builder: (controller) {
              return controller.isCameraInitialized.value
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          CameraPreview(
                            controller.cameraController,
                          ),
                          Container(
                            height: 100,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green, width: 4.0),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ColoredBox(color: Colors.white, child: Text('label of object')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Text(
                      'Loading Preview',
                    );
            },
          ),
        ),
      ),
    );
  }
}
