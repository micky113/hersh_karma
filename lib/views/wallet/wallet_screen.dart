import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../../models/transaction.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _transferFormKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  String _selectedCharityId = 'charity_oceans';
  String _selectedCharityName = 'Clean Oceans Fund 🌊';

  final List<Map<String, String>> _charities = [
    {'id': 'charity_oceans', 'name': 'Clean Oceans Fund 🌊', 'desc': 'Removes plastic from oceans & plants coral reefs.'},
    {'id': 'charity_shelter', 'name': 'Wild Animal Rescue 🐾', 'desc': 'Provides medical care to stray and wild animals.'},
    {'id': 'charity_redcross', 'name': 'Global Kindness Coalition ❤️', 'desc': 'Delivers crisis relief and food to families in need.'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _mintTokens(UserProfile user, WalletProvider walletProvider) async {
    final success = await walletProvider.mintPoGTokens(user.name, 1.0);
    if (success && mounted) {
      final newTx = walletProvider.ledger.first;
      _showTransactionDialog(newTx);
    }
  }

  void _donateTokens(UserProfile user, WalletProvider walletProvider) async {
    if (!_transferFormKey.currentState!.validate()) return;
    
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount > user.tokensBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient PoG token balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await walletProvider.transferTokens(
      senderName: user.name,
      receiverId: _selectedCharityId,
      receiverName: _selectedCharityName,
      amount: amount,
    );

    if (success && mounted) {
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully donated $amount PoG to $_selectedCharityName!'),
          backgroundColor: const Color(0xFF00B074),
        ),
      );
    }
  }

  void _showTransactionDialog(CryptoTransaction tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.token_rounded, color: Color(0xFF00B074)),
            SizedBox(width: 8),
            Text('Block Minted Successfully'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'A new cryptographic block was added to the Proof of Good ledger.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildDialogTxField('Transaction ID', tx.id),
              _buildDialogTxField('Sender Address', tx.senderId),
              _buildDialogTxField('Receiver Address', tx.receiverId),
              _buildDialogTxField('Amount Minted', '${tx.amount} PoG'),
              _buildDialogTxField('Block Timestamp', tx.timestamp.toIso8601String()),
              _buildDialogTxField('Block Hash (SHA-256)', tx.hash, isCode: true),
              _buildDialogTxField('Previous Block Hash', tx.previousHash, isCode: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTxField(String label, String val, {bool isCode = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    val,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: isCode ? 'monospace' : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: val));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final walletProvider = Provider.of<WalletProvider>(context);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final canMint = user.karmaCredits >= 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Crypto Balance Card
          Card(
            color: theme.colorScheme.surface,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'TOKEN WALLET BALANCE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.token_rounded, color: Color(0xFFFFB300), size: 36),
                      const SizedBox(width: 8),
                      Text(
                        '${user.tokensBalance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'PoG',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('${user.karmaCredits}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('Karma Credits', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      Column(
                        children: [
                          Text('${(user.karmaCredits / 100).floor()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('Eligible Mints', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mint panel
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.currency_exchange_rounded, color: Color(0xFF00B074)),
                      const SizedBox(width: 8),
                      Text(
                        'Karma Minting Hub',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Convert credits to native PoG cryptocurrency. Rate: 100 Karma Credits = 1.0 PoG Token.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  if (walletProvider.isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    ElevatedButton(
                      onPressed: canMint ? () => _mintTokens(user, walletProvider) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canMint ? const Color(0xFF00B074) : Colors.grey[400],
                      ),
                      child: Text(canMint ? 'Mint 1.0 PoG Token' : 'Need 100 Credits to Mint'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.impactExchange),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00B074),
                        side: const BorderSide(color: Color(0xFF00B074)),
                      ),
                      icon: const Icon(Icons.swap_horizontal_circle_outlined, size: 16),
                      label: const Text('Open Interoperable Impact Exchange'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: const Color(0xFFFFB300).withOpacity(0.08),
            child: ListTile(
              leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFFFB300)),
              title: const Text('Redeem Vouchers & Eco Vouchers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Use minted tokens in public transit stores & zero waste markets', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_rounded, size: 16),
              onTap: () => Navigator.pushNamed(context, AppRoutes.rewards),
            ),
          ),
          const SizedBox(height: 16),

          // Redeem / Donate Panel
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _transferFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.volunteer_activism_rounded, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Fund Social Impact',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Directly redeem or donate PoG tokens to support real, verified NGO action.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCharityId,
                      decoration: const InputDecoration(
                        labelText: 'Select NGO / Cause',
                        prefixIcon: Icon(Icons.business_rounded),
                      ),
                      items: _charities.map((ch) {
                        return DropdownMenuItem<String>(
                          value: ch['id'],
                          child: Text(ch['name']!),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCharityId = val;
                            _selectedCharityName = _charities.firstWhere((e) => e['id'] == val)['name']!;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.ngos),
                        icon: const Icon(Icons.search_rounded, size: 14),
                        label: const Text('Browse NGO Directory', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _charities.firstWhere((e) => e['id'] == _selectedCharityId)['desc']!,
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount (PoG)',
                        prefixIcon: Icon(Icons.toll_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter amount';
                        final numVal = double.tryParse(val);
                        if (numVal == null || numVal <= 0) return 'Enter a positive number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => _donateTokens(user, walletProvider),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text('Redeem & Support Cause'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Ledger block history
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Decentralized Ledger (PoG Chain)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.link_rounded, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),

          if (walletProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: walletProvider.ledger.length,
              itemBuilder: (context, index) {
                final tx = walletProvider.ledger[index];
                return _buildLedgerBlock(context, tx, user.id);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLedgerBlock(BuildContext context, CryptoTransaction tx, String currentUserId) {
    final isMint = tx.type == TransactionType.mint;
    final isDonation = tx.type == TransactionType.donation;

    Color txColor = Colors.blue;
    IconData txIcon = Icons.swap_horiz_rounded;
    String sign = '';

    if (isMint) {
      txColor = const Color(0xFF00B074);
      txIcon = Icons.toll_rounded;
      sign = '+';
    } else if (isDonation) {
      txColor = Colors.redAccent;
      txIcon = Icons.favorite_rounded;
      sign = '-';
    } else {
      if (tx.senderId == currentUserId) {
        txColor = Colors.orange;
        sign = '-';
      } else {
        txColor = Colors.blue;
        sign = '+';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: txColor.withOpacity(0.12),
          child: Icon(txIcon, color: txColor, size: 20),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isMint
                    ? 'Mint Token Block'
                    : isDonation
                        ? 'NGO Donation Block'
                        : 'Transfer Block',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Text(
              '$sign${tx.amount.toStringAsFixed(2)} PoG',
              style: TextStyle(color: txColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isMint
                    ? 'Minter: ${tx.receiverName}'
                    : 'To: ${tx.receiverName}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${tx.timestamp.hour}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLedgerInfoRow('Block ID', tx.id),
                _buildLedgerInfoRow('Sender Addr', tx.senderId),
                _buildLedgerInfoRow('Receiver Addr', tx.receiverId),
                _buildLedgerInfoRow('Previous Hash', tx.previousHash, isCode: true),
                _buildLedgerInfoRow('Block Hash', tx.hash, isCode: true),
                if (tx.associatedDeedId != null)
                  _buildLedgerInfoRow('Associated Proof Deed', tx.associatedDeedId!),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLedgerInfoRow(String label, String val, {bool isCode = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: TextStyle(
                fontSize: 10,
                fontFamily: isCode ? 'monospace' : null,
                color: Colors.blueGrey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: val));
            },
            child: const Icon(Icons.copy_rounded, size: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
