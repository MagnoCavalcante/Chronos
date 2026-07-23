import 'package:chronos/core/gamification/gamification_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GamificationModels', () {
    test('UserProfile serializes and deserializes', () {
      final now = DateTime.now().toUtc();
      final profile = UserProfile(
        id: 'p1',
        userId: 'u1',
        displayName: 'Test',
        totalXp: 100,
        currentLevel: 2,
        streakDays: 3,
        joinedAt: now,
        updatedAt: now,
      );
      final json = profile.toJson();
      final restored = UserProfile.fromJson(json);
      expect(restored.userId, 'u1');
      expect(restored.totalXp, 100);
      expect(restored.currentLevel, 2);
      expect(restored.streakDays, 3);
    });

    test('Achievement serializes and deserializes', () {
      final achievement = Achievement(
        id: 'a1',
        slug: 'first_study',
        name: 'Primeiro Estudo',
        description: 'Comece a estudar',
        category: AchievementCategory.study,
        criteriaType: AchievementCriteriaType.firstStudy,
        criteriaValue: 1,
        xpReward: 10,
      );
      final json = achievement.toJson();
      final restored = Achievement.fromJson(json);
      expect(restored.slug, 'first_study');
      expect(restored.category, AchievementCategory.study);
      expect(restored.criteriaType, AchievementCriteriaType.firstStudy);
    });

    test('UserAchievement progressPercent clamps to 1.0', () {
      final achievement = Achievement(
        id: 'a1',
        slug: 'collector',
        name: 'Colecionador',
        category: AchievementCategory.collection,
        criteriaType: AchievementCriteriaType.completeCount,
        criteriaValue: 5,
        xpReward: 20,
      );
      final ua = UserAchievement(
        userId: 'u1',
        achievementId: 'a1',
        achievement: achievement,
        progress: 10,
      );
      expect(ua.progressPercent, 1.0);
    });

    test('Challenge progressPercent is correct', () {
      final challenge = Challenge(
        id: 'c1',
        userId: 'u1',
        type: ChallengeType.daily,
        title: 'Estude 5 minutos',
        criteriaType: ChallengeCriteriaType.studyMinutes,
        targetValue: 5,
        currentValue: 2,
        startsAt: DateTime.now(),
        endsAt: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      );
      expect(challenge.progressPercent, closeTo(0.4, 0.001));
    });

    test('XpSource maps to api value and back', () {
      expect(XpSource.completeStudy.apiValue, 'complete_study');
      expect(XpSource.fromString('complete_collection'), XpSource.completeCollection);
    });

    test('ChallengeType fromString defaults to daily for unknown', () {
      expect(ChallengeType.fromString('unknown'), ChallengeType.daily);
    });
  });
}
