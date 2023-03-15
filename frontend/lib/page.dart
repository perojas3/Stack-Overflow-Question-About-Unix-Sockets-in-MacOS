import 'package:flutter/material.dart';
import 'package:frontend/connection/connection.dart';
import 'package:frontend/state.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectionProvider(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        home: const Scaffold(body: PageDecider()),
      ),
    );
  }
}

class PageDecider extends StatelessWidget {
  const PageDecider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = ConnectionProvider.of(context);
    return ValueListenableBuilder<Connection?>(
      valueListenable: provider.connectionNotifier,
      builder: (BuildContext context, Connection? value, _) {
        if (value == null) {
          return RequestUrl(addConnection: provider.addConnection);
        } else {
          return ActivateConnection(
            disconnect: provider.deleteConnection,
            messageListenable: provider.messageNotifier,
            onSend: provider.sendMessage,
          );
        }
      },
    );
  }
}

class RequestUrl extends StatefulWidget {
  const RequestUrl({Key? key, required this.addConnection}) : super(key: key);

  final void Function(String) addConnection;

  @override
  State<RequestUrl> createState() => _RequestUrlState();
}

class _RequestUrlState extends State<RequestUrl> {
  TextEditingController controller = TextEditingController();

  void startConnection() {
    widget.addConnection(controller.text);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter backend url",
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 16.0)),
        OutlinedButton(
          onPressed: startConnection,
          child: const Text("Send"),
        )
      ],
    );
  }
}

class ActivateConnection extends StatelessWidget {
  const ActivateConnection({
    Key? key,
    required this.disconnect,
    required this.messageListenable,
    required this.onSend,
  }) : super(key: key);

  final VoidCallback disconnect;
  final ValueNotifier<String?> messageListenable;
  final void Function(String) onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: ValueListenableBuilder<String?>(
            valueListenable: messageListenable,
            builder: (BuildContext context, String? value, _) {
              if (value == null) {
                return const NoMessages();
              } else {
                return DisplayMessage(message: value);
              }
            },
          ),
        ),
        Flexible(child: SendMessage(onSend: onSend)),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: disconnect,
              child: const Text("Disconnect"),
            ),
          ),
        )
      ],
    );
  }
}

class NoMessages extends StatelessWidget {
  const NoMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        "No Messages Received",
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
      ),
    );
  }
}

class DisplayMessage extends StatelessWidget {
  const DisplayMessage({Key? key, required this.message}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        message,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

class SendMessage extends StatefulWidget {
  const SendMessage({Key? key, required this.onSend}) : super(key: key);

  final void Function(String) onSend;

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  TextEditingController controller = TextEditingController();

  void sendMessage(){
    final message = controller.text;
    widget.onSend(message);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Message",
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 16.0)),
          OutlinedButton(
            onPressed: sendMessage,
            child: const Text("Send"),
          )
        ],
      );
  }
}
