import 'package:flutter/material.dart';

class CustomXMLDialog extends StatelessWidget {
  final TextEditingController xmlInputController;
  final Function(String) onParse;

  const CustomXMLDialog({
    Key? key, 
    required this.xmlInputController, 
    required this.onParse
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Custom XML'),
      content: TextField(
        controller: xmlInputController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Paste XML here',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onParse(xmlInputController.text);
          },
          child: const Text('Parse'),
        )
      ],
    );
  }
}