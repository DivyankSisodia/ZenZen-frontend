import 'dart:typed_data';

class FileTransferProgress {
  final String fileName;
  final String fileType;
  final int totalChunks;
  int fileSize;
  final Set<int> receivedChunks = {};
  final List<Uint8List?> chunks;

  FileTransferProgress({
    required this.fileName,
    required this.fileType,
    required this.totalChunks,
    required this.fileSize,
    List<Uint8List?>? chunks,
  }) : chunks = chunks ?? List.filled(totalChunks, null);

  double get progress => receivedChunks.length / totalChunks;
}