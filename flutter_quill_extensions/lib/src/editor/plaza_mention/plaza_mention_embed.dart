import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'config/plaza_mention_config.dart';

/// Inline embed builder that renders a plaza mention chip.
///
/// The embed data is a JSON string with keys: `id`, `name`,
/// and optionally `profileUrl`. Rendered as a compact chip
/// with an avatar and the plaza name.
class QuillEditorPlazaMentionEmbedBuilder extends EmbedBuilder {
  QuillEditorPlazaMentionEmbedBuilder({this.config});

  final PlazaMentionConfig? config;

  @override
  String get key => 'plaza_mention';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final data =
        jsonDecode(embedContext.node.value.data as String)
            as Map<String, dynamic>;
    final name = data['name'] as String;
    final profileUrl = data['profileUrl'] as String?;
    final plazaId = data['id'] as String;

    final bgColor = config?.backgroundColor ?? const Color(0x1A6750A4);
    final txtColor = config?.textColor ?? const Color(0xFF6750A4);

    return GestureDetector(
      onTap: () => config?.onPlazaTap?.call(plazaId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (profileUrl != null && profileUrl.isNotEmpty)
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(profileUrl),
              ),
            if (profileUrl != null && profileUrl.isNotEmpty)
              const SizedBox(width: 12),
            Text(
              name,
              style: TextStyle(
                color: txtColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
