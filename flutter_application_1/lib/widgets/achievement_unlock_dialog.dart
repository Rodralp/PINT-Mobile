import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/achievement_center.dart';

class AchievementUnlockDialog extends StatefulWidget {
  const AchievementUnlockDialog({
    super.key,
    required this.achievement,
  });

  final AchievementUnlock achievement;

  @override
  State<AchievementUnlockDialog> createState() => _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog> {
  late final ConfettiController _leftConfettiController;
  late final ConfettiController _rightConfettiController;

  @override
  void initState() {
    super.initState();
    _leftConfettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _rightConfettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _leftConfettiController.play();
    _rightConfettiController.play();
  }

  @override
  void dispose() {
    _leftConfettiController.dispose();
    _rightConfettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievement;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 64),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E8EF9), Color(0xFF0F73D8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcomeAchievementTitle,
                        style: const TextStyle(
                          fontSize: 42 / 2,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.welcomeAchievementDescription,
                        style: const TextStyle(
                          fontSize: 24 / 2,
                          color: Color(0xFFE8F4FF),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 58, 16, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 56, 14, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E8EF9), width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 14,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          achievement.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 38 / 2,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            achievement.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '+${achievement.points}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF1E8EF9),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppLocalizations.of(context)!.points,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 38,
                              color: const Color(0xFFE2E8F0),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${achievement.badgesCount}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF111827),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppLocalizations.of(context)!.badges,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E8EF9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.close,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 126,
            left: 0,
            right: 0,
            child: Center(
              child: _roundBadgeImage(achievement.imageAsset),
            ),
          ),
          Positioned(
            top: 10,
            left: 20,
            child: Icon(Icons.auto_awesome, color: Colors.yellow[300], size: 28),
          ),
          Positioned(
            top: 22,
            right: 24,
            child: Icon(Icons.auto_awesome, color: Colors.yellow[300], size: 24),
          ),
          Positioned(
            top: 0,
            left: 6,
            child: ConfettiWidget(
              confettiController: _leftConfettiController,
              blastDirection: pi / 4,
              emissionFrequency: 0.02,
              numberOfParticles: 18,
              shouldLoop: false,
              maxBlastForce: 18,
              minBlastForce: 8,
              gravity: 0.25,
            ),
          ),
          Positioned(
            top: 0,
            right: 6,
            child: ConfettiWidget(
              confettiController: _rightConfettiController,
              blastDirection: 3 * pi / 4,
              emissionFrequency: 0.02,
              numberOfParticles: 18,
              shouldLoop: false,
              maxBlastForce: 18,
              minBlastForce: 8,
              gravity: 0.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundBadgeImage(String? imageAsset) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD67F45), width: 8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: imageAsset != null
            ? Image.asset(imageAsset, fit: BoxFit.cover)
            : Container(
                color: const Color(0xFFFFE1C9),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFD67F45),
                  size: 52,
                ),
              ),
      ),
    );
  }
}
