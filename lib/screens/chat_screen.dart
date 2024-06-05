import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  ChatScreen({required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late Box<Message> _messagesBox;

  @override
  void initState() {
    super.initState();
    _openMessagesBox();
  }

  Future<void> _openMessagesBox() async {
    _messagesBox = await Hive.openBox<Message>('messages');
    setState(() {});
  }

  void _sendMessage(String content) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final senderId = authProvider.userId;
    final message = Message(
      id: DateTime.now().toString(),
      senderId: senderId,
      receiverId: widget.receiverId,
      content: content,
      timestamp: DateTime.now(),
    );
    _messagesBox.add(message);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.userId;

    if (_messagesBox == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final messages = _messagesBox.values.where((msg) =>
      (msg.senderId == currentUserId && msg.receiverId == widget.receiverId) ||
      (msg.senderId == widget.receiverId && msg.receiverId == currentUserId)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message.content),
                  subtitle: Text(message.timestamp.toString()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
