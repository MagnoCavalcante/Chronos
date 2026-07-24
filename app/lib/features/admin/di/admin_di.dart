import '../../../core/di/service_locator.dart';
import '../data/datasources/admin_remote_datasource.dart';
import '../data/repositories/admin_repository_impl.dart';
import '../domain/repositories/admin_repository.dart';
import '../services/audit_service.dart';
import '../services/content_version_service.dart';
import '../services/dashboard_service.dart';
import '../services/editor_assistant_service.dart';
import '../services/editorial_flow_service.dart';
import '../services/entity_management_service.dart';
import '../services/import_export_service.dart';
import '../services/media_library_service.dart';
import '../services/user_management_service.dart';
import '../services/visual_editor_service.dart';

/// Injeção de dependências do Admin Studio.
class AdminDI {
  AdminDI._();

  static void register() {
    final sl = ServiceLocator.instance;

    sl.registerLazySingleton<AdminRemoteDataSource>(
        () => AdminRemoteDataSource());

    sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(
          dataSource: sl.get<AdminRemoteDataSource>(),
        ));

    sl.registerLazySingleton<DashboardService>(
        () => DashboardService(repository: sl.get<AdminRepository>()));

    sl.registerLazySingleton<EntityManagementService>(
        () => EntityManagementService(repository: sl.get<AdminRepository>()));

    sl.registerLazySingleton<EditorialFlowService>(
        () => EditorialFlowService(repository: sl.get<AdminRepository>()));

    sl.registerLazySingleton<ContentVersionService>(
        () => ContentVersionService(repository: sl.get<AdminRepository>()));

    sl.registerLazySingleton<MediaLibraryService>(
        () => MediaLibraryService(repository: sl.get<AdminRepository>()));

    sl.registerLazySingleton<UserManagementService>(
        () => UserManagementService(repository: sl.get<AdminRepository>()));

    sl.registerLazySingleton<AuditService>(
        () => AuditService(repository: sl.get<AdminRepository>()));

    sl.registerLazySingleton<ImportExportService>(
        () => ImportExportService(repository: sl.get<AdminRepository>()));

    sl.registerLazySingleton<EditorAssistantService>(
        () => EditorAssistantService());

    sl.registerLazySingleton<VisualEditorService>(
        () => VisualEditorService());
  }
}
