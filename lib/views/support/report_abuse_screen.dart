import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/karma_category.dart';
import '../../core/localization/app_localizations.dart';

class ReportAbuseScreen extends StatefulWidget {
  const ReportAbuseScreen({super.key});

  @override
  State<ReportAbuseScreen> createState() => _ReportAbuseScreenState();
}

class _ReportAbuseScreenState extends State<ReportAbuseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  KarmaCategory _selectedCategory = KarmaCategory.environment;
  String? _beforeImageUrl;
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);

    final success = await karmaProvider.submitProblem(
      title: _titleController.text.trim(),
      description: _detailsController.text.trim(),
      category: _selectedCategory,
      latitude: _latitude ?? 12.9716,
      longitude: _longitude ?? 77.5946,
      beforeImageUrl: _beforeImageUrl ?? 'captured_before.png',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Problem reported successfully! Original reporter awarded +5 Reputation.'),
          backgroundColor: Color(0xFF00B074),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _simulateGPS() {
    setState(() {
      _isLocating = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _latitude = 12.9716;
        _longitude = 77.5946;
        _isLocating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translateWithContext(context, 'rep_title', defaultValue: 'Report a Problem')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.translateWithContext(context, 'rep_title', defaultValue: 'Report a Problem'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Flag garbage piles, animal issues, or public safety hazards immediately. NGOs can claim and resolve them.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<KarmaCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: AppLocalizations.translateWithContext(context, 'rep_category', defaultValue: 'Problem Category'),
                  border: const OutlineInputBorder(),
                ),
                items: KarmaCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Brief Title / Issue Name',
                  hintText: 'e.g. Broken water pipe / Garbage pile',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter problem title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppLocalizations.translateWithContext(context, 'rep_details', defaultValue: 'Details (text or speak)'),
                  hintText: 'Describe the issue...',
                  border: const OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please explain the issue' : null,
              ),
              const SizedBox(height: 20),

              // Mock GPS Lock Card
              Card(
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: _latitude != null ? Colors.green : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _latitude != null ? 'GPS Coordinates Locked' : 'GPS Location Required',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (_latitude != null)
                              Text('Lat: $_latitude, Lon: $_longitude', style: const TextStyle(fontSize: 12, color: Colors.grey))
                            else
                              const Text('Click target below to lock coordinates', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (_isLocating)
                        const CircularProgressIndicator()
                      else
                        IconButton(
                          icon: const Icon(Icons.gps_fixed),
                          onPressed: _simulateGPS,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mock BEFORE image attachment
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _beforeImageUrl = 'captured_before_${DateTime.now().millisecondsSinceEpoch}.jpg';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📸 BEFORE photo attached successfully!')),
                  );
                },
                icon: const Icon(Icons.add_a_photo),
                label: Text(_beforeImageUrl != null ? 'Change Attached Photo' : 'Attach Photo Evidence'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: _selectedCategory.color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(AppLocalizations.translateWithContext(context, 'rep_submit', defaultValue: 'Submit Report')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
