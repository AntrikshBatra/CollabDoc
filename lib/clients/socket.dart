import 'dart:io';

import 'package:google_docs/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIOClient {
  IO.Socket? socket;
  static SocketIOClient? _instance;

  SocketIOClient._internal() {
    socket = IO.io(host, <String, dynamic>{
      'transport': [WebSocket],
      'autoconnect': [false]
    });
    socket!.connect();
  }

  static SocketIOClient get instance {
    _instance ??= SocketIOClient._internal();
    return _instance!;
  }
}
