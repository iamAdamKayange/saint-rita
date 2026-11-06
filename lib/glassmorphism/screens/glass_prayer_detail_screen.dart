import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/provider/prayer_favorites_provider.dart';

class GlassPrayerDetailScreen extends StatefulWidget {
  const GlassPrayerDetailScreen({
    super.key,
    required this.title,
    required this.content,
    this.favoriteId,
    this.subtitle = '',
    this.journey = '',
  });

  final String title;
  final String content;
  final String? favoriteId;
  final String subtitle;
  final String journey;

  @override
  State<GlassPrayerDetailScreen> createState() => _GlassPrayerDetailScreenState();
}

class _GlassPrayerDetailScreenState extends State<GlassPrayerDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _progress = 0;
  double _fontSize = 17;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (!_scrollController.hasClients) return;
    final extent = _scrollController.position.maxScrollExtent;
    final value = extent == 0 ? 1.0 : _scrollController.offset / extent;
    if ((value - _progress).abs() > .03 && mounted) {
      setState(() => _progress = value.clamp(0, 1).toDouble());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProgress);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? Colors.white : GlassDesignSystem.deepForestGreen;
    final favoriteId = widget.favoriteId;
    final favoriteProvider = context.watch<PrayerFavoritesProvider>();
    final isSaved = favoriteId != null && favoriteProvider.contains(favoriteId);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const _ReadingBackdrop(),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.transparent,
                foregroundColor: text,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(68, 0, 18, 18),
                  title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w700)),
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 68, 20, 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF235F83), Color(0xFF31B3C3)]))),
                          Positioned(right: 12, bottom: -16, child: Icon(Icons.auto_stories_rounded, size: 112, color: Colors.white.withValues(alpha: .13))),
                          Padding(
                            padding: const EdgeInsets.all(19),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(widget.journey.toUpperCase(), style: const TextStyle(color: Color(0xFFB9F0F0), fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w700)),
                                if (widget.subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(widget.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (favoriteId != null)
                    IconButton(
                      tooltip: isSaved ? 'Remove saved prayer' : 'Save prayer',
                      onPressed: () => context.read<PrayerFavoritesProvider>().toggle(
                        SavedPrayer(
                          id: favoriteId,
                          title: widget.title,
                          subtitle: widget.subtitle,
                          content: widget.content,
                          journey: widget.journey,
                        ),
                      ),
                      icon: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: isSaved ? GlassDesignSystem.emerald : text),
                    ),
                  IconButton(
                    tooltip: 'Share prayer',
                    onPressed: () => Share.share('${widget.title}\n\n${widget.content}'),
                    icon: Icon(Icons.ios_share_rounded, color: text),
                  ),
                  PopupMenuButton<double>(
                    tooltip: 'Text size',
                    icon: Icon(Icons.text_fields_rounded, color: text),
                    onSelected: (size) => setState(() => _fontSize = size),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 15, child: Text('Small text')),
                      PopupMenuItem(value: 17, child: Text('Regular text')),
                      PopupMenuItem(value: 20, child: Text('Large text')),
                      PopupMenuItem(value: 23, child: Text('Extra large text')),
                    ],
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: _progress, minHeight: 5, backgroundColor: text.withValues(alpha: .1), valueColor: const AlwaysStoppedAnimation(GlassDesignSystem.emerald))),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(22, 25, 22, 27),
                            decoration: BoxDecoration(color: (dark ? const Color(0xFF17344D) : Colors.white).withValues(alpha: .71), border: Border.all(color: Colors.white.withValues(alpha: .78)), borderRadius: BorderRadius.circular(25)),
                            child: SelectableText(widget.content, style: TextStyle(color: text.withValues(alpha: .87), fontSize: _fontSize, height: 1.8, letterSpacing: .05)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(Icons.spa_outlined, size: 17, color: GlassDesignSystem.emerald),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Take your time. Return to these words whenever you need.', style: TextStyle(color: text.withValues(alpha: .57), fontSize: 12, height: 1.45))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadingBackdrop extends StatelessWidget {
  const _ReadingBackdrop();
  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: Theme.of(context).brightness == Brightness.dark ? const [Color(0xFF102940), Color(0xFF0B1D30)] : const [Color(0xFFEAF6FC), Color(0xFFF5FAFD)])),
          child: Stack(children: [Positioned(top: 40, right: -80, child: Container(width: 220, height: 220, decoration: BoxDecoration(color: GlassDesignSystem.emerald.withValues(alpha: .09), shape: BoxShape.circle))), Positioned(bottom: 70, left: -150, child: Container(width: 270, height: 270, decoration: BoxDecoration(color: GlassDesignSystem.divineBlue.withValues(alpha: .08), shape: BoxShape.circle)))]),
        ),
      );
}
