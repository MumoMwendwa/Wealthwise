import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../services/botpress_chat_api.dart';
import '../services/financial_context_service.dart';

String _formatChatError(Object e) {
  final raw = e.toString();
  if (kIsWeb &&
      (raw.contains('Failed to fetch') ||
          raw.contains('ClientException') ||
          raw.contains('NetworkError'))) {
    return 'Chat cannot call Botpress from a web browser: the browser blocks '
        'cross-origin requests (CORS), so the API never reaches Botpress.\n\n'
        'What works:\n'
        '• Run the app on Android, iOS, Windows, or macOS (not Chrome/web).\n'
        '• Example: flutter run -d windows  or  flutter run -d android\n\n'
        'For web only, you would need your own backend proxy (same origin as your site).\n\n'
        'Technical: $raw';
  }
  return 'Could not reach the bot.\n\n$raw';
}

class ChatProvider extends ChangeNotifier {
  final BotpressChatApi _api = BotpressChatApi();

  List<Map<String, String>> messages = [];

  Future<void> sendMessage(String message) async {
    messages.add({
      'sender': 'user',
      'text': message,
    });
    notifyListeners();

    try {
      final snapshot = (await FinancialContextService.buildSnapshotForBot()).trim();
      final toSend = snapshot.isEmpty
          ? message
          : '[WealthWise user financial data — amounts in Ksh (Kenyan Shilling)]\n'
              '$snapshot\n\n'
              '[User question]\n'
              '$message';
      final botReply = await _api.sendUserMessage(toSend);
      messages.add({
        'sender': 'bot',
        'text': botReply,
      });
    } on BotpressConfigException catch (e) {
      messages.add({
        'sender': 'bot',
        'text': e.message,
      });
    } catch (e) {
      messages.add({
        'sender': 'bot',
        'text': _formatChatError(e),
      });
    }

    notifyListeners();
  }
}
