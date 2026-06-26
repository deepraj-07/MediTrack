import 'package:flutter/material.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/theme/app_theme.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final List<_FamilyMember> _extraMembers = [];

  List<_FamilyMember> get _members {
    final l = AppLocalizations.of(context)!;
    return [
      _FamilyMember(
        name: l.familyNameWife,
        relation: l.familyRelationWife,
        age: l.familyAgeWife,
        bloodGroup: 'B+',
        emoji: '👩',
        color: const Color(0xFFF43F5E),
        medicines: l.familyMedsWife.split(', '),
      ),
      _FamilyMember(
        name: l.familyNameSon,
        relation: l.familyRelationSon,
        age: l.familyAgeSon,
        bloodGroup: 'O+',
        emoji: '👨',
        color: const Color(0xFF2E82FF),
        medicines: [],
      ),
      _FamilyMember(
        name: l.familyNameDaughterInLaw,
        relation: l.familyRelationDaughterInLaw,
        age: l.familyAgeDaughterInLaw,
        bloodGroup: 'A+',
        emoji: '👩‍🦰',
        color: const Color(0xFF12B76A),
        medicines: [],
      ),
      _FamilyMember(
        name: l.familyNameGrandson,
        relation: l.familyRelationGrandson,
        age: l.familyAgeGrandson,
        bloodGroup: 'O+',
        emoji: '👦',
        color: const Color(0xFFF59E0B),
        medicines: l.familyMedsGrandson.split(', '),
      ),
      ..._extraMembers,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
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
          AppLocalizations.of(context)!.quickFamily.replaceAll('\n', ' '),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.primaryText),
        ),
        centerTitle: false,
        actions: [
            IconButton(
              icon: const Icon(Icons.person_add_rounded, color: Color(0xFF7F56D9)),
              onPressed: () => _showAddMemberDialog(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Hero card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
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
                    child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.quickFamily.replaceAll('\n', ' '),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.memberStatus(_members.length),
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(AppLocalizations.of(context)!.addMember, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Members header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 4, height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F56D9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.familyMembersTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.primaryText),
                ),
                const Spacer(),
                Text(AppLocalizations.of(context)!.memberCount(_members.length), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.secondaryText)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Members list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _members.length,
              itemBuilder: (_, i) => _buildMemberCard(_members[i], i == 0),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addMember),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fullNameLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 12),
            TextField(controller: relationCtrl, decoration: InputDecoration(labelText: 'Relation', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 12),
            TextField(controller: ageCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.age, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final relation = relationCtrl.text.trim();
              final age = ageCtrl.text.trim();
              if (name.isEmpty) return;
              setState(() {
                _extraMembers.add(_FamilyMember(
                  name: name,
                  relation: relation.isNotEmpty ? relation : 'Family',
                  age: age.isNotEmpty ? age : '-',
                  bloodGroup: 'Unknown',
                  emoji: '👤',
                  color: const Color(0xFF7F56D9),
                  medicines: [],
                ));
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${nameCtrl.text} ${AppLocalizations.of(context)!.addMemberSnackbar}'), backgroundColor: const Color(0xFF7F56D9), behavior: SnackBarBehavior.floating),
              );
            },
            child: Text(AppLocalizations.of(context)!.add, style: const TextStyle(color: Color(0xFF7F56D9))),
          ),
        ],
      ),
    );
  }

  void _showMemberDetails(BuildContext context, _FamilyMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(member.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(member.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text('${member.relation} • ${member.age}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Blood Group', style: TextStyle(fontWeight: FontWeight.w600)), Text(member.bloodGroup)]),
            if (member.medicines.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Medicines', style: TextStyle(fontWeight: FontWeight.w600)), Text('${member.medicines.length} ${AppLocalizations.of(context)!.medicinesTitle}')]),
            ],
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.close))],
      ),
    );
  }

  Widget _buildMemberCard(_FamilyMember member, bool isSelf) {
    final c = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: () => _showMemberDetails(context, member),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: member.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(member.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                if (isSelf)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7F56D9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.primaryText),
                      ),
                      if (isSelf) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(AppLocalizations.of(context)!.self, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF7F56D9))),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${member.relation} • ${member.age}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.secondaryText),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.scaffoldBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${AppLocalizations.of(context)!.bloodGroup} ${member.bloodGroup}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.secondaryText),
                        ),
                      ),
                      if (member.medicines.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '💊 ${AppLocalizations.of(context)!.medicinesCount(member.medicines.length)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF97316)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F5FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF7F56D9), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyMember {
  final String name;
  final String relation;
  final String age;
  final String bloodGroup;
  final String emoji;
  final Color color;
  final List<String> medicines;

  const _FamilyMember({
    required this.name,
    required this.relation,
    required this.age,
    required this.bloodGroup,
    required this.emoji,
    required this.color,
    required this.medicines,
  });
}
