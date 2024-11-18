import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'custom.dart';
import 'predefined.dart';

class FormField {
  final String type;
  final String name;
  final String label;
  final List<String>? options;
  final bool required;

  FormField({
    required this.type,
    required this.name,
    required this.label,
    this.options,
    this.required = false,
  });
}

class FormRendererHome extends StatefulWidget {
  const FormRendererHome({Key? key}) : super(key: key);

  @override
  _FormRendererHomeState createState() => _FormRendererHomeState();
}

class _FormRendererHomeState extends State<FormRendererHome> {
  List<FormField> formFields = [];
  Map<String, dynamic> formData = {};
  SignatureController? _signatureController;
  final TextEditingController _xmlInputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void parseXML(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      final fields = document.findAllElements('field');

      setState(() {
        formFields = fields.map((field) {
          final attributes = field.attributes;
          return FormField(
            type: attributes.firstWhere((a) => a.name.local == 'type').value,
            name: attributes.firstWhere((a) => a.name.local == 'name').value,
            label: attributes.firstWhere((a) => a.name.local == 'label').value,
            required: attributes.any((a) => a.name.local == 'required')
                ? attributes.firstWhere((a) => a.name.local == 'required').value == 'true'
                : false,
            options: attributes.any((a) => a.name.local == 'options')
                ? attributes.firstWhere((a) => a.name.local == 'options').value.split(',')
                : null,
          );
        }).toList();
        formData.clear();
        _signatureController = SignatureController(
          penStrokeWidth: 5,
          penColor: const Color(0xFFC53F00),
        );
      });
    } catch (e) {
      _showErrorDialog('XML Parsing Error', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Color(0xFFC53F00))),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(FormField field) {
    switch (field.type) {
      case 'text':
      case 'email':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: field.label + (field.required ? ' *' : ''),
              prefixIcon: Icon(
                field.type == 'email' ? Icons.email_outlined : Icons.person_outline,
                color: const Color(0xFFC53F00),
              ),
            ),
            keyboardType: field.type == 'email' 
              ? TextInputType.emailAddress 
              : TextInputType.text,
            validator: field.required 
              ? (value) => value == null || value.isEmpty 
                ? '${field.label} is required' 
                : null 
              : null,
            onChanged: (value) => formData[field.name] = value,
          ),
        );

      case 'date':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: field.label + (field.required ? ' *' : ''),
              prefixIcon: const Icon(
                Icons.calendar_today,
                color: Color(0xFFC53F00),
              ),
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                builder: (context, child) => Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: const Color(0xFFC53F00),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                setState(() {
                  formData[field.name] = picked;
                });
              }
            },
            controller: TextEditingController(
              text: formData[field.name] != null
                  ? DateFormat('yyyy-MM-dd').format(formData[field.name])
                  : '',
            ),
            readOnly: true,
            validator: field.required 
              ? (value) => formData[field.name] == null 
                ? '${field.label} is required' 
                : null 
              : null,
          ),
        );

      case 'radio':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label + (field.required ? ' *' : ''),
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC53F00),
                ),
              ),
              ...?field.options?.map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: formData[field.name],
                    activeColor: const Color(0xFFC53F00),
                    onChanged: (value) {
                      setState(() {
                        formData[field.name] = value;
                      });
                    },
                  )),
              if (field.required && formData[field.name] == null)
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Text(
                    'Please select an option',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
            ],
          ),
        );

      case 'drawing':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label + (field.required ? ' *' : ''),
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC53F00),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Open Signature Pad'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC53F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => Container(
                        color: Colors.white,
                        height: 450,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Draw Your Signature',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC53F00),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Signature(
                              controller: _signatureController!,
                              height: 250,
                              width: double.infinity,
                              backgroundColor: Colors.grey[200]!,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _signatureController!.clear();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Clear'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    formData[field.name] = _signatureController!.points;
                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Save'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (field.required && formData[field.name] == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      'Signature is required',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                )
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      print(formData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Form Submitted Successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dynamic XML Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_open),
                  label: const Text('Predefined XML'),
                  onPressed: () => parseXML(predefinedXML),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.input),
                  label: const Text('    Custom XML   '),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => CustomXMLDialog(
                      xmlInputController: _xmlInputController, 
                      onParse: parseXML,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: formFields.isEmpty
                  ? const Center(
                      child: Text(
                        'Select a form!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFC53F00),
                        ),
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          ...formFields.map(_buildField).toList(),
                          if (formFields.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                child: const Text('Submit Form'),
                              ),
                            )
                        ],
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}