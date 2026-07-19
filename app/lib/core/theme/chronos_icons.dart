import 'package:flutter/material.dart';

/// Design Tokens de Ícones para o ecossistema CHRONOS.
///
/// Centraliza todos os ícones utilizados no projeto, garantindo estilo e preenchimento coesos.
abstract class ChronosIcons {
  // Ações globais
  static const IconData sync = Icons.sync_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData save = Icons.save_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData arrowBack = Icons.arrow_back_rounded;
  static const IconData arrowForward = Icons.arrow_forward_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData chevronLeft = Icons.chevron_left_rounded;

  // Estados semânticos
  static const IconData success = Icons.check_circle_outline_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData empty = Icons.folder_open_rounded;

  // Domínio Temático/Histórico
  static const IconData era = Icons.history_toggle_off_rounded;
  static const IconData event = Icons.event_note_rounded;
  static const IconData character = Icons.person_rounded;
  static const IconData characterMale = Icons.male_rounded;
  static const IconData characterFemale = Icons.female_rounded;
  static const IconData hourglass = Icons.hourglass_empty_rounded;
  static const IconData historyDoc = Icons.history_edu_rounded;
  static const IconData location = Icons.map_rounded;
  static const IconData artifact = Icons.museum_rounded;
}
