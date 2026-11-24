import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';

class ReviewItem {
  final String authorName;
  final String location;
  final double rating;
  final String date;
  final String commentEn;
  final String commentKm;
  final bool isVerified;

  const ReviewItem({
    required this.authorName,
    required this.location,
    required this.rating,
    required this.date,
    required this.commentEn,
    required this.commentKm,
    this.isVerified = true,
  });
}

class ReviewsListView extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final bool isKhmer;

  const ReviewsListView({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.isKhmer,
  });

  static const List<ReviewItem> sampleReviews = [
    ReviewItem(
      authorName: 'Sophea N.',
      location: 'Boeng Keng Kang 1, Phnom Penh',
      rating: 5.0,
      date: '14 Nov 2026',
      commentEn:
          'Incredible drape and craftsmanship. The fabric feels luxurious and breathable in Phnom Penh weather. Delivered within 3 hours by express courier!',
      commentKm:
          'សាច់ក្រណាត់ទន់រលោងប្រណីតណាស់ ត្រជាក់ស្រួលពាក់ក្នុងរាជធានីភ្នំពេញ។ សេវាដឹកជញ្ជូនរហ័សត្រឹមតែ 3 ម៉ោងប៉ុណ្ណោះ!',
    ),
    ReviewItem(
      authorName: 'Dara K.',
      location: 'Tuol Kork, Phnom Penh',
      rating: 5.0,
      date: '02 Nov 2026',
      commentEn:
          'The tailoring is impeccable. Fits true to size and looks even better in person than in the photos. Highly recommended for formal occasions.',
      commentKm:
          'ការកាត់ដេរស្អាតផ្ចិតផ្ចង់ឥតខ្ចោះ។ ទំហំត្រូវស្តង់ដារ និងស្អាតជាងរូបថតទៅទៀត។ ស័ក្តិសមបំផុតសម្រាប់ពិធីផ្លូវការ។',
    ),
    ReviewItem(
      authorName: 'Chanlina V.',
      location: 'Wat Bo, Siem Reap',
      rating: 4.8,
      date: '28 Oct 2026',
      commentEn:
          'Ordered to Siem Reap via Virak Buntham and arrived safely packed in a luxury gift box within 24 hours. The silk sheen is breathtaking.',
      commentKm:
          'បានកុម្ម៉ង់ទៅសៀមរាបតាមវីរៈប៊ុនថាំ ទទួលបានក្នុងរយៈពេល 24 ម៉ោង ខ្ចប់ក្នុងប្រអប់កាដូយ៉ាងប្រណីត។ ពណ៌សូត្ររលោងស្អាតខ្លាំងណាស់។',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Summary Header
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$rating',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, height: 1.1),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => const Icon(Icons.star, size: 16, color: AppColors.luxuryBeige),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$reviewCount ${isKhmer ? "ការវាយតម្លៃ" : "verified reviews"}',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(width: 28),
            // Progress distribution
            Expanded(
              child: Column(
                children: [
                  _buildRatingBar('5★', 0.92),
                  const SizedBox(height: 3),
                  _buildRatingBar('4★', 0.08),
                  const SizedBox(height: 3),
                  _buildRatingBar('3★', 0.0),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(),

        // Reviews List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sampleReviews.length,
          separatorBuilder: (context, index) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final rev = sampleReviews[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          rev.authorName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        if (rev.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, size: 14, color: AppColors.success),
                          const SizedBox(width: 2),
                          Text(
                            isKhmer ? 'បានទិញពិត' : 'Verified',
                            style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      rev.date,
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  rev.location,
                  style: TextStyle(fontSize: 11, color: AppColors.luxuryBeigeDark),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (starIdx) => Icon(
                      starIdx < rev.rating.round() ? Icons.star : Icons.star_border,
                      size: 13,
                      color: AppColors.luxuryBeige,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isKhmer ? rev.commentKm : rev.commentEn,
                  style: AppTypography.bodySmall(isKhmer: isKhmer, color: AppColors.textPrimary),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRatingBar(String label, double ratio) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: AppColors.warmSand,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlack),
            ),
          ),
        ),
      ],
    );
  }
}
