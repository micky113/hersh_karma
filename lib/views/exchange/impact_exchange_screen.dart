import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../models/exchange_asset.dart';
import '../../data/exchange_assets_presets.dart';

class ImpactExchangeScreen extends StatefulWidget {
  const ImpactExchangeScreen({super.key});

  @override
  State<ImpactExchangeScreen> createState() => _ImpactExchangeScreenState();
}

class _ImpactExchangeScreenState extends State<ImpactExchangeScreen> {
  AssetCategory _selectedCategory = AssetCategory.environmental;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

    final user = authProvider.currentUser;
    final karmaBalance = user?.karmaCredits ?? 0;

    // Filter assets by selected category
    final assets = exchangeAssetsPresets.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact Exchange Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Exchange Header Banner
            Card(
              color: Colors.green.withOpacity(0.08),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.green, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '🌱 INTEROPERABLE IMPACT SETTLEMENT',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your verified Karma Grid Credits (KGC) represent real-world positive outcomes. Convert them into verified environmental, health, education, or animal assets on the exchange registry.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Your Wallet: $karmaBalance KGC',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sector Tabs (Environmental, Human, Animal, Knowledge)
            Text(
              'Select Impact Registry',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AssetCategory.values.length,
                itemBuilder: (context, idx) {
                  final cat = AssetCategory.values[idx];
                  final isSelected = _selectedCategory == cat;
                  
                  String label = '🌱 Environmental';
                  Color activeColor = Colors.green;
                  if (cat == AssetCategory.human) {
                    label = '❤️ Human Capital';
                    activeColor = Colors.red;
                  } else if (cat == AssetCategory.animal) {
                    label = '🐘 Animal Protection';
                    activeColor = Colors.amber;
                  } else if (cat == AssetCategory.knowledge) {
                    label = '🧠 Open Knowledge';
                    activeColor = Colors.blue;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: activeColor.withOpacity(0.18),
                      side: BorderSide(
                        color: isSelected ? activeColor : Colors.grey.withOpacity(0.3),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Assets List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assets.length,
              itemBuilder: (context, idx) {
                final asset = assets[idx];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              asset.icon,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    asset.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    '1.0 ${asset.symbol} = ${asset.exchangeRate} KGC',
                                    style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B074),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: karmaBalance < asset.exchangeRate
                                  ? null
                                  : () => _showConversionDialog(context, asset, karmaBalance, walletProvider, authProvider),
                              child: const Text('Convert'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          asset.description,
                          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConversionDialog(
    BuildContext context,
    ExchangeAsset asset,
    int userCredits,
    WalletProvider walletProvider,
    AuthProvider authProvider,
  ) {
    final formKey = GlobalKey<FormState>();
    final creditInputController = TextEditingController(text: asset.exchangeRate.toString());
    double outputUnits = 1.0;
    String selectedOption = 'Option A: Donate equivalent value to environmental/social NGO';

    final options = [
      'Option A: Donate equivalent value to environmental/social NGO',
      'Option B: Support local community development projects',
      'Option C: Convert into Carbon Offset Certificates',
      'Option D: Swap directly with compatible partner tokens (Ocean/Tree/Edu)',
      'Option E: Burn credits and mint PoG blockchain utility tokens separately',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Text(asset.icon),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Impact Exchange: ${asset.symbol}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Exchange verified credits to acquire or redeem ${asset.name}.',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // Karma Credits Input
                      TextFormField(
                        controller: creditInputController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Karma Credits (KGC) to exchange',
                          hintText: 'Min is exchange rate',
                          prefixIcon: Icon(Icons.stars_rounded, color: Colors.amber),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter credits';
                          final parsed = int.tryParse(val);
                          if (parsed == null || parsed < asset.exchangeRate) {
                            return 'Min is ${asset.exchangeRate} KGC';
                          }
                          if (parsed > userCredits) {
                            return 'Insufficient credits (Max: $userCredits)';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          final parsed = int.tryParse(val) ?? 0;
                          setState(() {
                            outputUnits = parsed / asset.exchangeRate;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Converted Units Display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Converted Units:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              '${outputUnits.toStringAsFixed(3)} ${asset.symbol}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00B074)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Settlement Route Path Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedOption,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Impact Conversion Pathway',
                        ),
                        items: options.map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt,
                            child: Text(
                              opt,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedOption = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B074),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final creditsToBurn = int.parse(creditInputController.text.trim());
                    final user = authProvider.currentUser!;
                    
                    // Trigger ledger writing
                    final success = await walletProvider.exchangeKarmaCredits(
                      userName: user.name,
                      assetName: asset.name,
                      assetUnits: outputUnits,
                      karmaCreditsBurned: creditsToBurn,
                      optionSelected: selectedOption,
                    );

                    if (success && context.mounted) {
                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🎉 Successfully settled ${outputUnits.toStringAsFixed(2)} ${asset.symbol} via $selectedOption!'),
                          backgroundColor: const Color(0xFF00B074),
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm Exchange'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
