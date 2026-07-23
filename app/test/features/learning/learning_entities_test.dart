import 'package:chronos/features/learning/domain/entities/learning_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudyRecord', () {
    test('fromJson/toJson roundtrip', () {
      final record = StudyRecord(
        id: 'r1',
        userId: 'user1',
        entityId: 'char_1',
        entityType: 'character',
        entityName: 'Cleópatra',
        activityType: StudyActivityType.read,
        durationSeconds: 120,
        startedAt: DateTime(2025, 7, 23, 10, 0),
      );
      final json = record.toJson();
      final restored = StudyRecord.fromJson(json);
      expect(restored.entityName, 'Cleópatra');
      expect(restored.activityType, StudyActivityType.read);
      expect(restored.durationSeconds, 120);
    });
  });

  group('StudyProgress', () {
    test('fromJson/toJson roundtrip', () {
      final progress = StudyProgress(
        id: 'p1',
        userId: 'user1',
        entityId: 'char_1',
        entityType: 'character',
        entityName: 'César',
        status: StudyStatus.inProgress,
        totalReadTimeSeconds: 300,
        viewCount: 3,
        firstAccess: DateTime(2025, 7, 20),
        lastAccess: DateTime(2025, 7, 23),
      );
      final json = progress.toJson();
      final restored = StudyProgress.fromJson(json);
      expect(restored.status, StudyStatus.inProgress);
      expect(restored.viewCount, 3);
    });

    test('copyWith preserves unchanged fields', () {
      final progress = StudyProgress(
        id: 'p1',
        userId: 'user1',
        entityId: 'char_1',
        entityType: 'character',
        entityName: 'Test',
        firstAccess: DateTime(2025, 1, 1),
        lastAccess: DateTime(2025, 1, 1),
        viewCount: 5,
      );
      final updated = progress.copyWith(viewCount: 6, status: StudyStatus.studied);
      expect(updated.viewCount, 6);
      expect(updated.status, StudyStatus.studied);
      expect(updated.entityName, 'Test');
    });
  });

  group('ReviewSchedule', () {
    test('fromJson/toJson', () {
      final review = ReviewSchedule(
        id: 'rev1',
        userId: 'user1',
        entityId: 'char_1',
        entityType: 'character',
        entityName: 'Napoleão',
        scheduledFor: DateTime(2025, 7, 24),
        intervalDays: 3,
        repetition: 1,
      );
      final json = review.toJson();
      final restored = ReviewSchedule.fromJson(json);
      expect(restored.intervalDays, 3);
      expect(restored.repetition, 1);
      expect(restored.completed, false);
    });
  });

  group('QuizQuestion', () {
    test('fromJson/toJson', () {
      final q = QuizQuestion(
        id: 'q1',
        entityId: 'char_cleo',
        entityType: 'character',
        question: 'Qual civilização ela governou?',
        options: ['Egito', 'Roma', 'Grécia', 'Pérsia'],
        correctIndex: 0,
        explanation: 'Cleópatra foi a última faraó do Egito.',
      );
      final json = q.toJson();
      final restored = QuizQuestion.fromJson(json);
      expect(restored.options, hasLength(4));
      expect(restored.correctIndex, 0);
    });
  });

  group('StudyGoal', () {
    test('progress calculation', () {
      final goal = StudyGoal(
        id: 'g1',
        userId: 'user1',
        title: 'Ler 3 personagens',
        type: GoalType.readCharacters,
        targetValue: 3,
        currentValue: 2,
        createdAt: DateTime(2025, 7, 23),
      );
      expect(goal.progress, closeTo(0.666, 0.01));
    });
  });

  group('Achievement', () {
    test('progress calculation', () {
      const a = Achievement(
        id: 'a1',
        code: 'first_character',
        title: 'Primeiro Personagem',
        requiredValue: 1,
        currentValue: 0,
      );
      expect(a.progress, 0.0);
      expect(a.unlocked, false);
    });
  });

  group('UserStudyStats', () {
    test('quizAccuracy', () {
      const stats = UserStudyStats(
        userId: 'user1',
        totalQuizAnswered: 10,
        totalQuizCorrect: 7,
      );
      expect(stats.quizAccuracy, 0.7);
    });

    test('totalStudyTime', () {
      const stats = UserStudyStats(
        userId: 'user1',
        totalStudyTimeSeconds: 3600,
      );
      expect(stats.totalStudyTime.inHours, 1);
    });
  });

  group('UserLevel', () {
    test('values exist', () {
      expect(UserLevel.values, hasLength(6));
    });
  });

  group('StudyChallenge', () {
    test('progress and isExpired', () {
      final challenge = StudyChallenge(
        id: 'c1',
        userId: 'user1',
        title: 'Ler 5 conteúdos',
        type: ChallengeType.daily,
        targetValue: 5,
        currentValue: 3,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 12)),
      );
      expect(challenge.progress, closeTo(0.6, 0.01));
      expect(challenge.isExpired, false);
    });
  });
}
