// ignore_for_file: library_private_types_in_public_api, unused_field

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DragDropContainer extends StatefulWidget {
  final void Function()? onTap;
  final void Function(PlatformFile)? onSendFile; 
  const DragDropContainer({super.key, this.onTap, this.onSendFile});

  @override
  _DragDropContainerState createState() => _DragDropContainerState();
}

class _DragDropContainerState extends State<DragDropContainer> {
  final List<XFile> _droppedFiles = [];
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) async {
        setState(() {
          _droppedFiles.addAll(details.files);
        });
        print('Dragging done: ${details.files.length} files dropped');
        
        // Check if this appears to be a directory drop (multiple files)
        if (details.files.length > 1) {
          await _handleDirectoryDrop(details.files);
        } else if (details.files.isNotEmpty) {
          await _handleSingleFileDrop(details.files.first);
        }
      },
      onDragEntered: (details) {
        setState(() {
          _isDragging = true;
        });
        print('Dragging entered');
      },
      onDragExited: (details) {
        setState(() {
          _isDragging = false;
        });
        print('Dragging exited');
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDragging ? Colors.blue : Colors.grey,
              width: _isDragging ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[700]!,
                blurRadius: 2,
                spreadRadius: 1,
              ),
            ],
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_shared,  // Changed to folder icon to suggest directory support
                size: 50,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Drag and drop files or folders here',  // Updated text to indicate folder support
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                        text: ' or ', style: TextStyle(color: Colors.black)),
                    TextSpan(
                      text: 'click to select',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text('Files will be sent to the room',
                  style: TextStyle(fontSize: 12)),
              SizedBox(height: 8),
              Text('Maximum file size is 100 MB',
                  style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _handleDirectoryDrop(List<XFile> files) async {
    // Sort files to try to maintain directory structure
    // On many browsers, this will preserve the order of files within directories
    files.sort((a, b) => a.path.compareTo(b.path));
    
    // Process each file in the directory
    for (var file in files) {
      try {
        final platformFile = PlatformFile(
          name: file.name,
          size: await file.length(),
          path: file.path,
          bytes: await file.readAsBytes(),
        );
        
        // Process each file individually
        widget.onSendFile!(platformFile);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not read file: ${file.name}. Error: $e')),
        );
      }
    }
    
    // Show confirmation of directory processing
    if (files.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processed ${files.length} files from directory')),
      );
    }
  }
  
  Future<void> _handleSingleFileDrop(XFile file) async {
    try {
      final platformFile = PlatformFile(
        name: file.name,
        size: await file.length(),
        path: file.path,
        bytes: await file.readAsBytes(),
      );
      
      widget.onSendFile!(platformFile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read file: ${file.name}. Error: $e')),
      );
    }
  }
}