import 'package:flutter/painting.dart';

/// Configuration for the post mention inline embed.
///
/// Allows customizing colors and handling tap events
/// on post mention cards.
class PostMentionConfig {
  const PostMentionConfig({
    this.cardBackgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.accentColor,
    this.onPostTap,
  });

  /// Background color of the mention card.
  final Color? cardBackgroundColor;

  /// Color for the post title text.
  final Color? titleColor;

  /// Color for subtitle text (author + date).
  final Color? subtitleColor;

  /// Accent color for the left border.
  final Color? accentColor;

  /// Callback when user taps the mention card.
  final void Function(String postId)? onPostTap;
}
