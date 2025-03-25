import 'dart:typed_data';

class FileDisplayInfo {
  final String fileName;
  final String filePath;
  final String fileType;
  final Uint8List fileData;

  FileDisplayInfo({
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileData,
  });
}