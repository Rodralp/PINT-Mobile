import 'dart:async';

class AchievementUnlock {
  const AchievementUnlock({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.badgesCount,
    this.imageAsset,
    this.badgeName,
    this.levelKey,
  });

  final String id;
  final String title;
  final String description;
  final int points;
  final int badgesCount;
  final String? imageAsset;
  final String? badgeName;
  final String? levelKey;
}

class AchievementCenter {
  AchievementCenter._();

  static final AchievementCenter instance = AchievementCenter._();

  final StreamController<AchievementUnlock> _controller =
      StreamController<AchievementUnlock>.broadcast();
  final List<AchievementUnlock> _pending = [];

  Stream<AchievementUnlock> get stream => _controller.stream;

  void unlock(AchievementUnlock achievement) {
    if (_controller.hasListener) {
      _controller.add(achievement);
      return;
    }
    _pending.add(achievement);
  }

  List<AchievementUnlock> takePending() {
    if (_pending.isEmpty) {
      return const [];
    }
    final items = List<AchievementUnlock>.from(_pending);
    _pending.clear();
    return items;
  }
}
