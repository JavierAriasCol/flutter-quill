import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show QuillController, StyleAttribute, getEmbedNode;
import 'package:flutter_quill/internal.dart';

import '../../common/utils/element_utils/element_utils.dart';
import 'config/image_config.dart';
import 'widgets/image.dart' show ImageTapWrapper, getImageStyleString;

class ImageOptionsMenu extends StatelessWidget {
  const ImageOptionsMenu({
    required this.controller,
    required this.config,
    required this.imageSource,
    required this.imageSize,
    required this.readOnly,
    required this.imageProvider,
    super.key,
  });

  final QuillController controller;
  final QuillEditorImageEmbedConfig config;
  final String imageSource;
  final ElementSize imageSize;
  final bool readOnly;
  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: SimpleDialog(
        title: Text(context.loc.image),
        children: [
          if (!readOnly)
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: materialTheme.colorScheme.error,
              ),
              title: Text(context.loc.remove),
              onTap: () async {
                Navigator.of(context).pop();

                // Call the remove check callback if set
                if (await config.shouldRemoveImageCallback?.call(imageSource) ==
                    false) {
                  return;
                }

                final offset = getEmbedNode(
                  controller,
                  controller.selection.start,
                ).offset;
                controller.replaceText(
                  offset,
                  1,
                  '',
                  TextSelection.collapsed(offset: offset),
                );
                // Call the post remove callback if set
                await config.onImageRemovedCallback.call(imageSource);
              },
            ),
          if (!readOnly)
            ListTile(
              leading: const Icon(Icons.text_fields_outlined),
              title: const Text('Añadir leyenda'),
              onTap: () {
                Navigator.of(context).pop();
                _showCaptionDialog(context);
              },
            ),
          ListTile(
            leading: const Icon(Icons.zoom_in),
            title: Text(context.loc.zoom),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ImageTapWrapper(
                  imageUrl: imageSource,
                  config: config,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCaptionDialog(BuildContext context) {
    final captionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Añadir leyenda'),
        content: TextField(
          controller: captionController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Escribe la leyenda de la imagen...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final caption = captionController.text.trim();
              if (caption.isNotEmpty) {
                _addCaptionToImage(caption);
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _addCaptionToImage(String caption) {
    final res = getEmbedNode(
      controller,
      controller.selection.start,
    );

    // Get current style and add/update caption
    final currentStyle = getImageStyleString(controller);

    // URL encode the caption to handle special characters like colons and semicolons
    final encodedCaption = Uri.encodeComponent(caption);

    // Build new style string with caption
    String newStyle;
    if (currentStyle.contains('caption:')) {
      // Replace existing caption
      newStyle = currentStyle.replaceFirst(
        RegExp(r'caption:[^;]*;?'),
        'caption: $encodedCaption;',
      );
    } else {
      // Add caption to existing style
      if (currentStyle.isEmpty) {
        newStyle = 'caption: $encodedCaption;';
      } else {
        newStyle = '$currentStyle caption: $encodedCaption;';
      }
    }

    controller
      ..skipRequestKeyboard = true
      ..formatText(
        res.offset,
        1,
        StyleAttribute(newStyle),
      );
  }
}
