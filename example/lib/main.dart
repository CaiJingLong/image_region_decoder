import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_region_decoder/image_region_decoder.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'const/resource.dart';

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
                Image.memory(
                  image,
                  width: 300,
                  height: 300,
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
    final src = srcByteData.buffer.asUint8List();

    final size = ImageSizeGetter.getSize(MemoryInput(src));
    print('${size.width} x ${size.height}');

    final sw = Stopwatch();
    sw.start();
    final result = await ImageRegionDecoder.imageInRect(
      imageByte: src,
      rect: Rect.fromLTWH(1500, 1500, 1800, 1800),
    );
    sw.stop();

    print(sw.elapsedMilliseconds);

    this.image = result;
    setState(() {});
  }
}
