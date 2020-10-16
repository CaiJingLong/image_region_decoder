import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_region_decoder/image_region_decoder.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'const/resource.dart';
import 'memory_part_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Uint8List image;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              if (image != null)
                Image(
                  image: MemoryPartImage(
                    image,
                    rect: Rect.fromLTWH(3000, 3000, 2500, 2500),
                  ),
                ),
              RaisedButton(
                onPressed: _loadPartImage,
                child: Text('load part image'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadPartImage() async {
    final srcByteData = await rootBundle.load(R.ASSETS_JPG_8000X8000_JPG);
    this.image = srcByteData.buffer.asUint8List();
    setState(() {});
    final size = ImageSizeGetter.getSize(MemoryInput(this.image));
    print('${size.width} x ${size.height}');

    // final sw = Stopwatch();
    // sw.start();
    // final result = await handleImage(
    //   src,
    //   Rect.fromLTWH(1500, 1500, 1800, 1800),
    // );
    // sw.stop();

    // print(sw.elapsedMilliseconds);

    // this.image = result;
    // setState(() {});
  }

  Future<Uint8List> handleImage(Uint8List image, Rect rect) {
    return ImageRegionDecoder.imageInRect(
      imageByte: image,
      rect: rect,
    );
  }
}
