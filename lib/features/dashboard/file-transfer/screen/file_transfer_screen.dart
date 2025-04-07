// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io' show File, Platform, Process;
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/config/router/constants.dart';
import 'package:zenzen/utils/common/custom_textfield.dart';
import 'package:zenzen/utils/theme.dart';
import '../../docs/repo/socket_repo.dart';
import '../model/file_info_model.dart';
import '../model/file_transfer_model.dart';
import '../widget/dropzone_container.dart';

class FileTransferScreen extends ConsumerStatefulWidget {
  const FileTransferScreen({super.key});

  @override
  ConsumerState<FileTransferScreen> createState() => _FileTransferScreenState();
}

class _FileTransferScreenState extends ConsumerState<FileTransferScreen> {
  final TextEditingController _roomIdController = TextEditingController();
  String? _currentRoomId;
  bool _isConnected = false;
  final Map<String, FileTransferProgress> _incomingFiles = {};
  final Map<String, FileTransferProgress> _outgoingFiles = {};
  final Map<String, FileDisplayInfo> _receivedFiles = {};
  late SocketRepository _socketRepository;

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _socketRepository = SocketRepository();
    _connectToServer();
  }

  void _connectToServer() {
    setState(() {
      _isConnected = true;
    });

    _socketRepository.onUserJoined((userId) {
      _showSnackBar('User joined: $userId');
    });

    _socketRepository.onFileChunk((data) {
      _receiveFileChunk(data);
    });

    _socketRepository.onFileTransferComplete((data) {
      _completeFileTransfer(data);
    });

    _socketRepository.onFileTransferCancel((data) {
      _cancelFileTransfer(data);
    });
  }

  void _createRoom() {
    if (!_isConnected) {
      _showSnackBar('Not connected to server');
      return;
    }

    _socketRepository.createRoom(
      onSuccess: (roomId) {
        setState(() {
          _currentRoomId = roomId;
          _isConnected = true;
        });
        _showSnackBar('Room created: $roomId');
      },
      onError: (error) {
        _showSnackBar('Failed to create room: $error');
      },
    );
  }

  void _joinRoom() {
    if (!_isConnected) {
      _showSnackBar('Not connected to server');
      return;
    }

    final roomId = _roomIdController.text.trim();
    if (roomId.isEmpty) {
      _showSnackBar('Please enter a room ID');
      return;
    }

    _socketRepository.joinRoom(
      roomId,
      onSuccess: () {
        setState(() {
          _currentRoomId = roomId;
        });
        _showSnackBar('Joined room: $roomId');
      },
      onError: (error) {
        _showSnackBar('Failed to join room: $error');
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _cancelFileTransfer(Map<String, dynamic> data) {
    final fileId = data['fileId'] as String;
    final fileName = data['fileName'] as String;

    _incomingFiles.remove(fileId);
    _showSnackBar('File transfer cancelled: $fileName');
    setState(() {});
  }

  void _receiveFileChunk(dynamic data) {
    final String fileId = data['fileId'];
    final int chunkId = data['chunkId'];
    final String base64Chunk = data['chunk'];

    // Create new file tracker if first chunk
    if (!_incomingFiles.containsKey(fileId)) {
      _incomingFiles[fileId] = FileTransferProgress(
        fileName: data['fileName'],
        fileType: data['fileType'],
        totalChunks: data['totalChunks'],
        fileSize: 0, // Will be calculated as chunks arrive
        chunks: List.filled(data['totalChunks'], null),
      );
    }

    // Decode and store chunk
    final Uint8List chunk = base64Decode(base64Chunk);
    _incomingFiles[fileId]!.chunks[chunkId] = chunk;
    _incomingFiles[fileId]!.receivedChunks.add(chunkId);
    _incomingFiles[fileId]!.fileSize += chunk.length;

    setState(() {});
  }

  void _completeFileTransfer(dynamic data) {
    final String fileId = data['fileId'];
    final String fileName = data['fileName'];

    if (_incomingFiles.containsKey(fileId)) {
      _saveAndDisplayReceivedFile(fileId, fileName);
    }
  }

  Future<void> _saveAndDisplayReceivedFile(
      String fileId, String fileName) async {
    final progress = _incomingFiles[fileId]!;

    // Combine all chunks
    final BytesBuilder builder = BytesBuilder();
    for (Uint8List? chunk in progress.chunks) {
      if (chunk != null) {
        builder.add(chunk);
      }
    }
    final Uint8List fileData = builder.toBytes();

    String? filePath;
    if (kIsWeb) {
      filePath = await _saveFileWeb(fileName, fileData);
    } else {
      filePath = await _saveFileNative(fileName, fileData);
    }

    // Determine file type
    final fileType = fileName.split('.').last.toLowerCase();

    // Create FileDisplayInfo
    final displayInfo = FileDisplayInfo(
      fileName: fileName,
      filePath: filePath,
      fileType: fileType,
      fileData: fileData,
    );

    // Add to received files map
    _receivedFiles[fileId] = displayInfo;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File received: $fileName')),
    );
  }

  String? _lastSavedFilePath;

  Future<String> _saveFileNative(String fileName, Uint8List data) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    await File(filePath).writeAsBytes(data);
    _lastSavedFilePath = filePath;
    print('File saved to: $filePath');
    return filePath;
  }

  Future<String> _saveFileWeb(String fileName, Uint8List data) async {
    // Create a Blob from the file data
    final blob = html.Blob([data]);

    // Create a download link and trigger download
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    // Clean up the URL
    html.Url.revokeObjectUrl(url);

    // Set the last saved file details for web
    _lastSavedFilePath = fileName;

    print('File downloaded: $fileName');

    return _lastSavedFilePath!;
  }

  Future<void> _pickAndSendFiles() async {
    if (_currentRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create or join a room first')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.any,
    );

    if (result != null) {
      for (PlatformFile file in result.files) {
        _sendFile(file);
      }
    }
  }

  Future<void> _pickAndSendFolder() async {
    if (_currentRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create or join a room first')),
      );
      return;
    }

    // Check if we're running on web
    if (kIsWeb) {
      try {
        // For web, we need to use a different approach
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.any,
          withData: true,
        );

        if (result != null && result.files.isNotEmpty) {
          // Process the selected files directly
          for (var platformFile in result.files) {
            _sendFile(platformFile);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting files: $e')),
        );
      }
    } else {
      // Original code for mobile/desktop platforms
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final directory = Directory(selectedDirectory);
        await _sendFolder(directory);
      }
    }
  }

  Future<void> _sendFolder(Directory directory) async {
    try {
      // Only used for non-web platforms
      final files = await directory
          .list(recursive: true)
          .where((entity) => entity is File)
          .toList();

      for (var file in files) {
        if (file is File) {
          final platformFile = PlatformFile(
            name: path.basename(file.path),
            path: file.path,
            size: await file.length(),
            bytes: await file.readAsBytes(),
          );
          _sendFile(platformFile);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending folder: $e')),
      );
    }
  }

  void _sendFile(PlatformFile file) async {
    final fileId = const Uuid().v4();
    final fileSize = file.size;
    const chunkSize = 32 * 1024; // 32KB chunks
    final totalChunks = (fileSize / chunkSize).ceil();

    // Create progress tracker
    _outgoingFiles[fileId] = FileTransferProgress(
      fileName: file.name,
      fileType: file.extension ?? 'unknown',
      totalChunks: totalChunks,
      fileSize: fileSize,
    );

    setState(() {});

    Uint8List? fileBytes;
    if (file.bytes != null) {
      fileBytes = file.bytes!;
    } else if (file.path != null) {
      fileBytes = await File(file.path!).readAsBytes();
    }

    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read file: ${file.name}')),
      );
      return;
    }

    // Send file in chunks
    for (int i = 0; i < totalChunks; i++) {
      final start = i * chunkSize;
      final end = min(start + chunkSize, fileSize);
      final chunk = fileBytes.sublist(start, end);

      // Encode chunk to base64 for transmission
      final base64Chunk = base64Encode(chunk);

      // Match the structure expected by the server
      _socketRepository.sendFileChunk({
        'roomId': _currentRoomId,
        'fileName': file.name,
        'fileType': file.extension,
        'chunk': base64Chunk,
        'chunkId': i,
        'totalChunks': totalChunks,
        'fileId': fileId,
      });

      // Update progress
      _outgoingFiles[fileId]!.receivedChunks.add(i);
      setState(() {});

      // Small delay to prevent flooding
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Notify transfer completion - match server structure
    // _socket.emit('file_transfer_complete', {
    //   'roomId': _currentRoomId,
    //   'fileId': fileId,
    //   'fileName': file.name,
    // });

    _socketRepository.sendFileTransferComplete({
      'roomId': _currentRoomId,
      'fileId': fileId,
      'fileName': file.name,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File sent: ${file.name}')),
    );
  }

  Future<void> openSavedFile() async {
    if (_lastSavedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file has been saved yet')),
      );
      return;
    }

    print('Opening saved file: $_lastSavedFilePath');

    if (kIsWeb) {
      // Re-trigger the download for web
      final fileToRedownload = _incomingFiles.values.firstWhere(
        (file) => file.fileName == _lastSavedFilePath,
        orElse: () => throw Exception('File not found in incoming files'),
      );

      print(fileToRedownload);
      final BytesBuilder builder = BytesBuilder();
      for (Uint8List? chunk in fileToRedownload.chunks) {
        if (chunk != null) {
          builder.add(chunk);
        }
      }
      final Uint8List fileData = builder.toBytes();

      // Create a Blob and trigger download
      final blob = html.Blob([fileData]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', _lastSavedFilePath!)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Use platform-specific methods for non-web platforms
      await _openSavedFileLocation(_lastSavedFilePath!);
    }
  }

  Future<void> _openSavedFileLocation(String filePath) async {
    print('Opening file: $filePath');

    // Check if running on web
    if (kIsWeb) {
      _showFileError('File operations not supported on web');
      return;
    }

    try {
      final file = File(filePath);

      // Check if the file exists
      if (!await file.exists()) {
        _showFileError('File not found');
        return;
      }

      // Platform-specific file opening
      if (Platform.isMacOS) {
        await _openOnMacOS(filePath);
      } else if (Platform.isWindows) {
        await _openOnWindows(filePath);
      } else if (Platform.isLinux) {
        await _openOnLinux(filePath);
      } else if (Platform.isAndroid || Platform.isIOS) {
        await _openOnMobile(filePath);
      } else {
        // Fallback method
        await _openWithOpenFile(filePath);
      }
    } catch (e) {
      _showFileError('Error opening file: $e');
    }
  }

  Future<void> _openOnMacOS(String filePath) async {
    print('Opening file on macOS: $filePath');
    try {
      await Process.run('open', ['-R', filePath]);
    } catch (e) {
      await _openWithOpenFile(filePath);
    }
  }

  Future<void> _openOnWindows(String filePath) async {
    try {
      await Process.run('explorer', ['/select,', filePath]);
    } catch (e) {
      await _openWithOpenFile(filePath);
    }
  }

  Future<void> _openOnLinux(String filePath) async {
    try {
      await Process.run('xdg-open', [path.dirname(filePath)]);
    } catch (e) {
      await _openWithOpenFile(filePath);
    }
  }

  Future<void> _openOnMobile(String filePath) async {
    await _openWithOpenFile(filePath);
  }

  Future<void> _openWithOpenFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }

  void _showFileError(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_currentRoomId != null) {
      _socketRepository.leaveRoom(_currentRoomId!);
    }
    _roomIdController.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Received files: ${_receivedFiles.keys}');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              context.goNamed(RoutesName.home);
              // context.pop();
            },
            icon: const Icon(Icons.arrow_back)),
        automaticallyImplyLeading: true,
        title: const Text('File Transfer App'),
        actions: [
          Container(
            margin: const EdgeInsets.all(15),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentRoomId == null)
              Center(
                child: Card(
                  elevation: 5,
                  shadowColor: Colors.grey[700],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _createRoom,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            shadowColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                          ),
                          child: Text(
                            'Create Room',
                            style: AppTheme.textLarge(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('OR'),
                        const SizedBox(height: 16),
                        CustomTextField(
                            controller: _roomIdController,
                            focusNode: focusNode,
                            hint: 'Enter Room Id'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _joinRoom,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            shadowColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                          ),
                          child: Text(
                            'Join Room',
                            style: AppTheme.textLarge(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Card(
                elevation: 5,
                color: AppColors.background,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Room: $_currentRoomId',
                        style: AppTheme.textSmall(context),
                      ),
                      const SizedBox(height: 16),
                      DragDropContainer(
                        onTap: _pickAndSendFiles,
                        onSendFile: _sendFile,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _pickAndSendFiles,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shadowColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.upload_file),
                                const SizedBox(width: 8),
                                Text(
                                  'Upload Files',
                                  style: AppTheme.textLarge(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _pickAndSendFolder,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shadowColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.folder),
                                const SizedBox(width: 8),
                                Text(
                                  'Upload Folder',
                                  style: AppTheme.textLarge(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentRoomId = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shadowColor: Colors.grey[700],
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                        child: Text('Leave Room',
                            style: AppTheme.textLarge(context)),
                      ),
                    ],
                  ),
                ),
              ),
            if (_receivedFiles.isNotEmpty) ...[
              Text('Received Files', style: AppTheme.largeBodyTheme(context)),
              const SizedBox(height: 15),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _receivedFiles.length,
                  itemBuilder: (context, index) =>
                      _buildFileDisplay(_receivedFiles.values.elementAt(index)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_incomingFiles.isNotEmpty || _outgoingFiles.isNotEmpty) ...[
              Text(
                'File Transfers',
                style: AppTheme.largeBodyTheme(context),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView(
                  children: [
                    ..._outgoingFiles.entries.map((entry) {
                      final progress = entry.value;
                      final percentage = (progress.receivedChunks.length /
                              progress.totalChunks *
                              100)
                          .toStringAsFixed(1);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(progress.fileName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (progress.receivedChunks.length /
                                      progress.totalChunks <
                                  1)
                                Row(
                                  children: [
                                    CircularProgressIndicator(
                                      value: progress.receivedChunks.length /
                                          progress.totalChunks,
                                      strokeWidth: 4,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        '${progress.receivedChunks.length / progress.totalChunks * 100}%'),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'File sent',
                                      style: TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          leading: Icon(
                            progress.receivedChunks.length /
                                        progress.totalChunks <
                                    1
                                ? Icons.upload_file
                                : Icons.done,
                            color: Colors.blueAccent,
                          ),
                        ),
                      );
                    }),
                    ..._incomingFiles.entries.map((entry) {
                      final progress = entry.value;
                      final percentage = (progress.receivedChunks.length /
                              progress.totalChunks *
                              100)
                          .toStringAsFixed(1);

                      return ListTile(
                        title: Text(progress.fileName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (progress.receivedChunks.length /
                                    progress.totalChunks <
                                1)
                              Row(
                                children: [
                                  CircularProgressIndicator(
                                    value: progress.receivedChunks.length /
                                        progress.totalChunks,
                                    strokeWidth: 4,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      '${progress.receivedChunks.length / progress.totalChunks * 100}%'),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  const Text('File received',
                                      style: TextStyle(color: Colors.green)),
                                ],
                              ),
                          ],
                        ),
                        leading: const Icon(Icons.download_rounded),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileDisplay(FileDisplayInfo fileInfo) {
    // Check if file is an image
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          if (imageExtensions.contains(fileInfo.fileType))
            Image.memory(
              fileInfo.fileData,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            )
          else
            const Icon(
              Icons.insert_drive_file,
              size: 70,
              color: Colors.grey,
            ),
          const SizedBox(height: 8),
          Text(
            fileInfo.fileName,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
          ElevatedButton(
            onPressed: () => _openSavedFileLocation(fileInfo.filePath),
            child: Text('Open File', style: AppTheme.smallBodyTheme(context)),
          ),
        ],
      ),
    );
  }
}
