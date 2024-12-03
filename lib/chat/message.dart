import 'package:flutter/foundation.dart';

@immutable
class Message {
  final String id;
  final String text;
  final String userId;
  final bool isBot;
  final DateTime time;
  final MessageType type;
  final Map<String, dynamic> metadata;
  
  // AI specific fields
  final double? confidence;
  final List<String>? references;
  final Map<String, dynamic>? aiContext;
  final String? intent;
  final Map<String, dynamic>? entities;
  
  // Media content
  final String? mediaUrl;
  final MediaType? mediaType;
  final Map<String, dynamic>? mediaMetadata;

  const Message({
    required this.id,
    required this.text,
    required this.userId,
    required this.isBot,
    required this.time,
    this.type = MessageType.text,
    this.metadata = const {},
    this.confidence,
    this.references,
    this.aiContext,
    this.intent,
    this.entities,
    this.mediaUrl,
    this.mediaType,
    this.mediaMetadata,
  });

  // Create from database record
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['message'],
      userId: json['user_id'],
      isBot: json['is_bot'] ?? false,
      time: DateTime.parse(json['created_at']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] ?? {},
      confidence: json['confidence']?.toDouble(),
      references: List<String>.from(json['references'] ?? []),
      aiContext: json['ai_context'],
      intent: json['intent'],
      entities: json['entities'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'] != null 
          ? MediaType.values.firstWhere(
              (e) => e.toString() == json['media_type'],
              orElse: () => MediaType.image,
            )
          : null,
      mediaMetadata: json['media_metadata'],
    );
  }

  // Convert to JSON for database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'user_id': userId,
      'is_bot': isBot,
      'timestamp': time.toIso8601String(),
      'type': type.toString(),
      'metadata': metadata,
      'confidence': confidence,
      'references': references,
      'ai_context': aiContext,
      'intent': intent,
      'entities': entities,
      'media_url': mediaUrl,
      'media_type': mediaType?.toString(),
      'media_metadata': mediaMetadata,
    };
  }

  // Create copy with modifications
  Message copyWith({
    String? text,
    Map<String, dynamic>? metadata,
    double? confidence,
    List<String>? references,
    Map<String, dynamic>? aiContext,
    String? intent,
    Map<String, dynamic>? entities,
  }) {
    return Message(
      id: id,
      text: text ?? this.text,
      userId: userId,
      isBot: isBot,
      time: time,
      type: type,
      metadata: metadata ?? this.metadata,
      confidence: confidence ?? this.confidence,
      references: references ?? this.references,
      aiContext: aiContext ?? this.aiContext,
      intent: intent ?? this.intent,
      entities: entities ?? this.entities,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      mediaMetadata: mediaMetadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum MessageType { text, image, file, audio, video, location }
enum MediaType { image, video, audio, document }

// Extension for time-related utilities
extension MessageTime on Message {
  bool get isRecent => 
      DateTime.now().difference(time) < const Duration(minutes: 5);

 String get messageTime {
    int hour = time.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    
    // Convert to 12-hour format
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    // Format minutes with leading zero if needed
    final minutes = time.minute.toString().padLeft(2, '0');
    
    return '$hour:$minutes $period';
  }
  String get fullMessageTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);
    if (messageDate == today) {
      return messageTime;
    } else if (messageDate == yesterday) {
      return 'Yesterday, $messageTime';
    } else if (now.difference(time).inDays < 7) {
      return '${_getWeekday(time.weekday)}, $messageTime';
    } else {
      return '${time.day}/${time.month}/${time.year}, $messageTime';
    }
  }
  String _getWeekday(int day) {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
  String get timeAgo {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

// Extension for AI-specific functionality
extension AIMessage on Message {
  bool get hasHighConfidence => confidence != null && confidence! > 0.8;
  bool get needsHumanReview => confidence != null && confidence! < 0.5;
  bool get hasContext => aiContext != null && aiContext!.isNotEmpty;
}