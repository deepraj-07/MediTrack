import 'package:flutter/material.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/theme/app_theme.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  int _expandedCategory = -1;

  List<_TipCategory> _buildCategories(AppLocalizations l) {
    return [
      _TipCategory(
        name: l.catDiabetes,
        icon: Icons.bloodtype_rounded,
        color: const Color(0xFF3B82F6),
        tips: [
          _HealthTip(l.tipRegularCheckup, l.tipRegularCheckupDesc, '📊', false),
          _HealthTip(l.tipDiet, l.tipDietDesc, '🥗', true),
          _HealthTip(l.tipExercise, l.tipExerciseDesc, '🚶', false),
        ],
      ),
      _TipCategory(
        name: l.catHeart,
        icon: Icons.favorite_rounded,
        color: const Color(0xFFF43F5E),
        tips: [
          _HealthTip(l.tipBpControl, l.tipBpControlDesc, '❤️', false),
          _HealthTip(l.tipCholesterol, l.tipCholesterolDesc, '🥬', true),
          _HealthTip(l.tipStressFree, l.tipStressFreeDesc, '🧘', false),
        ],
      ),
      _TipCategory(
        name: l.catNutrition,
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFF59E0B),
        tips: [
          _HealthTip(l.tipBalancedDiet, l.tipBalancedDietDesc, '🍎', false),
          _HealthTip(l.tipDrinkWater, l.tipDrinkWaterDesc, '💧', true),
          _HealthTip(l.tipEatOnTime, l.tipEatOnTimeDesc, '⏰', false),
        ],
      ),
      _TipCategory(
        name: l.catMedicine,
        icon: Icons.medication_rounded,
        color: const Color(0xFF7F56D9),
        tips: [
          _HealthTip(l.tipMedicineOnTime, l.tipMedicineOnTimeDesc, '💊', false),
          _HealthTip(l.tipConsultDoctor, l.tipConsultDoctorDesc, '👨‍⚕️', true),
          _HealthTip(l.tipMedicineList, l.tipMedicineListDesc, '📋', false),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    final categories = _buildCategories(l);
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.primaryText, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.quickTips.replaceAll('\n', ' '),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.primaryText),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeroSection(l, categories);
          final cat = categories[index - 1];
          final isExpanded = _expandedCategory == index - 1;
          return _buildCategoryCard(l, cat, isExpanded, index - 1);
        },
      ),
    );
  }

  Widget _buildHeroSection(AppLocalizations l, List<_TipCategory> categories) {
    final categoriesCount = categories.length;
    final tipsCount = categories.fold(0, (sum, c) => sum + c.tips.length);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F56D9), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7F56D9).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.healthyLivingTips,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  l.tipsHeroSubtitle(categoriesCount.toString(), tipsCount.toString()),
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(AppLocalizations l, _TipCategory cat, bool isExpanded, int catIndex) {
    final c = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategory = isExpanded ? -1 : catIndex;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.primaryText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.tipsCount('${cat.tips.length}'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: cat.color, size: 24),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(color: c.border, height: 1),
                ...cat.tips.map((tip) => _buildTipTile(tip)),
              ],
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildTipTile(_HealthTip tip) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: c.scaffoldBg,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(tip.emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.primaryText),
                ),
                const SizedBox(height: 2),
                Text(
                  tip.desc,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.secondaryText),
                ),
              ],
            ),
          ),
          if (tip.isFavorite)
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_rounded, color: Color(0xFFF59E0B), size: 14),
            ),
        ],
      ),
    );
  }
}

class _TipCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<_HealthTip> tips;

  const _TipCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.tips,
  });
}

class _HealthTip {
  final String title;
  final String desc;
  final String emoji;
  final bool isFavorite;

  const _HealthTip(this.title, this.desc, this.emoji, this.isFavorite);
}
