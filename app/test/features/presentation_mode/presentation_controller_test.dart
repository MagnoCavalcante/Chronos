import 'package:chronos/features/presentation_mode/domain/entities/presentation_entities.dart';
import 'package:chronos/features/presentation_mode/services/presentation_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PresentationController', () {
    late PresentationController controller;
    late PresentationSession session;

    setUp(() {
      controller = PresentationController();
      session = PresentationSession(
        id: 'test',
        title: 'Teste',
        slides: List.generate(
          5,
          (i) => PresentationSlide(
            id: 'slide_$i',
            title: 'Slide $i',
            contentType: PresentableContentType.event,
            entityId: 'e_$i',
          ),
        ),
        config: const PresentationConfig(fullscreen: false),
        createdAt: DateTime.now(),
      );
    });

    tearDown(() => controller.dispose());

    test('estado inicial é idle', () {
      expect(controller.state, PresentationState.idle);
      expect(controller.session, isNull);
      expect(controller.currentSlide, isNull);
    });

    test('startSession ativa apresentação', () {
      controller.startSession(session);
      expect(controller.state, PresentationState.active);
      expect(controller.currentIndex, 0);
      expect(controller.session?.title, 'Teste');
    });

    test('next e previous navegam slides', () {
      controller.startSession(session);
      controller.next();
      expect(controller.currentIndex, 1);
      controller.next();
      expect(controller.currentIndex, 2);
      controller.previous();
      expect(controller.currentIndex, 1);
    });

    test('não avança além do último slide', () {
      controller.startSession(session);
      for (int i = 0; i < 10; i++) {
        controller.next();
      }
      expect(controller.currentIndex, 4);
    });

    test('não recua antes do primeiro slide', () {
      controller.startSession(session);
      controller.previous();
      expect(controller.currentIndex, 0);
    });

    test('goToSlide pula para índice específico', () {
      controller.startSession(session);
      controller.goToSlide(3);
      expect(controller.currentIndex, 3);
      expect(controller.currentSlide?.id, 'slide_3');
    });

    test('progress calcula corretamente', () {
      controller.startSession(session);
      expect(controller.progress, 0.0);
      controller.goToSlide(4);
      expect(controller.progress, 1.0);
    });

    test('pause e resume funcionam', () {
      controller.startSession(session);
      controller.pause();
      expect(controller.state, PresentationState.paused);
      controller.resume();
      expect(controller.state, PresentationState.active);
    });

    test('endSession volta para idle', () {
      controller.startSession(session);
      controller.endSession();
      expect(controller.state, PresentationState.idle);
      expect(controller.session, isNull);
    });

    test('handleSwipe left avança, right volta', () {
      controller.startSession(session);
      controller.handleSwipe(SwipeDirection.left);
      expect(controller.currentIndex, 1);
      controller.handleSwipe(SwipeDirection.right);
      expect(controller.currentIndex, 0);
    });

    test('handleKeyEvent com seta direita avança', () {
      controller.startSession(session);
      final event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowRight,
        logicalKey: LogicalKeyboardKey.arrowRight,
        timeStamp: Duration.zero,
      );
      final handled = controller.handleKeyEvent(event);
      expect(handled, isTrue);
      expect(controller.currentIndex, 1);
    });

    test('prepareCast registra configuração', () {
      controller.prepareCast(CastOutputType.chromecast);
      expect(controller.castConfig, isNotNull);
      expect(controller.castConfig!.outputType, CastOutputType.chromecast);
      expect(controller.castConfig!.isConnected, isFalse);
    });
  });
}
