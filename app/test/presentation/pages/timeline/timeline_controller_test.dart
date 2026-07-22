import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/presentation/pages/timeline/timeline_controller.dart';
import 'package:chronos/presentation/pages/timeline/timeline_item.dart';

void main() {
  group('TimelineController', () {
    testWidgets('inicia em estado vazio e não carregando', (tester) async {
      final controller = TimelineController();
      expect(controller.isLoading, false);
      expect(controller.hasError, false);
      expect(controller.filteredItems, isEmpty);
    });

    testWidgets('carregarDados retorna vazio sem conexão configurada', (tester) async {
      final controller = TimelineController();
      await controller.carregarDados();
      expect(controller.isLoading, false);
      expect(controller.hasError, false);
      expect(controller.filteredItems, isEmpty);
    });

    testWidgets('toggleOrder alterna a direção da ordenação', (tester) async {
      final controller = TimelineController();
      expect(controller.isAscending, true);
      controller.toggleOrder();
      expect(controller.isAscending, false);
      controller.toggleOrder();
      expect(controller.isAscending, true);
    });

    testWidgets('selectCategory atualiza o filtro ativo', (tester) async {
      final controller = TimelineController();
      controller.selectCategory(TimelineItemType.artifact);
      expect(controller.selectedCategory, TimelineItemType.artifact);
      // A recarga assíncrona termina sem exceção
      await tester.pump();
    });

    testWidgets('setPeriod atualiza o intervalo cronológico', (tester) async {
      final controller = TimelineController();
      controller.setPeriod(-1000, 500);
      expect(controller.startYear, -1000);
      expect(controller.endYear, 500);
      await tester.pump();
    });

    testWidgets('resetFilters retorna ao estado inicial', (tester) async {
      final controller = TimelineController();
      controller.selectCategory(TimelineItemType.historicalEvent);
      controller.setPeriod(1000, 1500);
      controller.toggleOrder();
      controller.resetFilters();
      expect(controller.selectedCategory, TimelineItemType.all);
      expect(controller.startYear, controller.minPossibleYear);
      expect(controller.endYear, controller.maxPossibleYear);
      expect(controller.isAscending, true);
    });
  });
}
