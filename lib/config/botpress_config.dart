/// Botpress **Chat API** uses: `https://chat.botpress.cloud/{webhookId}/...`
///
/// The in-Studio Emulator only checks your bot logic; this app talks to the
/// separate **Chat** HTTP API. You need the Chat integration installed and
/// this webhook id must match Chat’s Webhook URL (not Webchat-only).
///
/// In Botpress Studio: **Chat** integration → config → **Webhook URL**.
/// You can paste the **full URL** or **only the id** (last path segment).
///
/// Note: `webhook.botpress.cloud/...` and `chat.botpress.cloud/...` share the
/// same id; the app always calls `chat.botpress.cloud`.
///
/// **Flutter Web:** direct calls from the browser are usually blocked (CORS).
/// Use Android, iOS, Windows, or macOS builds for chat, or add a server-side proxy.
class BotpressConfig {
  /// Example full URL (works): https://webhook.botpress.cloud/c3eefb3b-...
  /// Example id only (works): c3eefb3b-66d9-4cf3-b497-81ca683ba37f
  static const String chatWebhookId =
      'https://webhook.botpress.cloud/b4d3a883-b4f7-48aa-bafe-e7013308f40f';
}
