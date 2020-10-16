import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_region_decoder/image_region_decoder.dart';

class MemoryPartImage extends ImageProvider<MemoryPartImage> {
  const MemoryPartImage(
    this.bytes, {
    this.scale = 1.0,
    @required this.rect,
  })  : assert(bytes != null),
        assert(scale != null),
        assert(rect != null);

  /// The bytes to decode into an image.
  final Uint8List bytes;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The rect of the image.
  final Rect rect;

  @override
  Future<MemoryPartImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter load(MemoryPartImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(
      MemoryPartImage key, DecoderCallback decode) async {
    assert(key == this);

    final partBytes =
        await ImageRegionDecoder.imageInRect(imageByte: bytes, rect: rect);

    return decode(partBytes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is MemoryPartImage &&
        other.bytes == bytes &&
        other.scale == scale &&
        other.rect == rect;
  }

  @override
  int get hashCode => hashValues(bytes.hashCode, scale, rect);
}
