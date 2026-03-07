import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/assets.dart';
import '../models/service_detail_data.dart';
import '../widgets/primary_button.dart';
import 'find_professional_screen.dart';

/// Reusable service detail page. Pass [service] with dynamic content
/// (title, description, pricing, CTA text).
class ServiceDetailScreen extends StatefulWidget {
  final ServiceDetailData service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _issueController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  File? _selectedImage;

  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isConvertingToText = false;
  Timer? _listenTimer;
  Timer? _convertingTimer;
  late AnimationController _waveController;
  String _textBeforeListening = '';
  static const _minConvertingDuration = Duration(milliseconds: 800);

  ServiceDetailData get service => widget.service;

  bool get _isFormValid =>
      _issueController.text.trim().isNotEmpty || _selectedImage != null;

  @override
  void initState() {
    super.initState();
    _issueController.addListener(() => setState(() {}));
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
          _listenTimer?.cancel();
          _clearConvertingState();
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
        _clearConvertingState();
      },
    );
    if (mounted) setState(() {});
  }

  void _clearConvertingState() {
    if (!_isConvertingToText) return;
    _convertingTimer?.cancel();
    _convertingTimer = Timer(_minConvertingDuration, () {
      if (mounted) setState(() => _isConvertingToText = false);
    });
  }

  @override
  void dispose() {
    _listenTimer?.cancel();
    _convertingTimer?.cancel();
    _waveController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechEnabled) return;

    if (_speechToText.isListening) {
      setState(() => _isConvertingToText = true);
      await _speechToText.stop();
      _listenTimer?.cancel();
      setState(() => _isListening = false);
    } else {
      _textBeforeListening = _issueController.text.trim();
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(partialResults: true),
      );

      setState(() => _isListening = true);

      _listenTimer = Timer(const Duration(seconds: 20), () {
        if (_speechToText.isListening) {
          if (mounted) setState(() => _isConvertingToText = true);
          _speechToText.stop();
        }
        if (mounted) setState(() => _isListening = false);
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords;
    final prefix = _textBeforeListening;
    final newText = prefix.isEmpty ? text : '$prefix $text';
    if (newText.isNotEmpty) {
      _issueController.text = newText;
      _issueController.selection =
          TextSelection.collapsed(offset: _issueController.text.length);
    }
    if (result.finalResult) {
      _clearConvertingState();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          service.pageTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeroImage(),
            const SizedBox(height: 24),
            Text(
              service.serviceTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service.fullDescription,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildIssueInput(),
            const SizedBox(height: 24),
            const Text(
              "Estimated Pricing",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildPricingCard(),
            const SizedBox(height: 32),
            PrimaryButton(
              text: service.ctaText,
              onPressed: _isFormValid
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FindProfessionalScreen(
                            serviceTitle: service.pageTitle,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
            if (!_isFormValid) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text(
                  "Please describe your issue and click the find button",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.amber.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        service.imagePath ?? AppAssets.welcomePage,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildIssueInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isListening ? const Color(0xFF2563EB) : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _issueController,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: "Describe your issue...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  isDense: true,
                ),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                _buildImagePreview(),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isListening) _buildVoiceAnimation(),
                  if (_isConvertingToText) _buildConvertingIndicator(),
                  IconButton(
                    icon: Icon(
                      Icons.mic,
                      color: _isListening
                          ? const Color(0xFF2563EB)
                          : _issueController.text.trim().isNotEmpty
                              ? const Color(0xFF2563EB)
                              : Colors.grey.shade600,
                    ),
                    onPressed: _speechEnabled ? _toggleListening : null,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      color: _selectedImage != null
                          ? const Color(0xFF2563EB)
                          : Colors.grey.shade600,
                    ),
                    onPressed: _pickImage,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isListening)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Listening... (max 20 seconds) • Tap mic to stop",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) return const SizedBox.shrink();
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            _selectedImage!,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black54,
            padding: const EdgeInsets.all(4),
            minimumSize: const Size(32, 32),
          ),
          onPressed: () {
            setState(() => _selectedImage = null);
          },
        ),
      ],
    );
  }

  Widget _buildConvertingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Converting to text...",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceAnimation() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final height = 8.0 + 12 * ((_waveController.value - 0.5).abs() * 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 4,
              height: 8 + (i % 2 == 0 ? height : 16 - height),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPricingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildPricingRow("Inspection fee", service.inspectionFee),
          const SizedBox(height: 12),
          _buildPricingRow("Hourly Rate", service.hourlyRate),
          const SizedBox(height: 12),
          _buildPricingRow("Materials", service.materials),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
