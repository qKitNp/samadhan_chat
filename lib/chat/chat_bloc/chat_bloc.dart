import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samadhan_chat/chat/chat_bloc/chat_event.dart';
import 'package:samadhan_chat/chat/chat_bloc/chat_state.dart';
import 'package:samadhan_chat/chat/chat_repository.dart';
import 'package:samadhan_chat/chat/gemini/gemini_service.dart';
import 'package:samadhan_chat/chat/message.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final GeminiService _geminiService;
  Stream<List<Message>>? _messageStream;

  ChatBloc(this._repository, this._geminiService) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<DeleteMessageEvent>(_onDeleteMessage);
  }

  void _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await _repository.sendMessage(event.userId, event.message, false);
      final aiResponse = await _geminiService.generateResponse(event.message);
      await _repository.sendMessage(event.userId, aiResponse, true);
      emit(MessageSent());
    } catch (e) {
      print('Error sending message: $e');
      emit(const ChatError());
    }
  }

  void _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    try {
      if (_messageStream == null) {
        emit(ChatLoading());
        _messageStream = _repository.getMessages(event.userId);
      }
      emit(ChatLoaded(_messageStream!));
    } catch (e) {
      print('Error on Loading message: $e');
      emit(const ChatError());
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
  
}