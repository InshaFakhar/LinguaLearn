import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/favorites_service.dart';
import '../services/tts_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesService();
    final tts = TtsService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: StreamBuilder<QuerySnapshot>(
        stream: favorites.favoritesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No favorites yet', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Tap the heart icon on flashcards to save words', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['word'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(data['translation'] ?? '', style: TextStyle(color: theme.colorScheme.primary)),
                          Text('${data['language']} • ${data['category']}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded),
                      onPressed: () => tts.speak(data['word'] ?? '', data['language'] ?? 'English'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                      onPressed: () async {
                        await favorites.toggleFavorite(docs[i].id, data);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}