import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:zenzen/features/dashboard/docs/repo/socket_repo.dart';

import '../../../../data/local/hive_models/local_user_model.dart';
import '../model/document_model.dart';

class DocumentEditor extends ConsumerStatefulWidget {
  final SocketRepository repository;
  final User? user;
  final String? documentId;
  final String? initialContent;

  const DocumentEditor({
    super.key,
    this.user,
    this.initialContent,
    this.documentId,
    required this.repository,
  });

  @override
  ConsumerState<DocumentEditor> createState() => _DocumentEditorState();
}

class _DocumentEditorState extends ConsumerState<DocumentEditor> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = true;
  Timer? _autoSaveTimer;
  StreamSubscription? _documentChangeSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    _initializeController();

    // Set up auto-save
    _setupAutoSave();
  }

  void _initializeController() {
    // Cancel existing subscription if it exists
    _documentChangeSubscription?.cancel();

    // Initialize controller
    try {
      final content = widget.initialContent ?? '';
      _controller = content.isNotEmpty
          ? quill.QuillController(
              document: quill.Document.fromJson(jsonDecode(content)),
              selection: const TextSelection.collapsed(offset: 0),
            )
          : quill.QuillController.basic();
    } catch (e) {
      _controller = quill.QuillController.basic();
    }

    // Setup socket listener
    widget.repository.onDocumentChange((data) {
      if (data != null && data['delta'] != null) {
        try {
          final delta = Delta.fromJson(data['delta']);
          _controller.compose(
            delta,
            _controller.selection,
            quill.ChangeSource.remote,
          );
        } catch (e) {
          print('Error parsing delta: $e');
        }
      } else {
        print('Received invalid data format: $data');
      }
    });

    // Listen for document changes
    _documentChangeSubscription = _controller.document.changes.listen((event) {
      if (event.source == quill.ChangeSource.local) {
        widget.repository.sendDocumentChanges({
          'delta': event.change.toJson(),
          'documentId': widget.documentId,
        });
      }
      if (_isEditing) {
        _autoSaveTimer?.cancel();
        _autoSaveTimer = Timer(const Duration(seconds: 10), _saveDocument);
      }
    });

    print('Controller initialized');
  }

  @override
  void didUpdateWidget(DocumentEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialContent != widget.initialContent) {
      // Dispose old controller before reinitializing
      _controller.dispose();
      _initializeController();
    }
  }

  void _setupAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isEditing) {
        _saveDocument();
      }
    });
  }

  void _saveDocument() {
    final json = jsonEncode(_controller.document.toDelta().toJson());
    widget.repository.autoSave({
      'documentId': widget.documentId,
      'delta': json,
    });
    print(json);
  }

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void dispose() {
    // Cancel document changes subscription
    _documentChangeSubscription?.cancel();

    // Dispose controller
    _controller.dispose();

    // Dispose other resources
    _focusNode.dispose();
    _autoSaveTimer?.cancel();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();

    // Remove socket listener
    widget.repository.removeDocumentChangeListener();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document #${widget.documentId}'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _saveDocument();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDocument,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isEditing)
            QuillSimpleToolbar(
              config: const QuillSimpleToolbarConfig(
                showAlignmentButtons: true,
                showBackgroundColorButton: true,
                showClearFormat: true,
                showColorButton: true,
                showFontFamily: true,
                showFontSize: true,
                showIndent: true,
                showInlineCode: true,
                showListCheck: true,
                showListBullets: true,
                showListNumbers: true,
                showQuote: true,
                showLink: true,
                showSearchButton: true,
                showCodeBlock: true,
                showStrikeThrough: true,
                showUnderLineButton: true,
                showDividers: true,
                showHeaderStyle: true,
                showSmallButton: false,
                showSubscript: true,
              ),
              controller: _controller,
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              margin: const EdgeInsets.all(16.0),
              child: QuillEditor(
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
                controller: _controller,
                config: QuillEditorConfig(
                  placeholder: 'Start writing your notes...',
                  padding: const EdgeInsets.all(16),
                  embedBuilders: [
                    ...FlutterQuillEmbeds.editorBuilders(
                      imageEmbedConfig: QuillEditorImageEmbedConfig(
                        imageProviderBuilder: (context, imageUrl) {
                          // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                          if (imageUrl.startsWith('assets/')) {
                            return AssetImage(imageUrl);
                          }
                          return null;
                        },
                      ),
                      videoEmbedConfig: QuillEditorVideoEmbedConfig(
                        customVideoBuilder: (videoUrl, readOnly) {
                          // To load YouTube videos https://github.com/singerdmx/flutter-quill/releases/tag/v10.8.0
                          return null;
                        },
                      ),
                    ),
                    TimeStampEmbedBuilder(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(
    String value,
  ) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}

// Example usage in your document list/browser
class DocumentBrowser extends StatelessWidget {
  final List<DocumentModel> documents;
  final Function(String) onDocumentOpen;

  const DocumentBrowser({
    super.key,
    required this.documents,
    required this.onDocumentOpen,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return ListTile(
          title: Text(doc.title),
          subtitle: Text('Last edited: ${doc.createdAt}'),
          onTap: () => onDocumentOpen(doc.id ?? ""),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}

// Document model for your app
// class DocumentModel {
//   final String id;
//   final String title;
//   final String lastEdited;
//   final String content;

//   DocumentModel({
//     required this.id,
//     required this.title,
//     required this.lastEdited,
//     required this.content,
//   });
// }
