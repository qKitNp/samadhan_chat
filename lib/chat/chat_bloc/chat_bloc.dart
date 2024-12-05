import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samadhan_chat/chat/chat_bloc/chat_event.dart';
import 'package:samadhan_chat/chat/chat_bloc/chat_state.dart';
import 'package:samadhan_chat/chat/chat_cache_manager.dart';
import 'package:samadhan_chat/chat/chat_repository.dart';
import 'package:samadhan_chat/chat/gemini/gemini_service.dart';
import 'package:samadhan_chat/chat/message.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final GeminiService _geminiService;
  final ChatCacheService _cacheService;
  StreamSubscription<List<Message>>? _messageSubscription;
  String? _currentUserId;
  Timer? _syncTimer;
  Stream<List<Message>>? _messageStream;
  List<Message> _currentMessages = [];

 ChatBloc(this._repository, this._geminiService, this._cacheService) 
  : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<DeleteMessageEvent>(_onDeleteMessage);
    _setupPeriodicSync();

  }
   void _setupPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _backgroundSync(),
    );
  }
  Future<void> _backgroundSync() async {
    if (_currentUserId != null && _cacheService.needsSync(_currentUserId!)) {
      try {
        final messages = await _repository.getMessages(_currentUserId!).first;
        await _cacheService.cacheMessages(_currentUserId!, messages);
      } catch (e) {
        print('Background sync error: $e');
      }
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      // 1. Add user message with optimistic update
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: event.message,
        userId: event.userId,
        isBot: false,
        created_at: DateTime.now(),
      );
      _currentMessages.add(userMessage);
      
      emit(ChatLoaded(
        messageStream: _messageStream!,
        currentMessages: _currentMessages,
      ));

      // 2. Send to supabase 
      await _repository.sendMessage(event.userId, event.message, false);

      // Get AI response
      final aiResponse = await _geminiService.generateResponse(event.message);
      
      // Add AI message
      final aiMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: aiResponse,
        userId: event.userId,
        isBot: true,
        created_at: DateTime.now(),
      );
      _currentMessages.add(aiMessage);
            
      // Update cache and repository
      await _cacheService.cacheMessages(_currentUserId!, _currentMessages);
      await _repository.sendMessage(event.userId, aiResponse, true);

      emit(ChatLoaded(
        messageStream: _messageStream!,
        currentMessages: _currentMessages,
      ));
      emit(MessageSent());

    } catch (e) {
      print('Error sending message: $e');
      if (_currentMessages.isNotEmpty) {
        _currentMessages.removeLast();
        await _cacheService.cacheMessages(_currentUserId!, _currentMessages);
      }
      emit(const ChatError());
    }
  }

  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    try {
      _currentUserId = event.userId;
      
      // Get cached messages
      _currentMessages = _cacheService.getCachedMessages(event.userId);
      
      // Setup message stream
      _messageStream = _repository.getMessages(event.userId);

      // Emit initial state with cached messages if available
      if (_currentMessages.isNotEmpty) {
        emit(ChatLoaded(
          messageStream: _messageStream!,
          currentMessages: _currentMessages,
        ));
      } else {
        emit(ChatLoading());
      }

      // Setup stream subscription for real-time updates
      await _messageSubscription?.cancel();
      _messageSubscription = _messageStream!.listen(
        (messages) async {
          _currentMessages = messages;
          await _cacheService.cacheMessages(event.userId, messages);
          
          if (_currentUserId == event.userId && !emit.isDone) {
            emit(ChatLoaded(
              messageStream: _messageStream!,
              currentMessages: messages,
            ));
          }
        },
        onError: (error) {
          print('Stream error: $error');
          if (!emit.isDone) {
            emit(ChatLoaded(
              messageStream: _messageStream!,
              currentMessages: _currentMessages,
            ));
          }
        },
      );

    } catch (e) {
      print('Error loading messages: $e');
      if (!emit.isDone) {
        // Fallback to cached messages if available
        if (_currentMessages.isNotEmpty) {
          emit(ChatLoaded(
            messageStream: _messageStream!,
            currentMessages: _currentMessages,
          ));
        } else {
          emit(const ChatError());
        }
      }
    }
  }
  
  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatState> emit
  ) async {
    try {
      emit(ChatLoading());
      await _repository.deleteMessage(event.messageId);
      emit(MessageSent());
    } catch (e) {
      emit(const ChatError()); 
    }
  }

  @override
  Future<void> close() async {
    await _messageSubscription?.cancel();
    _syncTimer?.cancel();
    return super.close();
  }
}