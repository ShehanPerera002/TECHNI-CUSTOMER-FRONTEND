import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  static const Map<String, String> _allowedServiceRoutes = {
    '/find_plumber': 'Plumbing Services',
    '/find_electrician': 'Electrical Services',
    '/find_carpenter': 'Carpentry Services',
    '/find_gardener': 'Gardening Services',
    '/find_painter': 'Painting Services',
    '/find_ac_tech': 'AC Services',
    '/find_elv': 'ELV Services',
  };

  // ✅ SYSTEM PROMPT - Instructions for the AI
  static const _systemPrompt = '''
Role: You are 'Techni-Worker' AI, a very friendly, kind, and professional home maintenance expert.
Available Workers: AC Technicians, Plumbers, Carpenters, Gardeners, Painters, Electricians, ELV Repairers.

Behavior Guidelines:
1. PERSONALITY: Be warm and welcoming. 
2. LANGUAGE: If Sinhala input, reply in natural Sinhala. If English, use friendly English.
3. CLARIFICATION: If issue is unclear, ask follow-up questions.
4. IMAGE ANALYSIS: If image exists, analyze it carefully and helpfully.
5. GOAL: Only when sure about repair, provide worker and route.

STRICT JSON FORMAT (Return ONLY the JSON):
{
  "chat_response": "Your warm message here",
  "pro": "Worker Name OR 'none'",
  "route": "/find_ac_tech OR /find_plumber OR /find_carpenter OR /find_gardener OR /find_painter OR /find_electrician OR /find_elv OR 'none'",
  "status": "completed OR ask_more"
}
''';

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final List<_ChatMessage> _messages = <_ChatMessage>[
    const _ChatMessage(
      text: 'Hello! I am TECHNI AI. Tell me your home issue and I will help you find the right worker.',
      isUser: false,
    ),
  ];

  bool _isSending = false;
  XFile? _selectedImage;
  String? _lastIssueText;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;
    setState(() => _selectedImage = picked);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    final image = _selectedImage;
    if (text.isEmpty && image == null) return;
    if (_isSending) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text.isEmpty ? 'Image attached' : text,
          isUser: true,
          imageFile: image != null ? File(image.path) : null,
        ),
      );
      _controller.clear();
      _selectedImage = null;
      _isSending = true;
      _lastIssueText = text;
    });
    _scrollToBottom();

    try {
      final aiData = await _askGemini(message: text, image: image);
      
      final chatResponse = (aiData['chat_response'] ?? 'Sorry, I couldn\'t process that.').toString();
      final status = (aiData['status'] ?? 'ask_more').toString();
      final route = (aiData['route'] ?? 'none').toString();

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: chatResponse, isUser: false));
      });
      _scrollToBottom();

      if (status == 'completed' && route != 'none') {
        if (_allowedServiceRoutes.containsKey(route)) {
          _navigateToMatchedService(route);
        } else {
          setState(() {
            _messages.add(
              const _ChatMessage(
                text: 'I can only route to supported services. Please describe your issue a bit more.',
                isUser: false,
              ),
            );
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('[AIChat] Error: $e');
      if (!mounted) return;
      setState(() {
        _messages.add(const _ChatMessage(text: 'I am having trouble connecting. Please check your internet or API key.', isUser: false));
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ✅ UPDATED GEMINI API CALL (Direct Frontend)
  Future<Map<String, dynamic>> _askGemini({required String message, XFile? image}) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim();
    debugPrint('[AIChat] GEMINI_API_KEY present: ${apiKey != null && apiKey.isNotEmpty}');
    if (apiKey == null || apiKey.isEmpty) throw Exception('API Key not found in .env');

    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

    List<Map<String, dynamic>> parts = [];
    
    // 1. Add Image if exists (Inline Data must come before text in some cases)
    if (image != null) {
      final bytes = await image.readAsBytes();
      parts.add({
        "inline_data": {
          "mime_type": "image/jpeg",
          "data": base64Encode(bytes)
        }
      });
    }

    // 2. Add Prompt
    parts.add({
      "text": "$_systemPrompt\n\nUser Input: ${message.isEmpty ? 'Analyze this image.' : message}"
    });

    final payload = {
      "contents": [{"parts": parts}],
      "generationConfig": {
        "responseMimeType": "application/json",
      }
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    debugPrint('[AIChat] Gemini response status: ${response.statusCode}');
    if (response.statusCode != 200) {
      debugPrint('[AIChat] Gemini error body: ${response.body}');
      throw Exception('Gemini Error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final String rawAiText = data['candidates'][0]['content']['parts'][0]['text'];

    return _decodeAiJson(rawAiText);
  }

  Map<String, dynamic> _decodeAiJson(String rawText) {
    try {
      // Clean potential markdown formatting
      String clean = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(clean);
    } catch (e) {
      return {
        "chat_response": rawText,
        "pro": "none",
        "route": "none",
        "status": "ask_more"
      };
    }
  }

  void _navigateToMatchedService(String route) {
    if (!mounted) return;
    if (!_allowedServiceRoutes.containsKey(route)) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.pushNamed(context, route, arguments: _lastIssueText);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep your existing UI Build method exactly as it was
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('TECHNI AI', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i]),
            ),
          ),
          if (_selectedImage != null) _buildImagePreview(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Image.file(File(_selectedImage!.path), width: 50, height: 50, fit: BoxFit.cover),
          const SizedBox(width: 10),
          const Text("Image selected"),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedImage = null)),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF007AFF) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.imageFile != null) Image.file(message.imageFile!, width: 150),
            Text(message.text, style: TextStyle(color: isUser ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.camera_alt), onPressed: _pickImage),
          Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Describe your issue..."))),
          IconButton(
            icon: _isSending ? const CircularProgressIndicator() : const Icon(Icons.send, color: Color(0xFF007AFF)),
            onPressed: _isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final File? imageFile;
  const _ChatMessage({required this.text, required this.isUser, this.imageFile});
}