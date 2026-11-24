enum MessageSender {
  user,
  concierge,
  system,
}

class ChatMessageModel {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? suggestedActions;
  final String? relatedProductId;
  final String? relatedOrderId;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.suggestedActions,
    this.relatedProductId,
    this.relatedOrderId,
  });

  bool get isUser => sender == MessageSender.user;
  bool get isConcierge => sender == MessageSender.concierge;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: json['sender'] == 'user'
          ? MessageSender.user
          : (json['sender'] == 'system' ? MessageSender.system : MessageSender.concierge),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      suggestedActions: (json['suggested_actions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      relatedProductId: json['related_product_id'] as String?,
      relatedOrderId: json['related_order_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'suggested_actions': suggestedActions,
      'related_product_id': relatedProductId,
      'related_order_id': relatedOrderId,
    };
  }
}
