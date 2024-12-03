import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samadhan_chat/Views/Home/message_bubble.dart';
import 'package:samadhan_chat/auth/Bloc/auth_bloc.dart';
import 'package:samadhan_chat/auth/Bloc/auth_state.dart';
import 'package:samadhan_chat/auth/custom_auth_user.dart';
import 'package:samadhan_chat/chat/chat_bloc/chat_bloc.dart';
import 'package:samadhan_chat/chat/chat_bloc/chat_event.dart';
import 'package:samadhan_chat/chat/chat_bloc/chat_state.dart';
import 'package:samadhan_chat/chat/message.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late CustomAuthUser user;

  @override
  void initState() {
    super.initState();
    // Initialize user in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  void _initializeUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthStateLoggedIn) {
      // print('User ID: ${authState.user.id}');
      setState(() {
        user = authState.user;
      });
      context.read<ChatBloc>().add(LoadMessagesEvent(user.id));
    }
  }
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: 
       BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
            if (state is MessageSent) {
              _messageController.clear();
               WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
            }
          },
            buildWhen: (previous, current) {
            return current is! MessageSent;
            },
            builder: (context, chatState) {
                if (chatState is ChatLoaded) {
                  return Column(
                    children: [
                      Expanded(
                        child:StreamBuilder<List<Message>>(
                          stream: chatState.messages,
                          builder: (context, snapshot) {
                             if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final messages = snapshot.data!;
                                return ListView.builder(
                                  controller: _scrollController,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[index];
                                    return MessageBubble(message: message);
                                  },
                      );
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            );
          }
          if (chatState is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        },
      )
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                context.read<ChatBloc>().add(
                  SendMessageEvent(
                    userId: user.id,
                    message: _messageController.text,
                  ),
                );
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}