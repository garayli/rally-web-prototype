import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';

class ReputationScreen extends StatelessWidget {
  final Player? player;  // null = viewing own reputation

  const ReputationScreen({super.key, this.player});

  static List<_Review> _reviews(AppLocalizations l) => [
    _Review(
      reviewerInitials: 'EK',
      reviewerName: 'Emre Kaya',
      gradientStart: '#e85d3a',
      gradientEnd: '#f4956d',
      rating: 5,
      comment: l.reviewCommentEmre,
      date: DateTime.now().subtract(const Duration(days: 3)),
      tags: [l.reviewTagPunctual, l.reviewTagSporty, l.reviewTagGoodComm],
    ),
    _Review(
      reviewerInitials: 'SD',
      reviewerName: 'Selin Demir',
      gradientStart: '#7b4fa6',
      gradientEnd: '#a97fcb',
      rating: 5,
      comment: l.reviewCommentSelin,
      date: DateTime.now().subtract(const Duration(days: 14)),
      tags: [l.reviewTagPunctual, l.reviewTagFairPlay],
    ),
    _Review(
      reviewerInitials: 'ZA',
      reviewerName: 'Zeynep Arslan',
      gradientStart: '#5a8a00',
      gradientEnd: '#8db600',
      rating: 4,
      comment: l.reviewCommentZeynep,
      date: DateTime.now().subtract(const Duration(days: 28)),
      tags: [l.reviewTagCompetitive, l.reviewTagFriendly],
    ),
    _Review(
      reviewerInitials: 'BÖ',
      reviewerName: 'Berk Öztürk',
      gradientStart: '#1a7abf',
      gradientEnd: '#5ba8e0',
      rating: 5,
      comment: l.reviewCommentBerk,
      date: DateTime.now().subtract(const Duration(days: 45)),
      tags: [l.reviewTagHelpful, l.reviewTagFriendly],
    ),
  ];

  static double _avgRating(List<_Review> reviews) =>
      reviews.fold(0.0, (s, r) => s + r.rating) / reviews.length;

  static Map<int, int> _ratingCounts(List<_Review> reviews) {
    final m = <int, int>{};
    for (final r in reviews) {
      m[r.rating] = (m[r.rating] ?? 0) + 1;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final reviews = _reviews(l);
    final avgRating = _avgRating(reviews);
    final ratingCounts = _ratingCounts(reviews);

    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: Text(
          player == null
              ? l.reputationMine
              : l.reputationOf(player!.name.split(' ').first),
          style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Rating summary ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RallyColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RallyColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 52, letterSpacing: -2, height: 1),
                      ),
                      _StarRow(rating: avgRating.round(), size: 20),
                      const SizedBox(height: 4),
                      Text(
                        l.reviewsCount(reviews.length),
                        style: const TextStyle(fontSize: 12, color: RallyColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (i) {
                        final stars = 5 - i;
                        final count = ratingCounts[stars] ?? 0;
                        final pct = reviews.isEmpty ? 0.0 : count / reviews.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text('$stars', style: const TextStyle(fontSize: 11, color: RallyColors.muted, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              const Icon(Icons.star, size: 10, color: Color(0xFFFFD700)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: RallyColors.surface2,
                                    valueColor: const AlwaysStoppedAnimation(RallyColors.accent),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('$count', style: const TextStyle(fontSize: 11, color: RallyColors.muted)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
          ),

          // ── Reviews ────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ReviewCard(review: reviews[i]).animate().fadeIn(delay: (i * 60).ms),
                childCount: reviews.length,
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RallyColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RallyColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlayerAvatar(
                initials: review.reviewerInitials,
                gradientStart: review.gradientStart,
                gradientEnd: review.gradientEnd,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    _StarRow(rating: review.rating, size: 14),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM d', context.localeName).format(review.date),
                style: const TextStyle(fontSize: 11, color: RallyColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${review.comment}"',
            style: const TextStyle(fontSize: 14, height: 1.5, color: RallyColors.textSecondary, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: review.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: RallyColors.accentLight,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: RallyColors.accent)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int rating;
  final double size;
  const _StarRow({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < rating ? Icons.star : Icons.star_border,
        size: size,
        color: const Color(0xFFFFD700),
      )),
    );
  }
}

class _Review {
  final String reviewerInitials;
  final String reviewerName;
  final String gradientStart;
  final String gradientEnd;
  final int rating;
  final String comment;
  final DateTime date;
  final List<String> tags;

  const _Review({
    required this.reviewerInitials,
    required this.reviewerName,
    required this.gradientStart,
    required this.gradientEnd,
    required this.rating,
    required this.comment,
    required this.date,
    required this.tags,
  });
}
