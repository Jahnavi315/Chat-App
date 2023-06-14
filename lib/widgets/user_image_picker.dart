import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserImagePicker extends StatefulWidget{
  const UserImagePicker({super.key , required this.onPickImage});
  final void Function(File) onPickImage;
  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
  void _pickImage() async{
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera , 
      imageQuality: 50, 
      maxWidth: 150
    );
    if(pickedImage == null){
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickedImageFile!);
  }
  @override
  Widget build(BuildContext context) {
    return Column( 
      children: [ 
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundImage: _pickedImageFile != null? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage, 
          label: Text(
            'Add image',
            style: TextStyle( 
              color: Theme.of(context).colorScheme.primary
            ),
          ),
          icon: const Icon(Icons.image),
        )
      ],
    );
  }
}