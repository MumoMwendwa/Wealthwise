import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/botpress_config.dart';

const _kUserKey = 'bp_chat_user_key';
const _kChatUserId = 'bp_chat_user_id';
const _kConversationId = 'bp_chat_conversation_id';
const _kWebhookIdStored = 'bp_webhook_id_stored';

/// Chat API base is always `https://chat.botpress.cloud/{id}`.
/// Accepts either the raw id or a full URL (e.g. from webhook.botpress.cloud).
String normalizeBotpressWebhookId(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return '';
  if (s.startsWith('http://') || s.startsWith('https://')) {
    final uri = Uri.tryParse(s);
    if (uri == null) return s;
    final segments = uri.pathSegments.where((e) => e.isNotEmpty).toList();
    if (segments.isEmpty) return s;
    return segments.last;
  }
  return s;
}

class BotpressConfigException implements Exception {
  BotpressConfigException(this.message);
  final String message;
  @override
  String toString() => message;
}

bool _httpSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

String _bodyPreview(String body, [int max = 400]) {
  final t = body.trim();
  if (t.isEmpty) return '(empty)';
  return t.length <= max ? t : '${t.substring(0, max)}…';
}

/// [jsonDecode] throws on empty string; Botpress occasionally returns 2xx with no body.
Map<String, dynamic> _decodeJsonMap(String body, String where) {
  final t = body.trim();
  if (t.isEmpty) {
    throw Exception(
      'Botpress returned an empty response body ($where). '
      'Check the Chat integration and webhook id in Botpress Studio.',
    );
  }
  try {
    final decoded = jsonDecode(t);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw Exception('Botpress returned non-object JSON ($where): ${_bodyPreview(t)}');
  } on FormatException catch (e) {
    throw Exception(
      'Botpress returned invalid JSON ($where): $e\n${_bodyPreview(t)}',
    );
  }
}

/// [listMessages] may return 200 with an empty body in some edge cases; treat as no messages.
Map<String, dynamic> _decodeJsonMapOrEmptyMessages(String body, String where) {
  final t = body.trim();
  if (t.isEmpty) {
    return {
      'messages': <dynamic>[],
      'meta': <String, dynamic>{},
    };
  }
  return _decodeJsonMap(t, where);
}

class BotpressChatApi {
  String get _webhookId {
    final id = normalizeBotpressWebhookId(BotpressConfig.chatWebhookId);
    if (id.isEmpty) {
      throw BotpressConfigException(
        'Set BotpressConfig.chatWebhookId in lib/config/botpress_config.dart '
        '(Chat integration → Webhook URL in Botpress Studio).',
      );
    }
    return id;
  }

  String get _base => 'https://chat.botpress.cloud/$_webhookId';

  Future<void> _invalidateSessionIfWebhookChanged(SharedPreferences prefs) async {
    final current = _webhookId;
    final prev = prefs.getString(_kWebhookIdStored);
    if (prev != null && prev != current) {
      await prefs.remove(_kUserKey);
      await prefs.remove(_kChatUserId);
      await prefs.remove(_kConversationId);
    }
    await prefs.setString(_kWebhookIdStored, current);
  }

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<http.Response> _postCreateUser() {
    return http.post(
      Uri.parse('$_base/users'),
      headers: _jsonHeaders,
      body: jsonEncode({}),
    );
  }

  String _responseBodyString(http.Response res) {
    if (res.body.isNotEmpty) return res.body;
    if (res.bodyBytes.isEmpty) return '';
    return utf8.decode(res.bodyBytes, allowMalformed: true);
  }

  Future<void> _ensureSession(SharedPreferences prefs) async {
    await _invalidateSessionIfWebhookChanged(prefs);

    var userKey = prefs.getString(_kUserKey);
    var chatUserId = prefs.getString(_kChatUserId);
    var conversationId = prefs.getString(_kConversationId);

    if (userKey == null || chatUserId == null) {
      http.Response res = await _postCreateUser();
      if (!_httpSuccess(res.statusCode)) {
        throw Exception('Botpress createUser failed: ${res.statusCode} ${_bodyPreview(res.body)}');
      }
      var body = _responseBodyString(res);
      if (body.trim().isEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        res = await _postCreateUser();
        if (!_httpSuccess(res.statusCode)) {
          throw Exception('Botpress createUser failed (retry): ${res.statusCode} ${_bodyPreview(res.body)}');
        }
        body = _responseBodyString(res);
      }
      if (body.trim().isEmpty) {
        throw Exception(
          'Botpress createUser returned success (${res.statusCode}) but an empty body. '
          'The Studio Emulator only tests your flows in Studio; the app uses the Chat HTTP API (POST …/users). '
          'In Studio: Integrations → install Chat if needed → open Chat → copy the Webhook URL id into '
          'botpress_config.dart. Test from a PC: curl -sS -X POST $_base/users '
          '-H "Content-Type: application/json" -d "{}" '
          '(expect JSON with "key" and "user"). '
          'Bytes: ${res.bodyBytes.length}, headers: ${res.headers}',
        );
      }
      final data = _decodeJsonMap(body, 'createUser');
      userKey = data['key'] as String;
      chatUserId = (data['user'] as Map<String, dynamic>)['id'] as String;
      await prefs.setString(_kUserKey, userKey);
      await prefs.setString(_kChatUserId, chatUserId);
    }

    if (conversationId == null) {
      final res = await http.post(
        Uri.parse('$_base/conversations'),
        headers: {
          ..._jsonHeaders,
          'x-user-key': userKey,
        },
        body: jsonEncode({}),
      );
      if (!_httpSuccess(res.statusCode)) {
        throw Exception('Botpress createConversation failed: ${res.statusCode} ${res.body}');
      }
      final data = _decodeJsonMap(res.body, 'createConversation');
      conversationId =
          (data['conversation'] as Map<String, dynamic>)['id'] as String;
      await prefs.setString(_kConversationId, conversationId);
    }
  }

  Future<String> sendUserMessage(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureSession(prefs);

    final userKey = prefs.getString(_kUserKey)!;
    final chatUserId = prefs.getString(_kChatUserId)!;
    final conversationId = prefs.getString(_kConversationId)!;

    final sendRes = await http.post(
      Uri.parse('$_base/messages'),
      headers: {
        ..._jsonHeaders,
        'x-user-key': userKey,
      },
      body: jsonEncode({
        'conversationId': conversationId,
        'payload': {
          'type': 'text',
          'text': text,
        },
      }),
    );

    if (!_httpSuccess(sendRes.statusCode)) {
      throw Exception('Botpress send message failed: ${sendRes.statusCode} ${sendRes.body}');
    }

    final sendData = _decodeJsonMap(sendRes.body, 'createMessage');
    final userMsg = sendData['message'] as Map<String, dynamic>;
    final userCreated = DateTime.parse(userMsg['createdAt'] as String);
    final userMessageId = userMsg['id'] as String;

    return _pollBotReply(
      conversationId: conversationId,
      userKey: userKey,
      chatUserId: chatUserId,
      userMessageId: userMessageId,
      after: userCreated,
    );
  }

  /// Lists all messages by following [meta.nextToken] (first page alone can miss new replies).
  Future<List<Map<String, dynamic>>> _listAllMessages({
    required String conversationId,
    required String userKey,
  }) async {
    final all = <Map<String, dynamic>>[];
    String? nextToken;

    for (var page = 0; page < 50; page++) {
      final uri = Uri.parse('$_base/conversations/$conversationId/messages').replace(
        queryParameters: nextToken != null && nextToken.isNotEmpty
            ? {'nextToken': nextToken}
            : null,
      );
      final listRes = await http.get(uri, headers: {'x-user-key': userKey});
      if (!_httpSuccess(listRes.statusCode)) break;

      final listData = _decodeJsonMapOrEmptyMessages(listRes.body, 'listMessages');
      final raw = listData['messages'];
      if (raw is List<dynamic>) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) all.add(item);
        }
      }
      final meta = listData['meta'];
      if (meta is! Map<String, dynamic>) break;
      nextToken = meta['nextToken'] as String?;
      if (nextToken == null || nextToken.isEmpty) break;
    }
    return all;
  }

  bool _isIncomingBotMessage(
    Map<String, dynamic> item, {
    required String chatUserId,
    required String userMessageId,
  }) {
    final id = item['id'] as String?;
    if (id == userMessageId) return false;

    final uid = item['userId'] as String?;
    return uid != null && uid != chatUserId;
  }

  Future<String> _pollBotReply({
    required String conversationId,
    required String userKey,
    required String chatUserId,
    required String userMessageId,
    required DateTime after,
  }) async {
    const attempts = 60;
    const delay = Duration(milliseconds: 500);

    for (var i = 0; i < attempts; i++) {
      if (i > 0) await Future<void>.delayed(delay);

      final raw = await _listAllMessages(
        conversationId: conversationId,
        userKey: userKey,
      );
      if (raw.isEmpty) continue;

      Map<String, dynamic>? best;
      DateTime? bestTime;

      for (final item in raw) {
        if (!_isIncomingBotMessage(
          item,
          chatUserId: chatUserId,
          userMessageId: userMessageId,
        )) {
          continue;
        }

        final createdAt = DateTime.tryParse(item['createdAt'] as String? ?? '');
        if (createdAt == null) continue;

        // Include same-millisecond replies; exclude anything strictly before our message.
        if (createdAt.isBefore(after)) continue;

        if (bestTime == null || createdAt.isBefore(bestTime)) {
          bestTime = createdAt;
          best = item;
        }
      }

      if (best != null) {
        final payload = best['payload'];
        final extracted = _textFromPayload(payload);
        if (extracted != null && extracted.isNotEmpty) return extracted;
      }
    }

    return 'The bot did not reply in time. Try again.';
  }

  String? _textFromPayload(dynamic payload) {
    if (payload is! Map<String, dynamic>) return null;
    final type = payload['type'] as String?;
    switch (type) {
      case 'text':
        return payload['text'] as String?;
      case 'markdown':
        return payload['markdown'] as String?;
      case 'choice':
      case 'dropdown':
        return payload['text'] as String?;
      default:
        return payload['text'] as String? ?? payload['markdown'] as String?;
    }
  }
}
