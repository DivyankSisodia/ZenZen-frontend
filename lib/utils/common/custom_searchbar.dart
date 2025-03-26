import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../config/constants/app_colors.dart';

class VoiceSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String placeholder;
  final TextEditingController? controller;
  final Function()? onTap;

  const VoiceSearchBar({
    super.key,
    required this.onSearch,
    this.placeholder = 'Search',
    this.controller,
    this.onTap,
  });

  @override
  State<VoiceSearchBar> createState() => _VoiceSearchBarState();
}

class _VoiceSearchBarState extends State<VoiceSearchBar> {
  late TextEditingController _searchController;
  
  // Speech to text instance
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _searchController = widget.controller ?? TextEditingController();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  // Initialize speech recognition
  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );
    if (!mounted) return;

    if (!available) {
      debugPrint("Speech recognition not available");
    }
  }

  // Listen for speech input
  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(seconds: 10),
          localeId: "en_US",
          cancelOnError: true,
          partialResults: true,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // Handle speech recognition status changes
  void _onSpeechStatus(String status) {
    debugPrint("Speech recognition status: $status");
    if (status == 'notListening') {
      setState(() => _isListening = false);
    }
  }

  // Handle speech recognition errors
  void _onSpeechError(dynamic error) {
    debugPrint("Speech recognition error: $error");
    setState(() => _isListening = false);
  }

  // Handle speech recognition results
  void _onSpeechResult(dynamic result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _searchController.text = _lastWords;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    // Only dispose the controller if we created it internally
    if (widget.controller == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CupertinoSearchTextField(
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontFamily: 'SpaceGrotesk',
            ),
            placeholderStyle: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontFamily: 'SpaceGrotesk',
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: widget.onTap,
            onSubmitted: widget.onSearch,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            autofocus: false,
            autocorrect: true,
            controller: _searchController,
            suffixMode: OverlayVisibilityMode.always,
            suffixIcon: Icon(
              _isListening ? FontAwesomeIcons.stop : FontAwesomeIcons.microphone,
              color: _isListening ? Colors.red : null,
            ),
            onSuffixTap: _startListening,
            suffixInsets: const EdgeInsets.only(right: 20),
            placeholder: widget.placeholder,
          ),
        ),
        if (_isListening)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Listening...",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}