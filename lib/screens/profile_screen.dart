import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/gamification_service.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final profileService = ProfileService();
  final authService = AuthService();
  final gamification = GamificationService();
  bool isEditing = false;
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = authService.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: profileService.profileStream(),
        builder: (context, profileSnap) {
          final profileData = profileSnap.data?.data() as Map<String, dynamic>?;
          final name = profileData?['name'] ?? email.split('@').first;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                isEditing
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: nameController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(hintText: 'Enter name'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_rounded, color: Colors.green),
                      onPressed: () async {
                        await profileService.updateName(nameController.text.trim());
                        setState(() => isEditing = false);
                      },
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      onPressed: () {
                        nameController.text = name;
                        setState(() => isEditing = true);
                      },
                    ),
                  ],
                ),
                Text(email, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 28),

                StreamBuilder<DocumentSnapshot>(
                  stream: gamification.statsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final xp = data['xp'] ?? 0;
                    final streak = data['streak'] ?? 0;
                    final words = data['totalWordsLearned'] ?? 0;
                    final level = gamification.getLevel(xp);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MiniStat(icon: Icons.star_rounded, value: '$level', label: 'Level', color: Colors.purple),
                        _MiniStat(icon: Icons.local_fire_department_rounded, value: '$streak', label: 'Streak', color: Colors.orange),
                        _MiniStat(icon: Icons.menu_book_rounded, value: '$words', label: 'Words', color: Colors.green),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),

                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}