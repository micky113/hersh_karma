import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Karma Legacy Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'LIFETIME IMPACT STATS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            _buildStatTile(Icons.park_rounded, 'Trees Planted', '5 trees', Colors.green),
            _buildStatTile(Icons.pets_rounded, 'Animal Welfare Logs', '2 rescues', Colors.orange),
            _buildStatTile(Icons.volunteer_activism_rounded, 'Community Hours', '12 hours', Colors.redAccent),
            _buildStatTile(Icons.workspace_premium_rounded, 'Consensus Audits', '18 reviews', Colors.purple),
            const SizedBox(height: 24),
            Card(
              color: Colors.blueGrey.withOpacity(0.05),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PASSPORT MISSION STATEMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                    SizedBox(height: 6),
                    Text(
                      '"Dedicated to localized actions making global impact. Striving to lower emissions and nurture native eco structures in the Bay Area."',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(IconData icon, String label, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}
