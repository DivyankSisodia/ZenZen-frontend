import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class DocumentEditor extends StatefulWidget {
  final String? initialContent;
  final String documentId;
  final Function(String) onSave;

  const DocumentEditor({
    super.key,
    this.initialContent,
    required this.documentId,
    required this.onSave,
  });

  @override
  State<DocumentEditor> createState() => _DocumentEditorState();
}

class _DocumentEditorState extends State<DocumentEditor> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = true;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();

    // Initialize with content or empty document
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      try {
        final json = jsonDecode(widget.initialContent!);
        _controller = quill.QuillController(
          document: quill.Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Fallback to empty document if parsing fails
        _controller = quill.QuillController.basic();
      }
    } else {
      _controller = quill.QuillController.basic();
    }

    // Set up auto-save
    _setupAutoSave();

    // Listen for changes
    _controller.document.changes.listen((event) {
      if (_isEditing) {
        // Reset timer on each change
        _autoSaveTimer?.cancel();
        _autoSaveTimer = Timer(const Duration(seconds: 2), _saveDocument);
      }
    });
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
    widget.onSave(json);
  }

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _autoSaveTimer?.cancel();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
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
    Key? key,
    required this.documents,
    required this.onDocumentOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return ListTile(
          title: Text(doc.title),
          subtitle: Text('Last edited: ${doc.lastEdited}'),
          onTap: () => onDocumentOpen(doc.id),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}

// Document model for your app
class DocumentModel {
  final String id;
  final String title;
  final String lastEdited;
  final String content;

  DocumentModel({
    required this.id,
    required this.title,
    required this.lastEdited,
    required this.content,
  });
}
