import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last updated: July 2026', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 20),

            _Section(
              title: '1. Acceptance of Terms',
              content: 'By using LinguaLearn, you agree to these Terms of Service. If you do not agree, please discontinue use of the app.',
            ),
            _Section(
              title: '2. Use of the App',
              content: 'LinguaLearn is provided for personal, non-commercial language learning purposes. You agree not to misuse the app, attempt to reverse-engineer it, or use it in any way that could harm the service or other users.',
            ),
            _Section(
              title: '3. Account Responsibility',
              content: 'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
            ),
            _Section(
              title: '4. AI Tutor Feature',
              content: 'The AI Tutor feature uses a third-party language model to generate conversational responses. Responses are generated automatically and may occasionally contain errors. LinguaLearn does not guarantee the accuracy of AI-generated content.',
            ),
            _Section(
              title: '5. Content and Intellectual Property',
              content: 'All app content, including vocabulary, design, and branding, is the property of LinguaLearn or its licensors and may not be copied or redistributed without permission.',
            ),
            _Section(
              title: '6. Service Availability',
              content: 'We strive to keep LinguaLearn available at all times but do not guarantee uninterrupted access. Some features (e.g. AI Tutor) require an internet connection.',
            ),
            _Section(
              title: '7. Limitation of Liability',
              content: 'LinguaLearn is provided "as is" without warranties of any kind. We are not liable for any indirect or incidental damages resulting from your use of the app.',
            ),
            _Section(
              title: '8. Termination',
              content: 'We reserve the right to suspend or terminate accounts that violate these terms.',
            ),
            _Section(
              title: '9. Changes to Terms',
              content: 'These terms may be updated periodically. Continued use of the app after changes constitutes acceptance of the updated terms.',
            ),
            _Section(
              title: '10. Contact',
              content: 'For questions about these Terms, please use the Feedback option in the app.',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}