import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../providers/user_session.dart';

// ============================================================
// CHAT STORAGE — historial por usuario
// ============================================================
class ChatStorage {
  static final Map<String, List<Map<String, String>>> _historials = {};

  static List<Map<String, String>> getMessages(String userId) {
    _historials[userId] ??= [];
    return _historials[userId]!;
  }

  static bool isEmpty(String userId) => getMessages(userId).isEmpty;

  static void addMessage(String userId, Map<String, String> message) {
    getMessages(userId).add(message);
  }

  static void clear(String userId) {
    _historials[userId] = [];
  }
}

// ============================================================
// CHAT SCREEN
// ============================================================
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  String get _userId => UserSession.userId ?? 'guest';

  static const String _groqApiKey = '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';
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static const String _systemPrompt = '''
Eres RealSteel AI, el asistente personal de entrenamiento de la app RealSteel. 
Tu función es ayudar a los usuarios con todo lo relacionado con:
- Rutinas y planes de entrenamiento personalizados
- Ejercicios específicos por grupo muscular
- Técnica correcta de ejercicios
- Nutrición deportiva y suplementación
- Recuperación y descanso
- Progresión y sobrecarga progresiva
- Motivación y consejos fitness

IMPORTANTE:
- Solo responde preguntas relacionadas con fitness, gimnasio, entrenamiento, nutrición deportiva y salud física.
- Si te preguntan algo fuera de estos temas, responde amablemente que solo puedes ayudar con temas de entrenamiento y fitness.
- Sé conciso, práctico y motivador.
- Usa el nombre del usuario cuando sea posible para personalizar las respuestas.
- Cuando generes rutinas, estructura la respuesta claramente con días, ejercicios, series y repeticiones.
- Responde siempre en español y cuando te hablen en ingles en ingles.
''';

  @override
  void initState() {
    super.initState();
    if (ChatStorage.isEmpty(_userId)) {
      ChatStorage.addMessage(_userId, {
        'role': 'assistant',
        'content': '¡Hola ${UserSession.nombre ?? 'campeón'}! 💪 Soy RealSteel AI, tu asistente personal de entrenamiento. Puedo ayudarte a crear rutinas personalizadas, resolver dudas sobre ejercicios, nutrición y mucho más. ¿En qué puedo ayudarte hoy?',
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      ChatStorage.addMessage(_userId, {'role': 'user', 'content': text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final List<Map<String, String>> apiMessages = [
        {'role': 'system', 'content': _systemPrompt},
        ...ChatStorage.getMessages(_userId).where((m) => m['role'] != 'system').toList(),
      ];

      debugPrint("=== GROQ enviando mensaje a: $_groqUrl");
      debugPrint("=== GROQ modelo: llama-3.3-70b-versatile");

      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile',
          'messages': apiMessages,
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      debugPrint("=== GROQ status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        setState(() {
          ChatStorage.addMessage(_userId, {'role': 'assistant', 'content': reply});
          _isLoading = false;
        });
      } else {
        debugPrint("=== GROQ ERROR: ${response.statusCode} — ${response.body}");
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("=== GROQ EXCEPTION: $e");
      setState(() {
        ChatStorage.addMessage(_userId, {
          'role': 'assistant',
          'content': 'Lo siento, ha ocurrido un error. Inténtalo de nuevo.',
        });
        _isLoading = false;
      });
    }

    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    final messages = ChatStorage.getMessages(_userId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/robotin.jpg',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("RealSteel AI",
                    style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 15)),
                Text("Asistente de entrenamiento",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.textSecondary),
            onPressed: () {
              setState(() => ChatStorage.clear(_userId));
              ChatStorage.addMessage(_userId, {
                'role': 'assistant',
                'content': '¡Hola ${UserSession.nombre ?? 'campeón'}! 💪 Chat reiniciado. ¿En qué puedo ayudarte?',
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == messages.length && _isLoading) {
                  return _TypingIndicator();
                }
                final msg = messages[i];
                final isUser = msg['role'] == 'user';
                return _MessageBubble(text: msg['content'] ?? '', isUser: isUser);
              },
            ),
          ),

          if (messages.length == 1) ...[
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _SuggestionChip("Crea una rutina para mí", _sendMessage),
                  _SuggestionChip("Ejercicios para pecho", _sendMessage),
                  _SuggestionChip("Dieta para ganar músculo", _sendMessage),
                  _SuggestionChip("Soy principiante", _sendMessage),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: AppColors.text),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Pregunta sobre entrenamiento...",
                      hintStyle: TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: _isLoading ? null : _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isLoading ? null : () => _sendMessage(_controller.text),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _isLoading ? AppColors.accentDark : AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BURBUJA DE MENSAJE
// ============================================================
class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _MessageBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/robotin.jpg',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.accent : AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? AppColors.white : AppColors.text,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  (UserSession.nombre ?? "U")[0].toUpperCase(),
                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// INDICADOR DE ESCRITURA
// ============================================================
class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    ));
    _animations = _controllers.map((c) => Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: c, curve: Curves.easeInOut),
    )).toList();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/robotin.jpg',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => AnimatedBuilder(
                animation: _animations[i],
                builder: (_, __) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.4 + _animations[i].value * 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUGERENCIA RÁPIDA
// ============================================================
class _SuggestionChip extends StatelessWidget {
  final String text;
  final Function(String) onTap;

  const _SuggestionChip(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.5)),
        ),
        child: Text(
          text,
          style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}