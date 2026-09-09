import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/karma_action.dart';
import '../../models/karma_category.dart';
import '../../models/karma_activity.dart';
import '../../data/india_30_presets.dart';
import '../../data/karma_grid_presets.dart';
import '../../core/routes/app_routes.dart';

import '../../core/localization/app_localizations.dart';

class IndiaMissionScreen extends StatefulWidget {
  const IndiaMissionScreen({super.key});

  @override
  State<IndiaMissionScreen> createState() => _IndiaMissionScreenState();
}

class _IndiaMissionScreenState extends State<IndiaMissionScreen> {
  IndiaPillar _selectedPillar = IndiaPillar.humanCapital;
  IndiaMissionPreset? _selectedPresetDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karmaProvider = Provider.of<KarmaProvider>(context);

    // Calculate dynamic additions based on user's verified deeds in the system
    final verifiedDeeds = karmaProvider.myActions.where((e) => e.status == DeedStatus.verified);
    
    // Custom dynamic increment seeds
    final mentoredDeeds = verifiedDeeds.where((e) => e.title.contains('Mentor')).length;
    final trainedDeeds = verifiedDeeds.where((e) => e.title.contains('Teach')).length;
    final bloodDeeds = verifiedDeeds.where((e) => e.title.contains('blood') || e.title.contains('Blood')).length;
    final wasteDeeds = verifiedDeeds.where((e) => e.title.contains('waste') || e.title.contains('Waste') || e.title.contains('litter') || e.title.contains('Litter')).length;

    // Seeding India Tickers
    final mentoredCount = 1245830 + mentoredDeeds;
    final trainedCount = 682421 + trainedDeeds;
    final jobsCount = 214502;
    final bloodCount = 394210 + bloodDeeds;
    final wasteCount = 8245000 + (wasteDeeds * 15); // assume 15kg litter per cleanup
    final waterCount = 1450200;
    final ecoCount = 49200;
    final civicCount = 18300 + verifiedDeeds.where((e) => e.category == KarmaCategory.communityService).length;

    // Filter India 30 actions by selected pillar
    final filteredPresets = india30Presets.where((preset) => preset.pillar == _selectedPillar).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translateWithContext(context, 'mission_india30_title', defaultValue: 'India 30 Mission Hub 🇮🇳')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header India Goal Card
            Card(
              color: const Color(0xFFFF9933).withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF128807), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.translateWithContext(context, 'INDIA 30 NATIONAL OBJECTIVES', defaultValue: 'INDIA 30 NATIONAL OBJECTIVES'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF000080), // Ashoka Chakra Navy Blue
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.translateWithContext(
                        context,
                        '30 foundational priority actions selected specifically to improve human capital, environmental security, and civic infrastructure in India. Earn Karma Multipliers for community-wide reach.',
                        defaultValue: '30 foundational priority actions selected specifically to improve human capital, environmental security, and civic infrastructure in India. Earn Karma Multipliers for community-wide reach.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[800], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Live Progress Tickers Label
            Row(
              children: [
                const Icon(Icons.show_chart_rounded, color: Color(0xFF128807)),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.translateWithContext(context, 'National Progress Metrics (Live)', defaultValue: 'National Progress Metrics (Live)'),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress Tickers Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: [
                _buildTickerCard('👨‍🎓 Students Mentored', mentoredCount.toString(), Colors.blue),
                _buildTickerCard('🧠 People Trained', trainedCount.toString(), Colors.teal),
                _buildTickerCard('💼 Jobs Created/Accessed', jobsCount.toString(), Colors.amber),
                _buildTickerCard('🩸 Blood Donations', bloodCount.toString(), Colors.red),
                _buildTickerCard('♻️ Waste Recovered (kg)', wasteCount.toString(), Colors.green),
                _buildTickerCard('💧 Water Saved (Litres)', waterCount.toString(), Colors.lightBlue),
                _buildTickerCard('🌱 Ecosystems Restored', ecoCount.toString(), Colors.indigo),
                _buildTickerCard('🏛️ Civic Issues Resolved', civicCount.toString(), Colors.purple),
              ],
            ),
            const SizedBox(height: 24),

            // Pillars Tab Selector
            Text(
              AppLocalizations.translateWithContext(context, 'Select Impact Pillar', defaultValue: 'Select Impact Pillar'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: IndiaPillar.values.length,
                itemBuilder: (context, index) {
                  final pillar = IndiaPillar.values[index];
                  final isSelected = _selectedPillar == pillar;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Row(
                        children: [
                          Text(pillar.icon),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.translateWithContext(context, pillar.label, defaultValue: pillar.label)),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: pillar.color.withOpacity(0.2),
                      side: BorderSide(
                        color: isSelected ? pillar.color : Colors.grey.withOpacity(0.3),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedPillar = pillar;
                          _selectedPresetDetail = null; // Reset detail card
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.translateWithContext(context, _selectedPillar.description, defaultValue: _selectedPillar.description),
              style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),

            // Pillar Priority Actions List
            Text(
              AppLocalizations.translateWithContext(context, 'Pillar Priorities', defaultValue: 'Pillar Priorities'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredPresets.length,
              itemBuilder: (context, index) {
                final preset = filteredPresets[index];
                final isSelected = _selectedPresetDetail == preset;

                return Card(
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? _selectedPillar.color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _selectedPillar.color.withOpacity(0.12),
                      child: Text(
                        '#${preset.rank}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _selectedPillar.color),
                      ),
                    ),
                    title: Text(
                      AppLocalizations.translateWithContext(context, preset.title, defaultValue: preset.title),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      AppLocalizations.translateWithContext(context, preset.justification, defaultValue: preset.justification),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      setState(() {
                        _selectedPresetDetail = preset;
                      });
                    },
                  ),
                );
              },
            ),

            // Selected Preset Detail Overlay Banner
            if (_selectedPresetDetail != null) ...[
              const SizedBox(height: 20),
              Card(
                color: _selectedPillar.color.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: _selectedPillar.color.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Active India 30 Mission: Rank #${_selectedPresetDetail!.rank}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: _selectedPillar.color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.translateWithContext(context, _selectedPresetDetail!.title, defaultValue: _selectedPresetDetail!.title),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pillar Rationale: ${_selectedPresetDetail!.justification}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedPillar.color,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Find corresponding preset from 366 presets database
                          final originalPreset = karmaGridPresets.firstWhere(
                            (e) => e.id == _selectedPresetDetail!.activityPresetId,
                            orElse: () => null as dynamic,
                          );

                          if (originalPreset != null) {
                            karmaProvider.prefilledPreset = originalPreset;
                            // Pop current screen and navigate to main home Submit tab (index 2)
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.home,
                              (route) => false,
                              arguments: 2,
                            );
                          }
                        },
                        icon: const Icon(Icons.assignment_turned_in_rounded),
                        label: Text(AppLocalizations.translateWithContext(context, 'Accept & Pre-fill Submit', defaultValue: 'Accept & Pre-fill Submit')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTickerCard(String title, String count, Color color) {
    return Builder(builder: (context) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.translateWithContext(context, title, defaultValue: title),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.blueGrey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                count.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
