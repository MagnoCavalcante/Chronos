import 'package:supabase_flutter/supabase_flutter.dart';

/// Classe base abstrata para todos os Data Sources do CHRONOS.
/// Garante acesso padronizado e seguro ao cliente do Supabase.
abstract class BaseRemoteDataSource {
  final SupabaseClient client;

  const BaseRemoteDataSource(this.client);
}
