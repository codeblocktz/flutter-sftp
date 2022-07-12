import 'dart:typed_data';
import 'dart:io';
import 'package:csv/csv.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';
import 'package:sftp/util.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FPS Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'FTP upload'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String hostname =
      's-e34e94b416cf4c95a.server.transfer.us-east-1.amazonaws.com';
  final String username = 'codeblock';
  final String keyDirectory = 'assets/key/codeblock';
  final String downloadPath = "/storage/emulated/0";
  String _result = '';

  final util = Util();

  void resetValues(String log) {
    setState(() {
      _result = log;
    });
  }

  Future onGenerateCsv() async {
    List<List<String>> data = [
      [
        "Uid.",
        "source_name",
        "source_id",
        "device_id",
        "platform_type",
        "date_from",
        "date_to",
        "data_type",
        "value",
        "unit"
      ],
      [
        "1",
        randomAlpha(3),
        randomNumeric(5),
        randomNumeric(4),
        randomNumeric(4),
        DateFormat.yMMMd().format(DateTime.now()),
        DateFormat.yMMMd().format(DateTime.now()),
        randomNumeric(3),
        randomNumeric(4),
        "1"
      ],
      [
        "1",
        randomAlpha(3),
        randomNumeric(5),
        randomNumeric(4),
        randomNumeric(4),
        DateFormat.yMMMd().format(DateTime.now()),
        DateFormat.yMMMd().format(DateTime.now()),
        randomNumeric(3),
        randomNumeric(4),
        "1"
      ],
      [
        "1",
        randomAlpha(3),
        randomNumeric(5),
        randomNumeric(4),
        randomNumeric(4),
        DateFormat.yMMMd().format(DateTime.now()),
        DateFormat.yMMMd().format(DateTime.now()),
        randomNumeric(3),
        randomNumeric(4),
        "1"
      ],
    ];
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();
      if (kDebugMode) {
        print(statuses[Permission.storage]);
      }
      util.log(statuses[Permission.storage]!.isGranted == true ? "true" : "false");
      if (statuses[Permission.storage]!.isGranted) {
        util.log(
            statuses[Permission.storage]!.isGranted == true ? "true" : "false");
        String csvData = const ListToCsvConverter().convert(data);
        final String directory = (await getApplicationSupportDirectory()).path;
        final path = "$directory/csv-${DateTime.now()}.csv";
        final File file = File(path);
        await file.writeAsString(csvData);
        util.log(path);

        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (_) {
        //       return LoadCsvDataScreen(path: path);
        //     },
        //   ),
        // );
      } else {
        await Permission.storage.request();
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      util.log(errorMessage);
    }
  }

  Future<void> onClickSFTP() async {
    String result = '';
    resetValues('Loading');
    var client = await util.sshClient(keyDirectory, hostname, username);

    try {
      result = await client.connect() ?? 'Null result';
      if (result == "session_connected") {
        result = await client.connectSFTP() ?? 'Null result';
        if (result == "sftp_connected") {
          var file = await util.getImageFileFromAssets(
              'assets/rpm/mobile/health_data_2022_06_22_13_00.json',
              'health_data_2022_06_22_13_00');
          result = await client.sftpUpload(
                path: file.path,
                toPath: "rpm/mobile/",
                callback: (progress) async {
                  util.log(progress);
                },
              ) ??
              'Upload failed';
          await client.disconnect();
        }
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      result += errorMessage;
      util.log(errorMessage);
    }
    resetValues(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _result,
              style: Theme.of(context).textTheme.headline4,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onGenerateCsv, //onClickSFTP,
        tooltip: 'Test file upload over sftp',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
