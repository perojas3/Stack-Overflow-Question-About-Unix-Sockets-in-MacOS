import 'dart:typed_data';

const lengthOffset = 4;

List<Uint8List> parseMessages(Uint8List rawMessages) {
  final messages = <Uint8List>[];
  var remainingMessages = rawMessages;

  while (remainingMessages.length >= lengthOffset) {
    final nextMessageLength = getNextMessageLength(remainingMessages);

    final nextMessage = remainingMessages.sublist(
      lengthOffset,
      lengthOffset + nextMessageLength,
    );
    messages.add(nextMessage);

    remainingMessages = remainingMessages.sublist(
      lengthOffset + nextMessageLength,
    );
  }
  return messages;
}

int getNextMessageLength(Uint8List rawMessage) {
  if (rawMessage.length < lengthOffset) {
    return 0;
  }

  final BytesBuilder buffer = BytesBuilder()
    ..add(rawMessage.sublist(0, lengthOffset));
  final length = ByteData.sublistView(buffer.toBytes()) //
      .getUint32(0, Endian.big);
  return length;
}
