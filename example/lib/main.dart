import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_scan/r_scan.dart';

import 'scan_camera_dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyPage());
  }
}

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final ImagePicker picker = ImagePicker();

  RScanResult? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('scan example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              result == null
                  ? '点击下方按钮开始扫码'
                  : '扫码结果${result.toString().split(',').join('\n')}',
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                final RScanResult? result = await Navigator.of(context).push(
                  MaterialPageRoute<RScanResult>(
                    builder: (BuildContext context) => RScanCameraDialog(),
                  ),
                );
                setState(() {
                  this.result = result;
                });
              },
              child: const Text('RScanCamera 开始扫码'),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                if (await canReadStorage()) {
                  final PickedFile? image = await picker.getImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    final RScanResult? result = await RScan.scanImagePath(
                      image.path,
                    );
                    setState(() {
                      this.result = result;
                    });
                  }
                }
              },
              child: const Text('选择图片扫描'),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                final RScanResult? result = await RScan.scanImageUrl(
                  'https://s.cn.bing.net/th'
                  '?id=OJ.5F0gxqWmxskS0Q&w=75&h=75&pid=MSNJVFeeds',
                );
                setState(() {
                  this.result = result;
                });
              },
              child: const Text('网络图片解析'),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                final ByteData data = await rootBundle.load(
                  'images/qrCode.png',
                );
                final RScanResult? result = await RScan.scanImageMemory(
                  data.buffer.asUint8List(),
                );
                setState(() {
                  this.result = result;
                });
              },
              child: const Text('内存图片解析'),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> canReadStorage() async {
    if (Platform.isIOS) {
      return true;
    }
    final Map<Permission, PermissionStatus> status = await <Permission>[
      Permission.storage,
    ].request();
    return status[Permission.storage] == PermissionStatus.granted;
  }
}
