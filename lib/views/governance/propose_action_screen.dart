import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/governance_provider.dart';
import '../../models/karma_category.dart';

class ProposeActionScreen extends StatefulWidget {
  const ProposeActionScreen({super.key});

  @override
  State<ProposeActionScreen> createState() => _ProposeActionScreenState();
}

class _ProposeActionScreenState extends State<ProposeActionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _problemController = TextEditingController();
  final _locationController = TextEditingController();
  final _impactController = TextEditingController();
  final _evidenceController = TextEditingController();
  final _resourcesController = TextEditingController();
  final _whoBenefitsController = TextEditingController();
  final _suggestedKarmaController = TextEditingController(text: '50');

  KarmaCategory _selectedCategory = KarmaCategory.environment;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _problemController.dispose();
    _locationController.dispose();
    _impactController.dispose();
    _evidenceController.dispose();
    _resourcesController.dispose();
    _whoBenefitsController.dispose();
    _suggestedKarmaController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final govProvider = Provider.of<GovernanceProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await govProvider.proposeAction(
      title: _titleController.text.trim(),
      problemDescription: _problemController.text.trim(),
      category: _selectedCategory,
      location: _locationController.text.trim(),
      expectedImpact: _impactController.text.trim(),
      evidenceRequired: _evidenceController.text.trim(),
      estimatedResources: _resourcesController.text.trim(),
      whoBenefits: _whoBenefitsController.text.trim(),
      suggestedKarma: int.tryParse(_suggestedKarmaController.text) ?? 50,
      proposerId: authProvider.currentUser!.id,
      proposerName: authProvider.currentUser!.name,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('➕ Proposal submitted successfully to the Community Queue!'),
          backgroundColor: Color(0xFF00B074),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Propose Impact Action'),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Description banner
                    Card(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Shape the global registry of positive impact. Your proposal will enter the Community Queue. Once approved by the governance network, it becomes an official verified action.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Action Name / Title',
                        hintText: 'e.g. Install school water-saving flow valves',
                        prefixIcon: Icon(Icons.star_outline_rounded),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Enter the action name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Problem
                    TextFormField(
                      controller: _problemController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Problem it addresses',
                        hintText: 'e.g. Water leakages and waste in public education properties.',
                        prefixIcon: Icon(Icons.report_problem_outlined),
                      ),
                      validator: (val) => val == null || val.length < 10 ? 'Describe the problem (min 10 chars)' : null,
                    ),
                    const SizedBox(height: 16),

                    // Category Selector Dropdown
                    DropdownButtonFormField<KarmaCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Impact Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: KarmaCategory.values.map((cat) {
                        return DropdownMenuItem<KarmaCategory>(
                          value: cat,
                          child: Text('${cat.icon} ${cat.label}'),
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

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Target Location / Country',
                        hintText: 'e.g. Delhi, India or Global / Online',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Specify target location' : null,
                    ),
                    const SizedBox(height: 16),

                    // Expected Impact
                    TextFormField(
                      controller: _impactController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Expected positive impact',
                        hintText: 'e.g. Lowers school water waste by 35% and models eco-responsibility.',
                        prefixIcon: Icon(Icons.bolt_rounded),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Describe the expected impact' : null,
                    ),
                    const SizedBox(height: 16),

                    // Evidence Required
                    TextFormField(
                      controller: _evidenceController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Verification evidence required',
                        hintText: 'e.g. Photo proof of flow valves and monthly bill comparison.',
                        prefixIcon: Icon(Icons.verified_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Specify evidence requirements' : null,
                    ),
                    const SizedBox(height: 16),

                    // Resources / Costs
                    TextFormField(
                      controller: _resourcesController,
                      decoration: const InputDecoration(
                        labelText: 'Estimated resources/time',
                        hintText: 'e.g. ₹12,000 for components, 3 hours setup time',
                        prefixIcon: Icon(Icons.hourglass_empty_rounded),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Provide resource estimates' : null,
                    ),
                    const SizedBox(height: 16),

                    // Who benefits
                    TextFormField(
                      controller: _whoBenefitsController,
                      decoration: const InputDecoration(
                        labelText: 'Who benefits?',
                        hintText: 'e.g. 250+ kids, school, local water district',
                        prefixIcon: Icon(Icons.people_outline_rounded),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Specify target beneficiaries' : null,
                    ),
                    const SizedBox(height: 16),

                    // Suggested Karma value
                    TextFormField(
                      controller: _suggestedKarmaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Suggested Karma value (Credits)',
                        hintText: 'e.g. 50, 100, 250',
                        prefixIcon: Icon(Icons.monetization_on_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Specify a karma score';
                        final parsed = int.tryParse(val);
                        if (parsed == null || parsed <= 0) return 'Must be a positive number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Submit Propose Action'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
