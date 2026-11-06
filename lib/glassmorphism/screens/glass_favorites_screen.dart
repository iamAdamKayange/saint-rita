import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/glassmorphism/screens/glass_prayer_detail_screen.dart';
import 'package:saint_rita/provider/language_provider.dart';
import 'package:saint_rita/provider/prayer_favorites_provider.dart';

class GlassFavoritesScreen extends StatelessWidget {
  const GlassFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? Colors.white : GlassDesignSystem.deepForestGreen;
    final sw = context.watch<LanguageProvider>().isSwahili;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const _FavoritesBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 7, 20, 16),
                  child: Row(
                    children: [
                      IconButton(onPressed: () => Navigator.maybePop(context), icon: Icon(Icons.arrow_back_rounded, color: text)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sw ? 'MAOMBI YALIYOHIFADHIWA' : 'YOUR COLLECTION', style: TextStyle(color: text.withValues(alpha: .5), fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w700)),
                            Text(sw ? 'Vipendwa' : 'Saved prayers', style: TextStyle(color: text, fontSize: 21, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<PrayerFavoritesProvider>(
                    builder: (context, favorites, _) {
                      if (!favorites.isLoaded) return const Center(child: CircularProgressIndicator());
                      if (favorites.items.isEmpty) {
                        return _EmptyFavorites(text: text, sw: sw);
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 26),
                        itemCount: favorites.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _FavoriteTile(prayer: favorites.items[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.prayer});
  final SavedPrayer prayer;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? Colors.white : GlassDesignSystem.deepForestGreen;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: (dark ? const Color(0xFF17344D) : Colors.white).withValues(alpha: .69),
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GlassPrayerDetailScreen(title: prayer.title, content: prayer.content, favoriteId: prayer.id, subtitle: prayer.subtitle))),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: .76))),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 54,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF368AB3), Color(0xFF53C9D2)]), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prayer.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(prayer.subtitle.isEmpty ? prayer.journey : prayer.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text.withValues(alpha: .62), fontSize: 11)),
                        const SizedBox(height: 6),
                        Text(prayer.journey, style: const TextStyle(color: GlassDesignSystem.emerald, fontSize: 10, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove saved prayer',
                    onPressed: () => context.read<PrayerFavoritesProvider>().remove(prayer.id),
                    icon: const Icon(Icons.bookmark_remove_outlined, color: GlassDesignSystem.emerald),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.text, required this.sw});
  final Color text;
  final bool sw;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 88, height: 88, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .55), shape: BoxShape.circle, border: Border.all(color: Colors.white)), child: const Icon(Icons.bookmark_border_rounded, size: 39, color: GlassDesignSystem.emerald)),
              const SizedBox(height: 18),
              Text(sw ? 'Bado hujahifadhi sala' : 'Your collection is waiting', style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 17)),
              const SizedBox(height: 7),
              Text(sw ? 'Gusa alama ya kuhifadhi ukiwa unasoma sala ili iwe rahisi kuipata tena.' : 'Save a prayer while reading it and it will be easy to find here again.', textAlign: TextAlign.center, style: TextStyle(color: text.withValues(alpha: .64), height: 1.5, fontSize: 13)),
            ],
          ),
        ),
      );
}

class _FavoritesBackdrop extends StatelessWidget {
  const _FavoritesBackdrop();
  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: Theme.of(context).brightness == Brightness.dark ? const [Color(0xFF102940), Color(0xFF0B1D30)] : const [Color(0xFFEAF6FC), Color(0xFFF5FAFD)])),
          child: Stack(children: [Positioned(top: -80, right: -75, child: Container(width: 220, height: 220, decoration: BoxDecoration(color: GlassDesignSystem.emerald.withValues(alpha: .1), shape: BoxShape.circle))), Positioned(bottom: 0, left: -140, child: Container(width: 260, height: 260, decoration: BoxDecoration(color: GlassDesignSystem.divineBlue.withValues(alpha: .08), shape: BoxShape.circle)))]),
        ),
      );
}
