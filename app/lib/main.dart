import 'package:flutter/material.dart';
import 'core/config/supabase_config.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_service.dart';
import 'core/theme/theme.dart';

void main() async {
  // Garante que o binding do Flutter esteja inicializado antes da execução de tarefas assíncronas.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a conexão com o Supabase de forma segura.
  await SupabaseConfig.initialize();

  // Inicializa o Service Locator e registra todas as dependências da aplicação.
  setupServiceLocator();

  runApp(const ChronosApp());
}

class ChronosApp extends StatelessWidget {
  const ChronosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHRONOS',
      theme: ChronosTheme.darkTheme,
      navigatorKey: locate<NavigationService>().navigatorKey,
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
