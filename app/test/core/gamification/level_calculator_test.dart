import 'package:chronos/core/gamification/gamification_models.dart';
import 'package:chronos/core/gamification/level_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelCalculator', () {
    test('xpForLevel returns 0 for level 1', () {
      expect(LevelCalculator.xpForLevel(1), 0);
    });

    test('xpForLevel increases progressively', () {
      expect(LevelCalculator.xpForLevel(2), 100);
      expect(LevelCalculator.xpForLevel(3), 250);
      expect(LevelCalculator.xpForLevel(4), 500);
      expect(LevelCalculator.xpForLevel(5), 850);
    });

    test('levelFromXp returns correct level boundaries', () {
      expect(LevelCalculator.levelFromXp(0), 1);
      expect(LevelCalculator.levelFromXp(99), 1);
      expect(LevelCalculator.levelFromXp(100), 2);
      expect(LevelCalculator.levelFromXp(249), 2);
      expect(LevelCalculator.levelFromXp(250), 3);
      expect(LevelCalculator.levelFromXp(500), 4);
    });

    test('xpToNextLevel returns remaining XP', () {
      expect(LevelCalculator.xpToNextLevel(0), 100);
      expect(LevelCalculator.xpToNextLevel(50), 50);
      expect(LevelCalculator.xpToNextLevel(100), 150);
    });

    test('levelProgress returns value between 0 and 1', () {
      expect(LevelCalculator.levelProgress(0), 0.0);
      expect(LevelCalculator.levelProgress(100), closeTo(0.0, 0.01));
      expect(LevelCalculator.levelProgress(175), closeTo(0.5, 0.01));
      expect(LevelCalculator.levelProgress(250), 0.0);
    });

    test('titleForProgress selects highest matching title', () {
      final titles = [
        const Title(id: '1', slug: 'novice', name: 'Novice', minLevel: 1, minXp: 0),
        const Title(id: '2', slug: 'apprentice', name: 'Apprentice', minLevel: 2, minXp: 100),
        const Title(id: '3', slug: 'expert', name: 'Expert', minLevel: 3, minXp: 300),
      ];
      expect(LevelCalculator.titleForProgress(titles, 1, 0)?.slug, 'novice');
      expect(LevelCalculator.titleForProgress(titles, 2, 100)?.slug, 'apprentice');
      expect(LevelCalculator.titleForProgress(titles, 3, 300)?.slug, 'expert');
      expect(LevelCalculator.titleForProgress(titles, 3, 299)?.slug, 'apprentice');
    });
  });
}
