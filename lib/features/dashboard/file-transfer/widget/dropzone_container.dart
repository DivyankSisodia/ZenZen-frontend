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
        
        final dropItem = details.files.first;
        print('File path: ${dropItem.path}');
        
        try {
          final platformFile = PlatformFile(
            name: dropItem.name,
            size: await dropItem.length(),
            path: dropItem.path, // Add the path
            bytes: await dropItem.readAsBytes(), // Read file bytes
          );
          
          widget.onSendFile!(platformFile);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not read file: ${dropItem.name}. Error: $e')),
          );
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
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[700]!,
                blurRadius: 2,
                spreadRadius: 1,
              ),
            ],
            color: Colors.white, // Replace with AppColors.background if defined
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.file_upload,
                size: 50,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Drag and drop files here',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                        text: ' or ', style: TextStyle(color: Colors.black)),
                    TextSpan(
                      text: 'click to select files',
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
}
