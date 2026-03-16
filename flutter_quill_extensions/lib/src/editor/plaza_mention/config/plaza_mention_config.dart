import 'package:flutter/painting.dart';

/// Configuration for the plaza mention inline embed.
///
/// Allows customizing colors and handling tap events
/// on plaza mention chips.
class PlazaMentionConfig {
  const PlazaMentionConfig({
    this.backgroundColor,
    this.textColor,
    this.onPlazaTap,
  });

  /// Background color of the mention chip.
  final Color? backgroundColor;

  /// Text color of the plaza name.
  final Color? textColor;

  /// Callback when user taps the mention chip.
  final void Function(String plazaId)? onPlazaTap;
}
