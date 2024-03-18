class Message {
  final String text;
  final String senderId;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.senderId,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      senderId: json['senderId'],
      timestamp: json['timestamp'].toDate(),
    );
  }
}