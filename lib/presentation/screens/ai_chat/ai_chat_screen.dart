import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/chat_message_model.dart';
import 'package:style_house/presentation/providers/ai_chat_provider.dart';
import 'package:style_house/presentation/providers/auth_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;
    _textController.clear();

    final tr = ref.read(localizationProvider);
    final user = ref.read(authProvider).user;
    final userId = user?.id ?? 'guest-shopper';

    ref.read(aiChatProvider.notifier).sendUserMessage(
          query: query,
          userId: userId,
          isKhmer: tr.isKhmer,
        );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final chatState = ref.watch(aiChatProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              isKhmer ? 'ជំនួយការផ្ទាល់ខ្លួន VIP' : 'FASHION CONCIERGE',
              style: isKhmer
                  ? AppTypography.titleMedium(isKhmer: isKhmer)
                  : const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'BKK1 Atelier • Online',
                  style: AppTypography.bodySmall(color: AppColors.luxuryBeigeDark),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Clear Chat',
            onPressed: () => ref.read(aiChatProvider.notifier).clearHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Stream
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return _buildMessageTile(message, isKhmer);
              },
            ),
          ),

          // Loading Typing Indicator
          if (chatState.isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.luxuryBeigeDark),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isKhmer ? 'ជំនួយការកំពុងឆ្លើយតប...' : 'Concierge is writing...',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: const BoxDecoration(
              color: AppColors.pureWhite,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: isKhmer ? 'សាកសួរអំពីទំនិញ ទំហំ ឬការដឹកជញ្ជូន...' : 'Ask about sizes, silk care, or delivery...',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: AppColors.canvasLinen,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryBlack,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: AppColors.pureWhite, size: 20),
                      onPressed: () => _sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(ChatMessageModel message, bool isKhmer) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlack,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.luxuryBeige, size: 16),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primaryBlack : AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isUser ? AppColors.primaryBlack : AppColors.borderLight,
                    ),
                  ),
                  child: SelectableText(
                    message.text,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: isUser ? AppColors.pureWhite : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Suggested Action Pills
          if (!isUser && message.suggestedActions != null && message.suggestedActions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.suggestedActions!.map((action) {
                  return ActionChip(
                    label: Text(action),
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                    backgroundColor: AppColors.canvasLinen,
                    side: const BorderSide(color: AppColors.borderLight),
                    onPressed: () => _sendMessage(action),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
