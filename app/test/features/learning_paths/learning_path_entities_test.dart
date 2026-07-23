import 'package:chronos/features/learning_paths/domain/entities/learning_path_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LearningPath', () {
    test('fromJson/toJson roundtrip', () {
      final path = LearningPath(
        id: 'p1',
        name: 'Egito Antigo',
        description: 'Explore o Egito.',
        category: PathCategory.antiquity,
        difficulty: PathDifficulty.beginner,
        estimatedMinutes: 90,
        totalModules: 3,
        totalContents: 9,
        xpReward: 200,
        createdAt: DateTime(2025, 7, 23),
      );
      final json = path.toJson();
      final restored = LearningPath.fromJson(json);
      expect(restored.name, 'Egito Antigo');
      expect(restored.category, PathCategory.antiquity);
      expect(restored.difficulty, PathDifficulty.beginner);
      expect(restored.totalModules, 3);
    });
  });

  group('PathModule', () {
    test('fromJson/toJson roundtrip', () {
      const module = PathModule(
        id: 'm1',
        pathId: 'p1',
        title: 'Surgimento do Egito',
        order: 1,
        totalContents: 3,
      );
      final json = module.toJson();
      final restored = PathModule.fromJson(json);
      expect(restored.title, 'Surgimento do Egito');
      expect(restored.order, 1);
    });
  });

  group('PathContent', () {
    test('fromJson/toJson roundtrip', () {
      const content = PathContent(
        id: 'c1',
        moduleId: 'm1',
        entityId: 'char_narmer',
        entityType: 'character',
        entityName: 'Narmer',
        contentType: PathContentType.text,
        order: 1,
      );
      final json = content.toJson();
      final restored = PathContent.fromJson(json);
      expect(restored.entityName, 'Narmer');
      expect(restored.contentType, PathContentType.text);
    });
  });

  group('PathProgress', () {
    test('progressPercent', () {
      final progress = PathProgress(
        id: 'pp1',
        userId: 'user1',
        pathId: 'p1',
        pathName: 'Egito',
        completedContents: 3,
        totalContents: 9,
        startedAt: DateTime(2025, 7, 20),
        lastAccessAt: DateTime(2025, 7, 23),
      );
      expect(progress.progressPercent, closeTo(0.333, 0.01));
    });

    test('fromJson/toJson', () {
      final progress = PathProgress(
        id: 'pp1',
        userId: 'user1',
        pathId: 'p1',
        pathName: 'Roma',
        status: PathStatus.inProgress,
        completedModules: 1,
        completedContents: 3,
        totalModules: 3,
        totalContents: 9,
        startedAt: DateTime(2025, 7, 20),
        lastAccessAt: DateTime(2025, 7, 23),
      );
      final json = progress.toJson();
      final restored = PathProgress.fromJson(json);
      expect(restored.status, PathStatus.inProgress);
      expect(restored.completedModules, 1);
    });
  });

  group('ModuleProgress', () {
    test('progressPercent', () {
      const mp = ModuleProgress(
        id: 'mp1',
        userId: 'user1',
        moduleId: 'm1',
        pathId: 'p1',
        status: ModuleStatus.inProgress,
        completedContents: 2,
        totalContents: 3,
      );
      expect(mp.progressPercent, closeTo(0.666, 0.01));
    });

    test('locked status', () {
      const mp = ModuleProgress(
        id: 'mp2',
        userId: 'user1',
        moduleId: 'm2',
        pathId: 'p1',
        status: ModuleStatus.locked,
      );
      expect(mp.status, ModuleStatus.locked);
    });
  });

  group('PathCertificate', () {
    test('fromJson/toJson', () {
      final cert = PathCertificate(
        id: 'cert1',
        userId: 'user1',
        userName: 'Magno',
        pathId: 'p1',
        pathName: 'Egito Antigo',
        completedAt: DateTime(2025, 7, 23),
        totalTimeSeconds: 5400,
        totalContentsCompleted: 9,
        xpEarned: 200,
      );
      final json = cert.toJson();
      final restored = PathCertificate.fromJson(json);
      expect(restored.userName, 'Magno');
      expect(restored.xpEarned, 200);
    });
  });

  group('Enums', () {
    test('PathCategory values', () {
      expect(PathCategory.values.length, 12);
    });

    test('PathDifficulty values', () {
      expect(PathDifficulty.values.length, 4);
    });

    test('ModuleStatus values', () {
      expect(ModuleStatus.values, contains(ModuleStatus.locked));
      expect(ModuleStatus.values, contains(ModuleStatus.unlocked));
      expect(ModuleStatus.values, contains(ModuleStatus.completed));
    });
  });
}
