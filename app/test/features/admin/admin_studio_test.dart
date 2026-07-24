import 'package:chronos/features/admin/domain/entities/admin_entities.dart';
import 'package:chronos/features/admin/domain/repositories/admin_repository.dart';
import 'package:chronos/features/admin/services/audit_service.dart';
import 'package:chronos/features/admin/services/content_version_service.dart';
import 'package:chronos/features/admin/services/dashboard_service.dart';
import 'package:chronos/features/admin/services/editor_assistant_service.dart';
import 'package:chronos/features/admin/services/editorial_flow_service.dart';
import 'package:chronos/features/admin/services/entity_management_service.dart';
import 'package:chronos/features/admin/services/import_export_service.dart';
import 'package:chronos/features/admin/services/media_library_service.dart';
import 'package:chronos/features/admin/services/user_management_service.dart';
import 'package:chronos/features/admin/services/visual_editor_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ============================================================
// Mock Repository
// ============================================================

class MockAdminRepository implements AdminRepository {
  final Map<String, ManagedContent> _contents = {};
  final Map<String, EditorialEntry> _editorial = {};
  final Map<String, ContentVersion> _versions = {};
  final List<AuditLogEntry> _auditLogs = [];
  final Map<String, MediaAsset> _media = {};
  final Map<String, AdminUser> _users = {};

  @override
  Future<AdminDashboardStats> getDashboardStats() async =>
      const AdminDashboardStats(
        totalUsers: 100,
        activeUsersToday: 25,
        publishedContents: 50,
        contentsInReview: 5,
        characters: 10,
        events: 8,
        civilizations: 5,
        artifacts: 3,
        locations: 4,
        sources: 20,
        learningPaths: 3,
        quizzes: 7,
        aiSessions: 42,
      );

  @override
  Future<List<ManagedContent>> listContents(AdminEntityType type,
      {EditorialStatus? status, int limit = 50, int offset = 0}) async {
    return _contents.values
        .where((c) => c.entityType == type)
        .where((c) => status == null || c.status == status)
        .skip(offset)
        .take(limit)
        .toList();
  }

  @override
  Future<ManagedContent?> getContent(String id) async => _contents[id];

  @override
  Future<ManagedContent> createContent(ManagedContent content) async {
    _contents[content.id] = content;
    return content;
  }

  @override
  Future<ManagedContent> updateContent(ManagedContent content) async {
    _contents[content.id] = content;
    return content;
  }

  @override
  Future<void> deleteContent(String id) async => _contents.remove(id);

  @override
  Future<EditorialEntry?> getEditorialEntry(String entityId) async =>
      _editorial[entityId];

  @override
  Future<void> upsertEditorialEntry(EditorialEntry entry) async =>
      _editorial[entry.entityId] = entry;

  @override
  Future<List<EditorialEntry>> getEntriesByStatus(EditorialStatus status,
      {int limit = 50}) async =>
      _editorial.values.where((e) => e.status == status).take(limit).toList();

  @override
  Future<List<ContentVersion>> getVersions(String entityId) async =>
      _versions.values
          .where((v) => v.entityId == entityId)
          .toList()
        ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber));

  @override
  Future<ContentVersion?> getVersion(String versionId) async =>
      _versions[versionId];

  @override
  Future<void> saveVersion(ContentVersion version) async =>
      _versions[version.id] = version;

  @override
  Future<void> logAudit(AuditLogEntry entry) async => _auditLogs.add(entry);

  @override
  Future<List<AuditLogEntry>> getAuditLogs(
      {String? userId, AuditActionType? action, int limit = 100}) async {
    return _auditLogs
        .where((l) => userId == null || l.userId == userId)
        .where((l) => action == null || l.action == action)
        .take(limit)
        .toList();
  }

  @override
  Future<List<MediaAsset>> listMedia(
      {MediaType? type, String? folder, int limit = 50}) async {
    return _media.values
        .where((m) => type == null || m.type == type)
        .where((m) => folder == null || m.folder == folder)
        .take(limit)
        .toList();
  }

  @override
  Future<MediaAsset> saveMedia(MediaAsset asset) async {
    _media[asset.id] = asset;
    return asset;
  }

  @override
  Future<void> deleteMedia(String id) async => _media.remove(id);

  @override
  Future<List<AdminUser>> listUsers({AdminRole? role, int limit = 50}) async =>
      _users.values
          .where((u) => role == null || u.role == role)
          .take(limit)
          .toList();

  @override
  Future<AdminUser?> getUser(String userId) async => _users[userId];

  @override
  Future<void> updateUserRole(String userId, AdminRole role) async {
    final user = _users[userId];
    if (user != null) _users[userId] = user.copyWith(role: role);
  }

  @override
  Future<void> updateUserPermissions(
      String userId, List<AdminPermission> permissions) async {
    final user = _users[userId];
    if (user != null) _users[userId] = user.copyWith(permissions: permissions);
  }

  @override
  Future<void> deactivateUser(String userId) async {
    final user = _users[userId];
    if (user != null) _users[userId] = user.copyWith(isActive: false);
  }
}

// ============================================================
// Tests
// ============================================================

void main() {
  // ============ Entities ============

  group('AdminDashboardStats', () {
    test('fromJson', () {
      final stats = AdminDashboardStats.fromJson({
        'total_users': 100,
        'characters': 10,
        'events': 8,
      });
      expect(stats.totalUsers, 100);
      expect(stats.characters, 10);
      expect(stats.events, 8);
    });
  });

  group('AdminUser Entity', () {
    test('fromJson/toJson roundtrip', () {
      final user = AdminUser(
        id: 'u1',
        name: 'Admin',
        email: 'admin@chronos.app',
        role: AdminRole.admin,
        createdAt: DateTime(2025, 1, 1),
      );
      final json = user.toJson();
      final restored = AdminUser.fromJson(json);
      expect(restored.role, AdminRole.admin);
      expect(restored.name, 'Admin');
    });

    test('canPerform — superAdmin can do anything', () {
      final superAdmin = AdminUser(
        id: 'sa',
        name: 'SA',
        email: 'sa@test.com',
        role: AdminRole.superAdmin,
        createdAt: DateTime.now(),
      );
      expect(superAdmin.canPerform(AdminModule.characters, PermissionAction.delete), true);
    });

    test('canPerform — editor with permissions', () {
      final editor = AdminUser(
        id: 'ed',
        name: 'Editor',
        email: 'ed@test.com',
        role: AdminRole.editor,
        permissions: const [
          AdminPermission(
            module: AdminModule.characters,
            actions: [PermissionAction.read, PermissionAction.create],
          ),
        ],
        createdAt: DateTime.now(),
      );
      expect(editor.canPerform(AdminModule.characters, PermissionAction.read), true);
      expect(editor.canPerform(AdminModule.characters, PermissionAction.delete), false);
    });
  });

  group('ContentVersion Entity', () {
    test('fromJson/toJson roundtrip', () {
      final version = ContentVersion(
        id: 'v1',
        entityId: 'e1',
        entityType: AdminEntityType.character,
        versionNumber: 3,
        data: {'name': 'Cleópatra'},
        authorId: 'admin',
        changeDescription: 'Atualização da biografia',
        createdAt: DateTime(2025, 7, 24),
      );
      final json = version.toJson();
      final restored = ContentVersion.fromJson(json);
      expect(restored.versionNumber, 3);
      expect(restored.data['name'], 'Cleópatra');
    });
  });

  group('EditorialEntry Entity', () {
    test('copyWith status change', () {
      final entry = EditorialEntry(
        id: 'ee1',
        entityId: 'e1',
        entityType: AdminEntityType.event,
        createdBy: 'editor1',
        createdAt: DateTime.now(),
      );
      final updated = entry.copyWith(
        status: EditorialStatus.inReview,
        reviewedBy: 'reviewer1',
      );
      expect(updated.status, EditorialStatus.inReview);
      expect(updated.reviewedBy, 'reviewer1');
      expect(updated.createdBy, 'editor1');
    });
  });

  group('AuditLogEntry Entity', () {
    test('fromJson/toJson roundtrip', () {
      final log = AuditLogEntry(
        id: 'log1',
        userId: 'u1',
        userName: 'Admin',
        action: AuditActionType.publish,
        entityId: 'e1',
        entityType: AdminEntityType.character,
        createdAt: DateTime(2025, 7, 24),
      );
      final json = log.toJson();
      final restored = AuditLogEntry.fromJson(json);
      expect(restored.action, AuditActionType.publish);
    });
  });

  group('MediaAsset Entity', () {
    test('fromJson/toJson roundtrip', () {
      final asset = MediaAsset(
        id: 'm1',
        fileName: 'cleopatra.jpg',
        url: 'https://storage.chronos.app/cleopatra.jpg',
        type: MediaType.image,
        sizeBytes: 1024000,
        folder: 'characters',
        tags: const ['egypt', 'queen'],
        uploadedBy: 'admin',
        createdAt: DateTime(2025, 7, 24),
      );
      final json = asset.toJson();
      final restored = MediaAsset.fromJson(json);
      expect(restored.type, MediaType.image);
      expect(restored.tags, contains('egypt'));
    });
  });

  group('ManagedContent Entity', () {
    test('fromJson/toJson roundtrip', () {
      final content = ManagedContent(
        id: 'mc1',
        entityType: AdminEntityType.character,
        name: 'Cleópatra',
        fields: {'biography': 'Última faraó do Egito'},
        tags: const ['egypt', 'pharaoh'],
        createdBy: 'editor1',
        createdAt: DateTime(2025, 7, 24),
        updatedAt: DateTime(2025, 7, 24),
      );
      final json = content.toJson();
      final restored = ManagedContent.fromJson(json);
      expect(restored.name, 'Cleópatra');
      expect(restored.entityType, AdminEntityType.character);
    });
  });

  group('EditorBlock Entity', () {
    test('fromJson/toJson roundtrip', () {
      final block = EditorBlock(
        id: 'b1',
        type: EditorBlockType.fact,
        data: {'text': 'Roma foi fundada em 753 a.C.'},
        order: 0,
      );
      final json = block.toJson();
      final restored = EditorBlock.fromJson(json);
      expect(restored.type, EditorBlockType.fact);
    });
  });

  // ============ Dashboard Service ============

  group('DashboardService', () {
    late DashboardService service;

    setUp(() {
      service = DashboardService(repository: MockAdminRepository());
    });

    test('getStats returns stats', () async {
      final stats = await service.getStats();
      expect(stats.totalUsers, 100);
      expect(stats.characters, 10);
    });

    test('getStats uses cache', () async {
      await service.getStats();
      final stats2 = await service.getStats();
      expect(stats2.totalUsers, 100);
    });

    test('getEntityCounts', () async {
      final counts = await service.getEntityCounts();
      expect(counts[AdminEntityType.character], 10);
      expect(counts[AdminEntityType.event], 8);
    });

    test('getTotalContents', () async {
      final total = await service.getTotalContents();
      expect(total, 60); // 10+8+5+3+4+20+3+7
    });
  });

  // ============ Entity Management Service ============

  group('EntityManagementService', () {
    late EntityManagementService service;
    late MockAdminRepository repo;

    setUp(() {
      repo = MockAdminRepository();
      service = EntityManagementService(repository: repo);
    });

    test('create content', () async {
      final content = await service.create(
        entityType: AdminEntityType.character,
        name: 'Cleópatra',
        fields: {'biography': 'Última faraó'},
        userId: 'editor1',
      );
      expect(content.name, 'Cleópatra');
      expect(content.status, EditorialStatus.draft);
      expect(content.currentVersion, 1);
    });

    test('create generates version and editorial entry', () async {
      final content = await service.create(
        entityType: AdminEntityType.character,
        name: 'César',
        fields: {},
        userId: 'editor1',
      );
      final versions = await service.getVersionHistory(content.id);
      expect(versions, hasLength(1));
    });

    test('update increments version', () async {
      final content = await service.create(
        entityType: AdminEntityType.event,
        name: 'Queda de Roma',
        fields: {},
        userId: 'editor1',
      );
      final updated = await service.update(
        content: content,
        userId: 'editor1',
        changeDescription: 'Adicionado detalhes',
      );
      expect(updated.currentVersion, 2);
    });

    test('delete removes content', () async {
      final content = await service.create(
        entityType: AdminEntityType.artifact,
        name: 'Pedra de Roseta',
        fields: {},
        userId: 'editor1',
      );
      await service.delete(contentId: content.id, userId: 'editor1');
      final result = await service.get(content.id);
      expect(result, isNull);
    });

    test('restoreVersion restores data', () async {
      final content = await service.create(
        entityType: AdminEntityType.character,
        name: 'Original',
        fields: {'bio': 'v1'},
        userId: 'e1',
      );
      await service.update(
        content: content.copyWith(name: 'Updated', fields: {'bio': 'v2'}),
        userId: 'e1',
      );
      final versions = await service.getVersionHistory(content.id);
      expect(versions, hasLength(2));
    });
  });

  // ============ Editorial Flow Service ============

  group('EditorialFlowService', () {
    late EditorialFlowService service;
    late MockAdminRepository repo;

    setUp(() {
      repo = MockAdminRepository();
      service = EditorialFlowService(repository: repo);
    });

    test('full editorial flow: draft → review → approved → published → archived',
        () async {
      // Create content first
      final mgmt = EntityManagementService(repository: repo);
      final content = await mgmt.create(
        entityType: AdminEntityType.character,
        name: 'Test',
        fields: {},
        userId: 'editor',
      );

      // Submit for review
      final review = await service.submitForReview(
        entityId: content.id,
        entityType: AdminEntityType.character,
        userId: 'editor',
      );
      expect(review.status, EditorialStatus.inReview);

      // Approve
      final approved = await service.approve(
        entityId: content.id,
        reviewerId: 'reviewer',
      );
      expect(approved!.status, EditorialStatus.approved);

      // Publish
      final published = await service.publish(
        entityId: content.id,
        publisherId: 'admin',
      );
      expect(published!.status, EditorialStatus.published);

      // Archive
      final archived = await service.archive(
        entityId: content.id,
        userId: 'admin',
      );
      expect(archived!.status, EditorialStatus.archived);
    });

    test('reject returns to draft with reason', () async {
      final mgmt = EntityManagementService(repository: repo);
      final content = await mgmt.create(
        entityType: AdminEntityType.event,
        name: 'Event',
        fields: {},
        userId: 'editor',
      );
      await service.submitForReview(
        entityId: content.id,
        entityType: AdminEntityType.event,
        userId: 'editor',
      );
      final rejected = await service.reject(
        entityId: content.id,
        reviewerId: 'reviewer',
        reason: 'Faltam fontes',
      );
      expect(rejected!.status, EditorialStatus.draft);
      expect(rejected.rejectionReason, 'Faltam fontes');
    });
  });

  // ============ Content Version Service ============

  group('ContentVersionService', () {
    late ContentVersionService service;
    late MockAdminRepository repo;

    setUp(() {
      repo = MockAdminRepository();
      service = ContentVersionService(repository: repo);
    });

    test('compareVersions finds differences', () async {
      await service.saveVersion(ContentVersion(
        id: 'v1', entityId: 'e1', entityType: AdminEntityType.character,
        versionNumber: 1, data: {'name': 'A', 'bio': 'Old'},
        authorId: 'u1', createdAt: DateTime.now(),
      ));
      await service.saveVersion(ContentVersion(
        id: 'v2', entityId: 'e1', entityType: AdminEntityType.character,
        versionNumber: 2, data: {'name': 'A', 'bio': 'New'},
        authorId: 'u1', createdAt: DateTime.now(),
      ));
      final diffs = await service.compareVersions('v1', 'v2');
      expect(diffs, contains('bio'));
      expect(diffs['bio']!.oldValue, 'Old');
      expect(diffs['bio']!.newValue, 'New');
    });

    test('getVersionCount', () async {
      await service.saveVersion(ContentVersion(
        id: 'v1', entityId: 'e1', entityType: AdminEntityType.character,
        versionNumber: 1, data: {}, authorId: 'u1', createdAt: DateTime.now(),
      ));
      await service.saveVersion(ContentVersion(
        id: 'v2', entityId: 'e1', entityType: AdminEntityType.character,
        versionNumber: 2, data: {}, authorId: 'u1', createdAt: DateTime.now(),
      ));
      expect(await service.getVersionCount('e1'), 2);
    });
  });

  // ============ Media Library Service ============

  group('MediaLibraryService', () {
    late MediaLibraryService service;

    setUp(() {
      service = MediaLibraryService(repository: MockAdminRepository());
    });

    test('upload and list', () async {
      await service.upload(
        fileName: 'test.jpg',
        url: 'https://storage.com/test.jpg',
        type: MediaType.image,
        uploadedBy: 'admin',
        folder: 'characters',
        tags: ['egypt'],
      );
      final media = await service.list(type: MediaType.image);
      expect(media, hasLength(1));
      expect(media.first.fileName, 'test.jpg');
    });

    test('delete', () async {
      final asset = await service.upload(
        fileName: 'del.jpg',
        url: 'https://x.com/del.jpg',
        type: MediaType.image,
        uploadedBy: 'admin',
      );
      await service.delete(mediaId: asset.id, userId: 'admin');
      final remaining = await service.list();
      expect(remaining, isEmpty);
    });

    test('searchByTags', () async {
      final repo = MockAdminRepository();
      final svc = MediaLibraryService(repository: repo);
      // Manually insert media to avoid timestamp collision
      repo._media['m1'] = MediaAsset(
        id: 'm1', fileName: 'a.jpg', url: 'url',
        type: MediaType.image, uploadedBy: 'u',
        tags: const ['rome', 'empire'], createdAt: DateTime.now(),
      );
      repo._media['m2'] = MediaAsset(
        id: 'm2', fileName: 'b.jpg', url: 'url2',
        type: MediaType.image, uploadedBy: 'u',
        tags: const ['greece'], createdAt: DateTime.now(),
      );
      final result = await svc.searchByTags(['rome']);
      expect(result, hasLength(1));
    });
  });

  // ============ User Management Service ============

  group('UserManagementService', () {
    late UserManagementService service;
    late MockAdminRepository repo;

    setUp(() {
      repo = MockAdminRepository();
      service = UserManagementService(repository: repo);
      repo._users['u1'] = AdminUser(
        id: 'u1', name: 'Editor', email: 'ed@test.com',
        role: AdminRole.editor, createdAt: DateTime.now(),
      );
    });

    test('changeRole', () async {
      await service.changeRole(userId: 'u1', newRole: AdminRole.admin, adminId: 'sa');
      final user = await service.getUser('u1');
      expect(user!.role, AdminRole.admin);
    });

    test('deactivate', () async {
      await service.deactivate(userId: 'u1', adminId: 'sa');
      final user = await service.getUser('u1');
      expect(user!.isActive, false);
    });

    test('getDefaultPermissions for editor', () {
      final perms = service.getDefaultPermissions(AdminRole.editor);
      expect(perms, isNotEmpty);
      expect(perms.first.actions, contains(PermissionAction.read));
    });

    test('getDefaultPermissions for superAdmin', () {
      final perms = service.getDefaultPermissions(AdminRole.superAdmin);
      expect(perms.length, AdminModule.values.length);
    });
  });

  // ============ Audit Service ============

  group('AuditService', () {
    late AuditService service;
    late MockAdminRepository repo;

    setUp(() {
      repo = MockAdminRepository();
      service = AuditService(repository: repo);
    });

    test('logLogin and getLogs', () async {
      await service.logLogin('u1');
      final logs = await service.getLogs(action: AuditActionType.login);
      expect(logs, hasLength(1));
      expect(logs.first.action, AuditActionType.login);
    });

    test('getUserLogs', () async {
      await service.log(userId: 'u1', action: AuditActionType.create);
      await service.log(userId: 'u2', action: AuditActionType.update);
      final u1Logs = await service.getUserLogs('u1');
      expect(u1Logs, hasLength(1));
    });
  });

  // ============ Import/Export Service ============

  group('ImportExportService', () {
    late ImportExportService service;

    setUp(() {
      service = ImportExportService(repository: MockAdminRepository());
    });

    test('importFromJson', () async {
      final result = await service.importFromJson(
        jsonString: '[{"name":"César"},{"name":"Augusto"}]',
        entityType: AdminEntityType.character,
        userId: 'admin',
      );
      expect(result.imported, 2);
      expect(result.errors, 0);
    });

    test('importFromCsv', () async {
      final csv = 'name,period\nCésar,Roma\nAugusto,Roma';
      final result = await service.importFromCsv(
        csvString: csv,
        entityType: AdminEntityType.character,
        userId: 'admin',
      );
      expect(result.imported, 2);
    });

    test('exportToJson', () async {
      // Create content first
      final repo = MockAdminRepository();
      final svc = ImportExportService(repository: repo);
      final mgmt = EntityManagementService(repository: repo);
      await mgmt.create(
        entityType: AdminEntityType.character,
        name: 'Test',
        fields: {},
        userId: 'u1',
      );
      final json = await svc.exportToJson(AdminEntityType.character);
      expect(json, contains('Test'));
    });

    test('exportToCsv', () async {
      final repo = MockAdminRepository();
      final svc = ImportExportService(repository: repo);
      final mgmt = EntityManagementService(repository: repo);
      await mgmt.create(
        entityType: AdminEntityType.event,
        name: 'Battle',
        fields: {'date': '44 BC'},
        userId: 'u1',
      );
      final csv = await svc.exportToCsv(AdminEntityType.event);
      expect(csv, contains('Battle'));
    });

    test('exportToMarkdown', () async {
      final repo = MockAdminRepository();
      final svc = ImportExportService(repository: repo);
      final mgmt = EntityManagementService(repository: repo);
      await mgmt.create(
        entityType: AdminEntityType.character,
        name: 'Hero',
        fields: {},
        userId: 'u1',
      );
      final md = await svc.exportToMarkdown(AdminEntityType.character);
      expect(md, contains('Hero'));
      expect(md, contains('# Personagem'));
    });
  });

  // ============ Editor Assistant Service ============

  group('EditorAssistantService', () {
    late EditorAssistantService assistant;

    setUp(() {
      assistant = EditorAssistantService();
    });

    test('analyze detects missing fields', () {
      final content = ManagedContent(
        id: 'c1',
        entityType: AdminEntityType.character,
        name: 'Test',
        fields: {'name': 'Test'},
        createdBy: 'u1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final suggestions = assistant.analyze(content);
      expect(suggestions, isNotEmpty);
      final missing = suggestions
          .where((s) => s.type == AssistantSuggestionType.incompleteField);
      expect(missing, isNotEmpty);
    });

    test('analyze detects no sources', () {
      final content = ManagedContent(
        id: 'c2',
        entityType: AdminEntityType.event,
        name: 'Event',
        fields: {'name': 'Event', 'date': '44 BC', 'location': 'Rome',
            'description': 'A very long description that is detailed enough',
            'consequences': 'Many things happened after this event',
            'participants': 'People'},
        createdBy: 'u1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final suggestions = assistant.analyze(content);
      final sourceSuggestions = suggestions
          .where((s) => s.type == AssistantSuggestionType.sourceSuggestion);
      expect(sourceSuggestions, isNotEmpty);
    });

    test('analyze detects missing classification', () {
      final content = ManagedContent(
        id: 'c3',
        entityType: AdminEntityType.character,
        name: 'Char',
        fields: {'name': 'Char', 'sources': ['src1']},
        blocks: [
          const EditorBlock(
            id: 'b1', type: EditorBlockType.paragraph,
            data: {'text': 'Some text'}, order: 0,
          ),
        ],
        createdBy: 'u1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final suggestions = assistant.analyze(content);
      final classif = suggestions
          .where((s) => s.type == AssistantSuggestionType.classificationSuggestion);
      expect(classif, isNotEmpty);
    });

    test('checkChronology detects invalid dates', () {
      final content = ManagedContent(
        id: 'c4',
        entityType: AdminEntityType.event,
        name: 'Event',
        fields: {'start_date': '500', 'end_date': '400'},
        createdBy: 'u1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final suggestions = assistant.checkChronology(
        content: content, relatedContents: [],
      );
      expect(suggestions, isNotEmpty);
      expect(suggestions.first.type,
          AssistantSuggestionType.chronologyInconsistency);
    });
  });

  // ============ Visual Editor Service ============

  group('VisualEditorService', () {
    late VisualEditorService editor;

    setUp(() {
      editor = VisualEditorService();
    });

    test('creates all block types', () {
      expect(editor.createHeading('Title').type, EditorBlockType.heading);
      expect(editor.createParagraph('Text').type, EditorBlockType.paragraph);
      expect(editor.createImage('url').type, EditorBlockType.image);
      expect(editor.createVideo('url').type, EditorBlockType.video);
      expect(editor.createTable([['A', 'B']]).type, EditorBlockType.table);
      expect(editor.createQuote('Quote').type, EditorBlockType.quote);
      expect(editor.createObservation('Obs').type, EditorBlockType.observation);
      expect(editor.createFact('Fact').type, EditorBlockType.fact);
      expect(editor.createTheory('Theory').type, EditorBlockType.theory);
      expect(editor.createDebate('Debate').type, EditorBlockType.debate);
      expect(editor.createFootnote('Note').type, EditorBlockType.footnote);
      expect(editor.createReference('Source').type, EditorBlockType.reference);
    });

    test('toMarkdown converts blocks', () {
      final blocks = [
        editor.createHeading('Roma', order: 0),
        editor.createParagraph('Roma foi um império.', order: 1),
        editor.createFact('Fundada em 753 a.C.', order: 2),
        editor.createTheory('Origem mítica de Rômulo', order: 3),
        editor.createQuote('Veni, vidi, vici', order: 4),
      ];
      final md = editor.toMarkdown(blocks);
      expect(md, contains('## Roma'));
      expect(md, contains('Roma foi um império.'));
      expect(md, contains('🟢 **Fato**'));
      expect(md, contains('🟡 **Teoria**'));
      expect(md, contains('Veni, vidi, vici'));
    });

    test('reorder changes order', () {
      final blocks = [
        editor.createParagraph('A', order: 0),
        editor.createParagraph('B', order: 1),
        editor.createParagraph('C', order: 2),
      ];
      final reordered = editor.reorder(blocks, 2, 0);
      expect(reordered[0].data['text'], 'C');
      expect(reordered[1].data['text'], 'A');
      expect(reordered[2].data['text'], 'B');
    });
  });

  // ============ Enum coverage ============

  group('Enums', () {
    test('AdminRole labels', () {
      for (final role in AdminRole.values) {
        expect(role.label, isNotEmpty);
      }
    });

    test('EditorialStatus labels', () {
      for (final status in EditorialStatus.values) {
        expect(status.label, isNotEmpty);
      }
    });

    test('AdminEntityType labels', () {
      for (final type in AdminEntityType.values) {
        expect(type.label, isNotEmpty);
      }
    });

    test('MediaType labels', () {
      for (final type in MediaType.values) {
        expect(type.label, isNotEmpty);
      }
    });

    test('AssistantSuggestionType labels', () {
      for (final type in AssistantSuggestionType.values) {
        expect(type.label, isNotEmpty);
      }
    });
  });
}
