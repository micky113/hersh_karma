import 'package:flutter/material.dart';

class ReportAbuseScreen extends StatefulWidget {
  const ReportAbuseScreen({super.key});

  @override
  State<ReportAbuseScreen> createState() => _ReportAbuseScreenState();
}

class _ReportAbuseScreenState extends State<ReportAbuseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deedIdController = TextEditingController();
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _deedIdController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abuse report submitted. Platform auditors will review the cryptographic proof.'),
          backgroundColor: Color(0xFF00B074),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Abuse')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Help Protect Ecosystem Integrity',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you discover a verified or pending submission that contains fake images, falsified GPS logs, or incorrect data, please file a report below.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _deedIdController,
                decoration: const InputDecoration(
                  labelText: 'Transaction/Deed ID',
                  hintText: 'e.g. deed_123x...',
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter the deed identifier' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Explain details of the violation',
                  hintText: 'What is incorrect? (e.g. generic photo from internet, wrong location coordinates)',
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please explain the issue' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Submit Violation Flag'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
