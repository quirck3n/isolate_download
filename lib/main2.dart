// import 'dart:async';
// import 'dart:io';
// import 'dart:isolate';

// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:uuid/uuid.dart';

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
//               message.url, "${message.savePath}+/+${message.name}");
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
