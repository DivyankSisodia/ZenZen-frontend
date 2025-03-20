import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/features/dashboard/docs/view-model/doc_viewmodel.dart';
import 'package:zenzen/utils/common/custom_appbar.dart';
import 'package:zenzen/utils/theme.dart';
import 'package:intl/intl.dart';

import '../../../../config/constants/responsive.dart';
import '../../../../config/constants/size_config.dart';
import '../../home/widget/side_drawer_menu.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../widget/document_list_widget.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  const DocumentScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();
  final TextEditingController searchController = TextEditingController();

  // is grid view or list view
  bool isGridView = false;

  // Speech to text instance
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(docViewmodelProvider.notifier).getAllDocuments();
    });
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
          listenFor: const Duration(seconds: 30),
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
      searchController.text = _lastWords;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: drawerKey,
      drawer: SizedBox(
        width: SizeConfig.screenWidth / 2,
        child: Responsive.isMobile(context) ? const SideDrawerMenu() : null,
      ),
      appBar: CustomAppBar(drawerKey: drawerKey),
      body: SafeArea(
        child: Column(
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
                onTap: () {
                  debugPrint('Search field tapped');
                },
                onSubmitted: (value) {
                  debugPrint('Search submitted: $value');
                },
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                autofocus: false,
                autocorrect: true,
                controller: searchController,
                suffixMode: OverlayVisibilityMode.always,
                suffixIcon: Icon(
                  _isListening ? FontAwesomeIcons.stop : FontAwesomeIcons.microphone,
                  color: _isListening ? Colors.red : null,
                ),
                onSuffixTap: _startListening,
                suffixInsets: const EdgeInsets.only(right: 20),
                placeholder: 'Search',
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
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            width: double.infinity,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.lightGrey,
                                  Colors.grey[500]!,
                                  AppColors.primary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )),
                          // Document list
                          // Add document list here
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Document list',
                              style: AppTheme.textMedium(context),
                            ),
                          ),
                          Expanded(
                              child: Container(
                            width: double.infinity,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  Colors.grey[500]!,
                                  AppColors.lightGrey,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )),
                        ],
                      ),
                      //
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isGridView = !isGridView;
                            });
                          },
                          icon: isGridView ? Icon(Icons.list) : Icon(Icons.grid_view),
                        ),
                      ),

                      // show all the documents for the user

                      isGridView? Center(child: Text('GridView'),): DocumentListWidget()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

