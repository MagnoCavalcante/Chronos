import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/study/study_models.dart';

void main() {
  group('StudyStatus', () {
    test('converte para e de apiValue corretamente', () {
      expect(StudyStatus.notStarted.apiValue, 'not_started');
      expect(StudyStatus.inStudy.apiValue, 'in_study');
      expect(StudyStatus.completed.apiValue, 'completed');
      expect(StudyStatus.review.apiValue, 'review');
      expect(StudyStatusExtension.fromString('in_study'), StudyStatus.inStudy);
      expect(StudyStatusExtension.fromString('desconhecido'), StudyStatus.notStarted);
    });

    test('labels estão preenchidos', () {
      for (final s in StudyStatus.values) {
        expect(s.label.isNotEmpty, isTrue);
      }
    });
  });

  group('Collection', () {
    final json = {
      'id': 'col-1',
      'user_id': 'user-1',
      'slug': 'roma-antiga',
      'title': 'Roma Antiga',
      'description': 'Coleção sobre Roma',
      'cover_url': 'https://example.com/roma.png',
      'is_public': true,
      'ativo': true,
      'created_at': '2026-07-22T00:00:00.000Z',
      'updated_at': '2026-07-22T00:00:00.000Z',
    };

    test('fromJson cria modelo completo', () {
      final collection = Collection.fromJson(json);
      expect(collection.id, 'col-1');
      expect(collection.title, 'Roma Antiga');
      expect(collection.isPublic, isTrue);
    });

    test('toJson serializa campos principais', () {
      final collection = Collection.fromJson(json);
      final out = collection.toJson();
      expect(out['title'], 'Roma Antiga');
      expect(out['slug'], 'roma-antiga');
    });
  });

  group('StudyGoal', () {
    final json = {
      'id': 'goal-1',
      'user_id': 'user-1',
      'title': 'Ler 5 livros',
      'target_type': 'books',
      'target_value': 5,
      'current_value': 2,
      'completed': false,
      'deadline': '2026-12-31T00:00:00.000Z',
      'created_at': '2026-07-22T00:00:00.000Z',
      'updated_at': '2026-07-22T00:00:00.000Z',
    };

    test('fromJson mantém progresso', () {
      final goal = StudyGoal.fromJson(json);
      expect(goal.currentValue, 2);
      expect(goal.targetValue, 5);
      expect(goal.completed, isFalse);
    });
  });
}
