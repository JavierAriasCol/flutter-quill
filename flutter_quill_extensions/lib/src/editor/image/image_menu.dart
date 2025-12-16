import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show QuillController, StyleAttribute, getEmbedNode;
import 'package:flutter_quill/internal.dart';

import '../../common/utils/element_utils/element_utils.dart';
import '../../common/utils/element_utils/element_shared_utils.dart';
import 'config/image_config.dart';
import 'widgets/image.dart' show ImageTapWrapper, getImageStyleString;

// Custom colors for dialogs
const _dialogBackgroundColor = Color(0xFF1B1818);
const _textFieldBorderColor = Color(0xFF2B2727);
const _dialogTextColor = Color(0xFFECE9E9);
const _addButtonBackgroundColor = Color(0xFFFFCB74);
const _addButtonTextColor = Color(0xFF201D1D);

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

  /// Extracts the current caption from the image style string
  String? _getCurrentCaption() {
    final currentStyle = getImageStyleString(controller);
    if (currentStyle.isEmpty) return null;

    final cssAttrs = parseCssString(currentStyle);
    final caption = cssAttrs['caption'];
    if (caption == null || caption.isEmpty) return null;

    // Decode URL-encoded caption
    return Uri.decodeComponent(caption);
  }

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: SimpleDialog(
        title: Text(context.loc.image),
        children: [
          // 1. Añadir leyenda (first)
          if (!readOnly)
            ListTile(
              leading: const Icon(Icons.text_fields_outlined),
              title: const Text('Añadir leyenda'),
              onTap: () {
                Navigator.of(context).pop();
                _showCaptionDialog(context);
              },
            ),
          // 2. Zoom (middle)
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
          // 3. Eliminar (last)
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
        ],
      ),
    );
  }

  void _showCaptionDialog(BuildContext context) {
    // Get current caption to pre-fill the text field
    final currentCaption = _getCurrentCaption();
    final captionController = TextEditingController(text: currentCaption);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _dialogBackgroundColor,
        title: const Text(
          'Añadir leyenda',
          style: TextStyle(color: _dialogTextColor),
        ),
        content: TextField(
          controller: captionController,
          minLines: 2,
          maxLines: 4,
          style: const TextStyle(color: _dialogTextColor),
          decoration: const InputDecoration(
            hintText: 'Escribe la leyenda de la imagen...',
            hintStyle: TextStyle(color: Color(0x80ECE9E9)),
            filled: true,
            fillColor: _dialogBackgroundColor,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: _textFieldBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _textFieldBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _textFieldBorderColor, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: _dialogTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final caption = captionController.text.trim();
              if (caption.isNotEmpty) {
                _addCaptionToImage(caption);
              }
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _addButtonBackgroundColor,
              foregroundColor: _addButtonTextColor,
            ),
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
