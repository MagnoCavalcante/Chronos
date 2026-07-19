import 'package:flutter/material.dart';
import '../presentation/screens/historical_characters_screen.dart';

class HistoricalCharactersRoutes {
  HistoricalCharactersRoutes._();

  static const String root = '/historical_characters';

  static Map<String, WidgetBuilder> get routes => {
        root: (context) => const HistoricalCharactersScreen(),
      };
}
