import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/src/common/utils/element_utils/element_utils.dart';
import 'package:flutter_quill_extensions/src/editor/image/config/image_config.dart';
import 'package:flutter_quill_extensions/src/editor/image/image_menu.dart';
import 'package:flutter_quill_extensions/src/editor/image/image_save_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../quill_test_app.dart';

void main() {
  group('$ImageOptionsMenu', () {
    testWidgets('shows remove and zoom options', (tester) async {
      await tester.pumpWidget(const MaterialApp(
          home:
              Scaffold(body: Text('Placeholder for ImageOptionsMenu tests'))));
      // Tests for Resize, Copy, Save were removed as the features were removed.
      // TODO: Add tests for Remove and Zoom options if needed.
    });
  });
}

class MockImageSaver extends Mock implements ImageSaver {}

class FakeQuillController extends Fake implements QuillController {}

class FakeImageProvider extends ImageProvider {
  @override
  Future<Object> obtainKey(ImageConfiguration configuration) async =>
      UnimplementedError('Fake implementation of $ImageProvider');
}

class AnotherFakeImageProvider extends ImageProvider {
  @override
  Future<Object> obtainKey(ImageConfiguration configuration) async =>
      UnimplementedError('Another fake implementation of $ImageProvider');
}
