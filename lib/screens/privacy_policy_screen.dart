import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last updated: July 2026', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 20),

            _Section(
              title: '1. Introduction',
              content: 'LinguaLearn ("we", "our", or "us") respects your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our app.',
            ),
            _Section(
              title: '2. Information We Collect',
              content: '• Account information: your email address and password (managed securely by Firebase Authentication)\n'
                  '• Learning data: words learned, quiz scores, streaks, XP, favorites, and app usage statistics\n'
                  '• Chat messages: text you send to the AI Tutor feature, which is processed to generate responses\n'
                  '• Device information: basic technical data needed for app functionality (e.g. offline storage)',
            ),
            _Section(
              title: '3. How We Use Your Information',
              content: 'We use your information to:\n'
                  '• Provide and improve the app\'s features (flashcards, quizzes, progress tracking)\n'
                  '• Sync your learning progress across sessions\n'
                  '• Send optional daily reminder notifications (if enabled)\n'
                  '• Generate AI tutor responses via a third-party language model provider',
            ),
            _Section(
              title: '4. Third-Party Services',
              content: 'We use the following third-party services:\n'
                  '• Google Firebase (Authentication, Cloud Firestore) — for account management and data storage\n'
                  '• Groq API — for AI-powered conversation practice\n\n'
                  'These providers may process data according to their own privacy policies.',
            ),
            _Section(
              title: '5. Data Storage',
              content: 'Your data is stored securely on Google Firebase servers. Some data is also cached locally on your device for offline access and is synced automatically when an internet connection is available.',
            ),
            _Section(
              title: '6. Your Rights',
              content: 'You may:\n'
                  '• Request access to your stored data\n'
                  '• Request correction or deletion of your data via the Settings screen\n'
                  '• Delete your account at any time',
            ),
            _Section(
              title: '7. Children\'s Privacy',
              content: 'This app is not intended for children under 13. We do not knowingly collect personal information from children under this age.',
            ),
            _Section(
              title: '8. Changes to This Policy',
              content: 'We may update this Privacy Policy from time to time. Continued use of the app after changes constitutes acceptance of the updated policy.',
            ),
            _Section(
              title: '9. Contact Us',
              content: 'If you have questions about this Privacy Policy, please contact us through the Feedback option in the app.',
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