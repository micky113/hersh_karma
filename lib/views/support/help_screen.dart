import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 16),
          ExpansionTile(
            title: Text('What is a Karma Credit?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Karma Credits are non-transferable reputation points earned when you complete verified daily good deeds. They represent your social impact and directly define your community validator reputation.',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              )
            ],
          ),
          ExpansionTile(
            title: Text('How does PoG Token minting work?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Once you accumulate 100 verified Karma Credits, you can "burn" them in the Wallet to mint 1.0 PoG crypto token. This token acts as a measurable digital asset that organizations can buy or you can donate to NGOs.',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              )
            ],
          ),
          ExpansionTile(
            title: Text('What is the confidence score?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'The confidence score estimates proof strength. Attaching photo logs (+25%), GPS hardware coordinates (+20%), and witness email addresses (+15%) increases your confidence score, enabling faster validator approval.',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              )
            ],
          ),
          ExpansionTile(
            title: Text('What is the "No Proof of Change" rule?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'To prevent false claims, Karma Grid enforces a strict BEFORE → ACTION → AFTER sequence. Every qualifying action must demonstrate a meaningful change using the strongest practical evidence for that action (e.g. photos of a cleanup site, starting/ending learner assessments, or system performance logs). Submissions without both BEFORE and AFTER proof are rejected.',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
