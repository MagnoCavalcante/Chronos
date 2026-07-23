import 'gamification_models.dart';

/// Calcula nível, XP para próximo nível e título com base no XP total.
abstract class LevelCalculator {
  /// XP base para o nível 1.
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    // Fórmula progressiva: 100, 250, 500, 850, 1300, 1850...
    // Cada nível exige 150 a mais do que o incremento anterior.
    final previous = xpForLevel(level - 1);
    final increment = (level - 1) * 100 - 50; // nível 2: 100, 3: 150, 4: 250, 5: 350...
    return previous + (increment < 100 ? 100 : increment);
  }

  /// Nível atual com base no XP total.
  static int levelFromXp(int totalXp) {
    var level = 1;
    while (xpForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  /// XP acumulado no nível atual.
  static int xpInCurrentLevel(int totalXp) {
    final level = levelFromXp(totalXp);
    return totalXp - xpForLevel(level);
  }

  /// XP necessário para subir do nível atual para o próximo.
  static int xpToNextLevel(int totalXp) {
    final level = levelFromXp(totalXp);
    final next = xpForLevel(level + 1);
    return next - totalXp;
  }

  /// Progresso percentual no nível atual (0.0 a 1.0).
  static double levelProgress(int totalXp) {
    final level = levelFromXp(totalXp);
    final currentBase = xpForLevel(level);
    final nextBase = xpForLevel(level + 1);
    if (nextBase <= currentBase) return 0.0;
    final progress = (totalXp - currentBase) / (nextBase - currentBase);
    return progress.clamp(0.0, 1.0);
  }

  /// Título automaticamente desbloqueado para o nível/XP atual.
  static Title? titleForProgress(List<Title> rules, int level, int totalXp) {
    Title? selected;
    for (final rule in rules) {
      if (level >= rule.minLevel && totalXp >= rule.minXp) {
        if (selected == null || rule.minLevel > selected.minLevel || rule.minXp > selected.minXp) {
          selected = rule;
        }
      }
    }
    return selected;
  }
}
