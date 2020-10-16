import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageRegionDecoder {
  static const MethodChannel _channel =
      const MethodChannel('image_region_decoder');

  static Future<Uint8List> imageInRect({
    @required Uint8List imageByte,
    @required Rect rect,
  }) async {
    if (rect == null) {
      return imageByte;
    }
    final params = <String, dynamic>{};
    params.putIfAbsent('image', () => imageByte);
    params.putIfAbsent('rect', () => _rectToMap(rect));

    return _channel.invokeMethod('imageRect', params);
  }

  static Map _rectToMap(Rect rect) {
    return {
      'l': rect.left,
      't': rect.top,
      'w': rect.width,
      'h': rect.height,
    };
  }
}
