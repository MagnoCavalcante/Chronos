/// Passo individual do onboarding.
class OnboardingStep {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final OnboardingFeature feature;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.feature,
  });
}

/// Feature apresentada no onboarding.
enum OnboardingFeature {
  search,
  timeline,
  map,
  ai,
  collections,
  gamification,
  favorites,
  studySystem,
}

/// Estado de conclusão do onboarding.
class OnboardingState {
  final bool completed;
  final int lastStepSeen;
  final DateTime? completedAt;

  const OnboardingState({
    this.completed = false,
    this.lastStepSeen = 0,
    this.completedAt,
  });
}
