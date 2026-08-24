import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _statementController = TextEditingController();
  String _city = 'San Francisco';

  @override
  void dispose() {
    _statementController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Karma Passport')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      child: Icon(Icons.person, size: 48),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF00B074),
                        child: Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _statementController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Personal Mission Statement',
                  hintText: 'What positive change do you strive to bring?',
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a mission statement' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _city,
                decoration: const InputDecoration(labelText: 'Home City / Region'),
                items: const [
                  DropdownMenuItem(value: 'San Francisco', child: Text('San Francisco, CA')),
                  DropdownMenuItem(value: 'London', child: Text('London, UK')),
                  DropdownMenuItem(value: 'Delhi', child: Text('New Delhi, IN')),
                  DropdownMenuItem(value: 'Tokyo', child: Text('Tokyo, JP')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _city = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Activate Passport'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
