import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class IsolateTemplateMultiple {
  final Map<String, Completer<bool>> _downloadCompleters = {};
  final Map<String, Isolate> _isolateList = {};

  IsolateTemplateMultiple();

  String addTask(String url, String savePath, String name) {
    DownloadedObject message = _createMessage(url, savePath, name);
    _startIsolate(message);

    return message.id;
  }

  DownloadedObject _createMessage(String url, String savePath, String name) {
    return DownloadedObject(
      name: name,
      savePath: savePath,
      url: url,
      id: const Uuid().v4(),
      completer: Completer<bool>(),
    );
  }

  void _startIsolate(DownloadedObject message) async {
    _downloadCompleters[message.id] = message.completer;
    final ReceivePort receivePort = ReceivePort();
    final Isolate isolate =
        await Isolate.spawn(_downloadInIsolate, receivePort.sendPort);
    _isolateList[message.id] = isolate;
    receivePort.listen((dynamic data) async {
      if (data is double) {
        // Progress update, do nothing for now
      } else if (data is bool) {
        // Download completion signal received
        final Completer? completer = _downloadCompleters[message.id];
        if (completer != null) {
          killById(message.id);
          completer.complete(data);
        }
      } else if (data is SendPort) {
        Directory savePath2 = await getApplicationCacheDirectory();
        // Download completion signal received
        message.savePath = savePath2.path;
        data.send(PortMessage(
          name: message.name,
          savePath: message.savePath,
          url: message.url,
        ));
      }
    });
  }

  static void _downloadInIsolate(SendPort sendPort) async {
    final receivePort = ReceivePort();

    sendPort.send(receivePort.sendPort);

    receivePort.listen((dynamic data) async {
      if (data is PortMessage) {
        final PortMessage message = data;
        final dio = Dio();

        try {
          await dio.download(
              message.url, "${message.savePath}/${message.name}");
          sendPort.send(true); // Signal download completion
        } catch (e) {
          print(message.url);
          print(e);
          sendPort.send(false); // Signal download failure
        }
      }
    });
  }

  Future<bool> isDownloaded(String id) async {
    return _downloadCompleters[id]?.future ?? Future<bool>.value(false);
  }

  void killById(String id) {
    if (_isolateList.containsKey(id)) {
      var value = _isolateList[id];
      if (value != null) {
        value.kill(priority: Isolate.immediate);
      }
    }
  }

  void removeById(String id) {
    if (_downloadCompleters.containsKey(id)) {
      _downloadCompleters.remove(id);
    }
  }

  void kill() {
    _isolateList.forEach((key, value) {
      value.kill(priority: Isolate.immediate);
    });
  }
}

class PortMessage {
  String url;
  String savePath;
  String name;

  PortMessage({
    required this.url,
    required this.savePath,
    required this.name,
  });
}

class DownloadedObject {
  String id;
  final String url;
  String savePath;
  final String name;
  Completer<bool> completer;

  DownloadedObject({
    required this.id,
    required this.url,
    required this.savePath,
    required this.name,
    required this.completer,
  });
}
