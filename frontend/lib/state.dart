import 'dart:io';

import 'package:flutter/material.dart';

import 'connection/connection.dart';

class ConnectionNotifier extends ValueNotifier<Connection?> {
  ConnectionNotifier([super.value]);

  void _resetValue() {
    value?.disconnect();
    value = null;
  }

  @override
  void dispose() {
    value?.disconnect();
    super.dispose();
  }
}

class MessageNotifier extends ValueNotifier<String?> {
  MessageNotifier([super.value]);

  void setter(String? newValue) {
    value = newValue;
  }
}

class ConnectionProvider extends InheritedWidget {
  ConnectionProvider({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  final connectionNotifier = ConnectionNotifier();
  final messageNotifier = MessageNotifier();

  void addConnection(String url) async {
    final connection = Connection(
      url: url,
      onDisconnect: connectionNotifier._resetValue,
      onMessage: messageNotifier.setter,
    );
    try {
      await connection.connect();
    } on SocketException catch (error) {
      debugPrint(error.toString());
      return;
    }
    connectionNotifier.value = connection;
  }

  void sendMessage(String message) {
    connectionNotifier.value?.send(message);
  }

  void deleteConnection() {
    connectionNotifier._resetValue();
    messageNotifier.setter(null);
  }

  static ConnectionProvider of(BuildContext context) {
    final ConnectionProvider? result =
        context.dependOnInheritedWidgetOfExactType<ConnectionProvider>();
    assert(result != null, 'No ConnectionProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ConnectionProvider oldWidget) {
    connectionNotifier.value = oldWidget.connectionNotifier.value;
    messageNotifier.value = oldWidget.messageNotifier.value;
    return true;
  }
}
