import 'dart:convert';
 
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'package:pokemon/main.dart';
 
class ImageColorExtractor extends StatefulWidget {
  final String imageUrl;

  const ImageColorExtractor({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  _ImageColorExtractorState createState() => _ImageColorExtractorState();
}

// ini untuk mengambil warna dari gambar yang digunakan
class _ImageColorExtractorState extends State<ImageColorExtractor> {
  PaletteGenerator? _paletteGenerator;

  @override
  void initState() {
    super.initState();
    _generatePalette();
  }

  Future<void> _generatePalette() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.imageUrl),
      maximumColorCount: 20, // Adjust as needed
    );

    setState(() {
      _paletteGenerator = paletteGenerator;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _paletteGenerator == null
        ? const CircularProgressIndicator()
        : ColorExtractor(palette: _paletteGenerator!.lightVibrantColor!.color!);
  }
}

// ini untuk extract warna dari gambar
class ColorExtractor extends StatelessWidget {
  final Color palette;

  const ColorExtractor({Key? key, required this.palette}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: palette,
      child: Center(
        child: Text(
          '',
          style: TextStyle(
            color:
                ThemeData.estimateBrightnessForColor(palette) == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      ),
    );
  }
}
