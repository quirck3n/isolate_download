import 'package:flutter/material.dart';
import 'package:isolate_download/multi_isolate.dart';

void main() {
  runApp(MyApp());
}

const downList = [
  '1cem-arm64.apk',
  'AndFTP%20(your%20FTP%20client)_6.3_Apkpure.apk',
  'AnyDesk%20Remote%20Desktop_6.6.0_Apkpure.apk',
  'Quick%20Printer%20(ESC%20POS%20Print)_1.7.3%20%e2%80%94%20%d0%ba%d0%be%d0%bf%d0%b8%d1%8f.apk',
  'Quick%20Printer%20(ESC%20POS%20Print)_1.7.3.apk',
  'apk/ZFPLabServer_1.7.4.apk',
  'com.e1c.celmobile-arm.apk',
];

const String url = "http://192.168.1.100:8080/apk/";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download Server Rust',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _taskIds = [];
  final Map<String, String> _maps = {};
  final IsolateTemplateMultiple _isolateService = IsolateTemplateMultiple();
  var _interator = 0;

  void _startDownload() {
    var path = "/";
    final id = _isolateService.addTask(
        url + downList[_interator], path, downList[_interator]);
    _maps[id] = downList[_interator];
    _interator += 1;
    if (downList.length == _interator) {
      _interator = 0;
    }
    setState(() {
      _taskIds.add(id);
    });
    // if (url.isNotEmpty && name.isNotEmpty) {
    //   final IsolateMessageM message = IsolateMessageM(
    //       id: const Uuid().v4(), url: url, name: name, savePath: "/");
    //   final taskId = _isolateTemplate.addTask(message);
    //   setState(() {
    //     _taskIds.add(taskId);
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Server Rust'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _startDownload,
              child: const Text('Start Download'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _taskIds.length,
                itemBuilder: (context, index) {
                  final taskId = _taskIds[index];
                  return FutureBuilder<bool>(
                    future: _isolateService.isDownloaded(taskId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Task $taskId ${_maps[taskId]}'),
                          subtitle: const Text('Downloading...'),
                        );
                      } else if (snapshot.hasError || !snapshot.data!) {
                        return ListTile(
                          title: Text('Task $taskId ${_maps[taskId]}'),
                          subtitle: const Text('Download failed'),
                        );
                      } else {
                        return ListTile(
                          title: Text('Task $taskId ${_maps[taskId]}'),
                          subtitle: const Text('Download succeeded'),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
