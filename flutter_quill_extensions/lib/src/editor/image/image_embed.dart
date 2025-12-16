import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../common/utils/element_utils/element_utils.dart';
import 'config/image_config.dart';
import 'image_menu.dart';
import 'widgets/image.dart';

class QuillEditorImageEmbedBuilder extends EmbedBuilder {
  QuillEditorImageEmbedBuilder({
    required this.config,
  });
  final QuillEditorImageEmbedConfig config;

  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final imageSource = standardizeImageUrl(embedContext.node.value.data);
    final ((imageSize), margin, alignment, caption) = getElementAttributes(
      embedContext.node,
      context,
    );

    final width = imageSize.width;
    final height = imageSize.height;

    final imageWidget = getImageWidgetByImageSource(
      context: context,
      imageSource,
      imageProviderBuilder: config.imageProviderBuilder,
      imageErrorWidgetBuilder: config.imageErrorWidgetBuilder,
      alignment: alignment,
      height: height,
      width: width,
    );

    // Build the image with optional caption
    Widget imageWithCaption = imageWidget;
    if (caption != null && caption.isNotEmpty) {
      // Decode the caption (it may be URL encoded to handle special chars)
      final decodedCaption = Uri.decodeComponent(caption);
      final screenWidth = MediaQuery.sizeOf(context).width;

      imageWithCaption = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          imageWidget,
          Padding(
            padding: EdgeInsets.only(
              top: 8,
              bottom: 24,
              left: screenWidth * 0.13,
              right: screenWidth * 0.13,
            ),
            child: Text(
              decodedCaption,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFFECE9E9),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        final onImageClicked = config.onImageClicked;
        if (onImageClicked != null) {
          onImageClicked(imageSource);
          return;
        }
        showDialog(
          context: context,
          builder: (_) => ImageOptionsMenu(
            controller: embedContext.controller,
            config: config,
            imageSource: imageSource,
            imageSize: imageSize,
            readOnly: embedContext.readOnly,
            imageProvider: imageWidget.image,
          ),
        );
      },
      child: Builder(
        builder: (context) {
          if (margin != null) {
            return Padding(
              padding: EdgeInsets.all(margin),
              child: imageWithCaption,
            );
          }
          return imageWithCaption;
        },
      ),
    );
  }
}
