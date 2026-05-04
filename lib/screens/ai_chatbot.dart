import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wealthwise/providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final provider = Provider.of<ChatProvider>(context, listen: false);
    provider.sendMessage(text);
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Wealthwise_backg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chat, _) {
                    return ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(12),
                      itemCount: chat.messages.length,
                      itemBuilder: (context, i) {
                        final msg = chat.messages[i];
                        final isUser = msg['sender'] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[600] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg['text'] ?? '',
                              style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'Ask about saving, budgets, expenses...',
                            hintStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    IconButton(onPressed: _send, icon: const Icon(Icons.send))
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}