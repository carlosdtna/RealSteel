class ChatStorage {
  // Mapa por userId — cada usuario tiene su propio historial
  static final Map<String, List<Map<String, String>>> _historials = {};

  static List<Map<String, String>> getMessages(String userId) {
    _historials[userId] ??= [];
    return _historials[userId]!;
  }

  static bool isEmpty(String userId) {
    return getMessages(userId).isEmpty;
  }

  static void addMessage(String userId, Map<String, String> message) {
    getMessages(userId).add(message);
  }

  static void clear(String userId) {
    _historials[userId] = [];
  }
}