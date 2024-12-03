import 'package:equatable/equatable.dart';
import '../message.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatError extends ChatState {
  const ChatError();
}

class ChatLoaded extends ChatState {
  final Stream<List<Message>> messages;
  
  const ChatLoaded(this.messages);
  
  @override
  List<Object?> get props => [messages];
}


class MessageSent extends ChatState {}
class MessageSending extends ChatState {}