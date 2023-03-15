import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'message_communication.dart';

class Connection {
  String url;
  void Function(String message) onMessage;
  void Function() onDisconnect;
  Socket? _socket;

  Connection({
    required this.url,
    required this.onDisconnect,
    required this.onMessage,
  });

  connect() async {
    final path = InternetAddress(url, type: InternetAddressType.unix);
    final socket = await Socket.connect(path, 1);
    socket.listen(
      _listening,
      onError: _onError,
      onDone: _onDone,
    );
    _socket = socket;
  }

  _listening(Uint8List rawMessages) {
    final messages = parseMessages(rawMessages);
    for (final message in messages) {
      final textMessage = String.fromCharCodes(message);
      onMessage(textMessage);
    }
  }

  _onError(error) {
    _socket?.destroy();
  }

  _onDone() {
    _socket?.destroy();
  }

  Uint8List int32BigEndianBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

  void send(String message) {
    var buffer = utf8.encode(message);
    final lengthPrefix = Uint8List(4)
      ..buffer.asByteData().setInt32(0, buffer.length, Endian.big);
    _socket?.add(lengthPrefix);
    _socket?.write(message);
  }

  void disconnect() {
    _socket?.destroy();
  }
}
