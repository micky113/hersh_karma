import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/wish.dart';

class MakeWishScreen extends StatefulWidget {
  const MakeWishScreen({super.key});

  @override
  State<MakeWishScreen> createState() => _MakeWishScreenState();
}

class _MakeWishScreenState extends State<MakeWishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController(text: '1000');
  WishCategory _selectedCategory = WishCategory.experience;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);
    final target = int.tryParse(_targetController.text.trim()) ?? 1000;

    final success = await karmaProvider.submitWish(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      karmaTarget: target,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Wish submitted successfully! AI generated your Wish Plan.'),
          backgroundColor: Color(0xFF00B074),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(karmaProvider.error ?? 'Submission failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karmaProvider = Provider.of<KarmaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('💫 Make a Wish'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Describe Your Wish',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Wishes should be meaningful achievements or community projects. The network will coordinate to help sponsor, fund, or connect resources.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Wish Title',
                  hintText: 'e.g. Learn guitar, Get clean drinking water...',
                  prefixIcon: Icon(Icons.star_outline_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter a title for your wish' : null,
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Why is this wish important to you?',
                  hintText: 'Provide details. What do you need? Who will it help?',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 56.0),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (val) => val == null || val.trim().length < 15
                    ? 'Provide a detailed description (min 15 characters)'
                    : null,
              ),
              const SizedBox(height: 20),

              // Category dropdown
              DropdownButtonFormField<WishCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: WishCategory.values.map((cat) {
                  return DropdownMenuItem<WishCategory>(
                    value: cat,
                    child: Row(
                      children: [
                        Text(cat.icon),
                        const SizedBox(width: 8),
                        Text(cat.label),
                      ],
                    ),
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
              const SizedBox(height: 20),

              // Karma target
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Desired Karma Crowdfund Target',
                  hintText: 'e.g. 500, 1000, 2000',
                  prefixIcon: Icon(Icons.favorite_border_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter a Karma goal';
                  final parsed = int.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid positive number';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // AI plan card preview
              Card(
                color: theme.colorScheme.primary.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.psychology_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🤖 AI Wish Plan Generator',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'When you submit, Karma Grid AI automatically analyzes your wish and creates a 4-step actionable execution roadmap. Sponsors can view milestones and contribute resources or Karma directly to specific steps.',
                              style: TextStyle(color: Colors.grey[750], fontSize: 11, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (karmaProvider.isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8F00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Generate Wish Plan & Submit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
