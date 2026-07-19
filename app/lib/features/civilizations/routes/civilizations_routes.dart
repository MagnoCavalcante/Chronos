import 'package:flutter/material.dart';
import '../presentation/screens/civilizations_screen.dart';

class CivilizationsRoutes {
  CivilizationsRoutes._();

  static const String root = '/civilizations';

  static Map<String, WidgetBuilder> get routes => {
        root: (context) => const CivilizationsScreen(),
      };
}
