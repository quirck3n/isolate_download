// import 'dart:async';
// import 'dart:io';
// import 'dart:isolate';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:uuid/uuid.dart';

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
//   final IsolateTemplateMultiple _isolateTemplate = IsolateTemplateMultiple();
//   final TextEditingController _urlController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final List<String> _taskIds = [];

//   @override
//   void dispose() {
//     _isolateTemplate.kill();
//     _urlController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _startDownload() {
//     final String url = _urlController.text;
//     final String name = _nameController.text;
//     if (url.isNotEmpty && name.isNotEmpty) {
//       final IsolateMessageM message = IsolateMessageM(
//           id: const Uuid().v4(), url: url, name: name, savePath: "/");
//       final taskId = _isolateTemplate.addTask(message);
//       setState(() {
//         _taskIds.add(taskId);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Download Server Rust'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _urlController,
//               decoration: InputDecoration(labelText: 'URL'),
//             ),
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             ElevatedButton(
//               onPressed: _startDownload,
//               child: Text('Start Download'),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _taskIds.length,
//                 itemBuilder: (context, index) {
//                   final taskId = _taskIds[index];
//                   return FutureBuilder<bool>(
//                     future: _isolateTemplate.isDonloaded(taskId),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return ListTile(
//                           title: Text('Task $taskId'),
//                           subtitle: Text('Downloading...'),
//                         );
//                       } else if (snapshot.hasError || !snapshot.data!) {
//                         return ListTile(
//                           title: Text('Task $taskId'),
//                           subtitle: Text('Download failed'),
//                         );
//                       } else {
//                         return ListTile(
//                           title: Text('Task $taskId'),
//                           subtitle: Text('Download succeeded'),
//                         );
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class IsolateTemplateMultiple {
//   final Map<String, Completer<bool>> _downloadCompleters = {};
//   final Map<String, Isolate> _isolateList = {};

//   IsolateTemplateMultiple();

//   String addTask(IsolateMessageM message) {
//     final String id = message.id ?? const Uuid().v4();
//     Completer<bool> completer = Completer<bool>();
//     message.completer = completer;
//     _downloadCompleters[id] = completer;

//     _startIsolate(message);

//     return id;
//   }

//   void _startIsolate(IsolateMessageM message) async {
//     final ReceivePort receivePort = ReceivePort();
//     final Isolate isolate =
//         await Isolate.spawn(_downloadInIsolate, receivePort.sendPort);
//     _isolateList[message.id!] = isolate;
//     receivePort.listen((dynamic data) async {
//       if (data is double) {
//         // Progress update, do nothing for now
//       } else if (data is bool) {
//         // Download completion signal received
//         final Completer? completer = _downloadCompleters[message.id];
//         if (completer != null) {
//           completer.complete(data);
//         }
//       } else if (data is SendPort) {
//         Directory savePath2 = await getApplicationCacheDirectory();
//         // Download completion signal received
//         message.savePath = savePath2.path;
//         data.send(message);
//       }
//     });
//   }

//   static void _downloadInIsolate(SendPort sendPort) async {
//     final receivePort = ReceivePort();

//     sendPort.send(receivePort.sendPort);

//     receivePort.listen((dynamic data) async {
//       if (data is IsolateMessageM) {
//         final IsolateMessageM message = data;
//         final dio = Dio();

//         try {
//           await dio.download(
//               message.url, "${message.savePath}/${message.name}");
//           sendPort.send(true); // Signal download completion
//         } catch (e) {
//           sendPort.send(false); // Signal download failure
//         }
//       }
//     });
//   }

//   Future<bool> isDonloaded(String id) async {
//     return _downloadCompleters[id]?.future ?? Future<bool>.value(false);
//   }

//   void kill() {
//     _isolateList.forEach((key, value) {
//       value.kill(priority: Isolate.immediate);
//     });
//   }
// }

// class IsolateMessageM {
//   String? id;
//   final String url;
//   String savePath;
//   final String name;
//   Completer<bool>? completer;

//   IsolateMessageM({
//     this.id,
//     required this.url,
//     required this.savePath,
//     required this.name,
//   });
// }
