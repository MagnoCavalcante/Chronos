/// Contrato para envio de notificações locais gamificadas.
abstract interface class NotificationService {
  Future<void> initialize();
  Future<void> showXpGained(int amount, int totalXp);
  Future<void> showLevelUp(int newLevel);
  Future<void> showAchievementUnlocked(String achievementName);
  Future<void> showStreakReminder(int streakDays);
  Future<void> scheduleDailyReminder({required int hour, required int minute});
  Future<void> cancelAll();
}

/// Implementação stub/placeholder para notificações locais.
///
/// Não depende de permissões de plataforma e serve de infraestrutura para
/// futura integração com flutter_local_notifications em uma sprint dedicada.
class StubNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showXpGained(int amount, int totalXp) async {}

  @override
  Future<void> showLevelUp(int newLevel) async {}

  @override
  Future<void> showAchievementUnlocked(String achievementName) async {}

  @override
  Future<void> showStreakReminder(int streakDays) async {}

  @override
  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {}

  @override
  Future<void> cancelAll() async {}
}

/// Notifier central que pode ser substituído por implementação real no futuro.
class GamificationNotificationService {
  static NotificationService _instance = StubNotificationService();

  static NotificationService get instance => _instance;

  static void set(NotificationService service) => _instance = service;

  static Future<void> initialize() => _instance.initialize();
}
