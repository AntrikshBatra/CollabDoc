import 'package:google_docs/clients/socket.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketRepository {
  final socket = SocketIOClient.instance.socket!;

  Socket get socketClient => socket;

  void joinRoom(String documentID) {
    socket.emit('join', documentID);
  }

  void typing(String documentID, Map<String, dynamic> data) {
    socket.emit("typing", {"room": documentID, "content": data});
  }

  void autoSave(Map<String, dynamic> data) {
    print(';;;;;;;;;;;;;;;;;;;;;');
    socket.emit("save", data);
  }

  void changeListener(Function(Map<String, dynamic>) func) {
    print("Changed");
    socket.on("changes", (data) {
      print("Received data: $data"); // Debugging log
      func(data);
    });
  }
}
