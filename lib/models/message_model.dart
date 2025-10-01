import 'package:uuid/uuid.dart';

enum MessageType { text, voice, weather, reminder, calculation, error }

enum MessageSender { user, ai, system }

class MessageModel {
  final String id;
  final String content;
  final MessageSender sender;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  MessageModel({
    String? id,
    required this.content,
    required this.sender,
    this.type = MessageType.text,
    DateTime? timestamp,
    this.metadata,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  // Check if message is from user
  bool get isUser => sender == MessageSender.user;

  // Check if message is from AI
  bool get isAI => sender == MessageSender.ai;

  // Check if message is system message
  bool get isSystem => sender == MessageSender.system;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.name,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.system,
      ),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }

  // Create a copy with updated fields
  MessageModel copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    MessageType? type,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, content: $content, sender: $sender, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
