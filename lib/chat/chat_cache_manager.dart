import 'package:samadhan_chat/chat/message.dart';

class ChatCacheManager {
  final Map<String, List<Message>> _userMessages = {};
  static const Duration cacheValidityDuration = Duration(hours: 1);
  DateTime? _lastUpdated;

  bool get needsRefresh => _lastUpdated == null || 
      DateTime.now().difference(_lastUpdated!) > cacheValidityDuration;

  List<Message> getCachedMessages(String userId) {
    return _userMessages[userId] ?? [];
  }

  void updateCache(String userId, List<Message> messages) {
    _userMessages[userId] = messages;
    _lastUpdated = DateTime.now();
  }

  void addMessage(String userId, Message message) {
    _userMessages[userId] ??= [];
    _userMessages[userId]!.add(message);
  }

  void clear(String userId) {
    _userMessages.remove(userId);
    _lastUpdated = null;
  }
}