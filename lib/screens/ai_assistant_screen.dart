import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مساعد موجز الذكي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.chatMessages.length,
              itemBuilder: (context, index) {
                final msg = provider.chatMessages[index];
                final bool isAi = msg['role'] == 'ai';
                return Align(
                  alignment: isAi ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isAi ? AppColors.aiChatBubble : AppColors.primaryButton.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(20),
                        topLeft: const Radius.circular(20),
                        bottomLeft: isAi ? const Radius.circular(20) : Radius.zero,
                        bottomRight: isAi ? Radius.zero : const Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(
                        color: isAi ? AppColors.primaryBg : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'اسأل عن كتاب، مؤلف، أو فكرة...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppColors.inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      provider.sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  backgroundColor: AppColors.primaryButton,
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
