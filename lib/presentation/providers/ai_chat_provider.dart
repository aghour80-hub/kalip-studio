import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:style_house/data/models/chat_message_model.dart';
import 'package:style_house/data/services/ai_concierge_service.dart';
import 'package:style_house/data/services/n8n_webhook_service.dart';

class AiChatState {
  final List<ChatMessageModel> messages;
  final bool isLoading;
  final String? errorMessage;

  const AiChatState({
    required this.messages,
    this.isLoading = false,
    this.errorMessage,
  });

  AiChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final AiConciergeService _conciergeService;

  AiChatNotifier({AiConciergeService? conciergeService})
      : _conciergeService = conciergeService ?? AiConciergeService(),
        super(
          AiChatState(
            messages: [
              ChatMessageModel(
                id: 'welcome-001',
                text: 'Welcome to **KALIP studio Luxury Concierge**!\n\n'
                    'I am your dedicated fashion advisor at our Phnom Penh Atelier. '
                    'How may I assist you with sizes, Khmer silk care, stock availability, or delivery tracking today?',
                sender: MessageSender.concierge,
                timestamp: DateTime.now(),
                suggestedActions: const [
                  'Phnom Penh delivery policy',
                  'Khmer silk care instructions',
                  'Check stock on evening dresses',
                  'Where is my order?',
                ],
              ),
            ],
          ),
        );

  Future<void> sendUserMessage({
    required String query,
    required String userId,
    required bool isKhmer,
  }) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    final userMessage = ChatMessageModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      text: clean,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );

    try {
      final reply = await _conciergeService.sendMessage(
        userQuery: clean,
        userId: userId,
        isKhmer: isKhmer,
      );

      state = state.copyWith(
        messages: [...state.messages, reply],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to reach fashion concierge. Please try again.',
      );
    }
  }

  void clearHistory() {
    state = const AiChatState(messages: []);
  }
}

final aiConciergeServiceProvider = Provider<AiConciergeService>((ref) {
  return AiConciergeService();
});

final n8nWebhookServiceProvider = Provider<N8nWebhookService>((ref) {
  return N8nWebhookService();
});

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final service = ref.watch(aiConciergeServiceProvider);
  return AiChatNotifier(conciergeService: service);
});
