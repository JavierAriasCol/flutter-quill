import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';

import 'config/post_mention_config.dart';

/// Inline embed builder that renders a post mention card.
///
/// The embed data is a JSON string with keys: `id`, `title`,
/// `authorName`, `authorPhotoUrl`, and `createdAt`. Rendered
/// as a full-width card with accent left border, title, author
/// avatar+name, and formatted date.
class QuillEditorPostMentionEmbedBuilder extends EmbedBuilder {
  QuillEditorPostMentionEmbedBuilder({this.config});

  final PostMentionConfig? config;

  @override
  String get key => 'post_mention';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final data =
        jsonDecode(embedContext.node.value.data as String)
            as Map<String, dynamic>;
    final postId = data['id'] as String;
    final title = data['title'] as String;
    final authorName = data['authorName'] as String? ?? '';
    final authorPhotoUrl =
        data['authorPhotoUrl'] as String? ?? '';
    final createdAtStr = data['createdAt'] as String? ?? '';

    final bgColor = config?.cardBackgroundColor ??
        const Color(0xFF201D1D);
    final titleColor =
        config?.titleColor ?? Colors.white;
    final subtitleColor =
        config?.subtitleColor ?? Colors.white70;
    final accentColor =
        config?.accentColor ?? const Color(0xFFFFCB74);

    var formattedDate = '';
    if (createdAtStr.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAtStr);
        formattedDate = DateFormat('d MMM yyyy', 'es')
            .format(date);
      } catch (_) {
        formattedDate = createdAtStr;
      }
    }

    return GestureDetector(
      onTap: () => config?.onPostTap?.call(postId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            left: BorderSide(
              color: accentColor,
              width: 3,
            ),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (authorPhotoUrl.isNotEmpty) ...[
                  CircleAvatar(
                    radius: 10,
                    backgroundImage:
                        NetworkImage(authorPhotoUrl),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    [
                      if (authorName.isNotEmpty)
                        authorName,
                      if (formattedDate.isNotEmpty)
                        formattedDate,
                    ].join('  ·  '),
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
