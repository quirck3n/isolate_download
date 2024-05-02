
// import 'dart:async';
// import 'dart:io';
// import 'dart:isolate';

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Download Server Rust',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final IsolateTemplate _isolateTemplate = IsolateTemplate(
//     savePath: "/",
//     url: "http://192.168.1.100:8080/apk/com.e1c.celmobile-arm.apk",
//     name: "com.e1c.celmobile-arm.apk",
//   );
//   int isDowload = -2;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _isolateTemplate.kill();
//     super.dispose();
//   }

//   void _startDownload() {
//     _isolateTemplate.init();
//     setState(() {
//       isDowload = -1;
//     });

//     reloadIcon();
//   }

//   Future<void> reloadIcon() async {
//     isDowload = await _isolateTemplate.isFileDownloaded ? 1 : 0;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Download Server Rust'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (isDowload == -1)
//               const CircularProgressIndicator()
//             else if (isDowload == -2)
//               Container()
//             else if (isDowload == 0)
//               const Icon(Icons.close)
//             else
//               const Icon(Icons.done),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _startDownload(),
//         tooltip: 'Start Download',
//         child: Icon(Icons.cloud_download),
//       ),
//     );
//   }
// }

// // class _IsolateMessage {
// //   final String url;
// //   final String savePath;

// //   _IsolateMessage(this.url, this.savePath);
// // }

// class IsolateTemplate {
//   final String url;
//   final String savePath;
//   final String name;
//   final ReceivePort _receivePort = ReceivePort();
//   Isolate? _isolate;
//   late Completer<bool> _downloadCompleter;

//   IsolateTemplate(
//       {required this.url, required this.savePath, required this.name}) {
//     _downloadCompleter = Completer<bool>();
//   }

//   void init() {
//     _startIsolate();
//   }

//   void _startIsolate() async {
//     _isolate = await Isolate.spawn(_downloadInIsolate, _receivePort.sendPort);
//     _receivePort.listen((dynamic data) async {
//       if (data is double) {
//         // Progress update, do nothing for now
//       } else if (data is bool) {
//         // Download completion signal received
//         _downloadCompleter.complete(data);
//       } else if (data is SendPort) {
//         Directory savePath2 = await getApplicationCacheDirectory();
//         // Download completion signal received
//         data.send(
//             _IsolateMessage(url: url, savePath: savePath2.path, name: name));
//       }
//     });
//   }

//   static void _downloadInIsolate(SendPort sendPort) async {
//     final receivePort = ReceivePort();

//     sendPort.send(receivePort.sendPort);

//     receivePort.listen((dynamic data) async {
//       if (data is _IsolateMessage) {
//         final _IsolateMessage message = data;
//         final dio = Dio();

//         try {
//           await dio.download(
//               message.url, "${message.savePath}+/+${message.name}");
//           sendPort.send(true); // Signal download completion
//         } catch (e) {
//           print('Error during download: $e');
//           sendPort.send(false); // Signal download failure
//         }
//       }
//     });
//   }

//   Future<bool> get isFileDownloaded async {
//     return _downloadCompleter.future;
//   }

//   void kill() {
//     _receivePort.close();
//     if (_isolate != null) {
//       _isolate!.kill(priority: Isolate.immediate);
//     }
//   }
// }

// class _IsolateMessage {
//   final String url;
//   final String savePath;
//   final String name;

//   _IsolateMessage(
//       {required this.url, required this.savePath, required this.name});
// }
