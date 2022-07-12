import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ssh2/ssh2.dart';

class Util {
  Future<File> getImageFileFromAssets(String path, String fileName) async {
    final byteData = await rootBundle.load(path);
    final buffer = byteData.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath =
        '$tempPath/$fileName.json'; // file_01.tmp is dump file, can be anything
    return File(filePath).writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  Future<SSHClient> sshClient(
      String keyDirectory, String hostName, String userName) async {
    var c = await rootBundle.loadString(keyDirectory);
    var client = SSHClient(
      host: hostName,
      port: 22,
      username: userName,
      passwordOrKey: {
        "privateKey": c,
      },
    );
    return client;
  }

  Future<void> log(String? log) async {
    if (kDebugMode) {
      print(log);
    }
    await Future.delayed(const Duration(seconds: 1));
  }
}
