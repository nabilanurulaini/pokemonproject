import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:palette_generator/palette_generator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return SearchBarApp();
  }
}

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({Key? key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Center(
            child: Image.asset('assets/img/Logo.png', height: 160, width: 160),
          ),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder<List<Location>>(
            future: fetchPokemonLocations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Location> locations = snapshot.data!;
                return Column(
                  children: [
                    SearchAnchor(builder:
                        (BuildContext context, SearchController controller) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, bottom: 20, top: 30),
                        child: SearchBar(
                          backgroundColor: isDark == false
                              ? MaterialStatePropertyAll<Color>(
                                  Color.fromARGB(255, 255, 255, 255))
                              : MaterialStatePropertyAll<Color>(
                                  Color.fromARGB(0, 0, 0, 0)),
                          controller: controller,
                          padding: const MaterialStatePropertyAll<EdgeInsets>(
                              EdgeInsets.symmetric(horizontal: 16.0)),
                          onTap: () {
                            controller.openView();
                          },
                          onChanged: (_) {
                            controller.openView();
                          },
                          hintText: "Search",
                          leading: const Icon(Icons.search),
                          trailing: <Widget>[
                            Tooltip(
                              message: 'Change brightness mode',
                              child: IconButton(
                                isSelected: isDark,
                                onPressed: () {
                                  setState(() {
                                    isDark = !isDark;
                                  });
                                },
                                icon: const Icon(Icons.wb_sunny_outlined),
                                selectedIcon:
                                    const Icon(Icons.brightness_2_outlined),
                              ),
                            )
                          ],
                        ),
                      );
                    }, suggestionsBuilder:
                        (BuildContext context, SearchController controller) {
                      return List<ListTile>.generate(locations.length, (index) {
                        final String item = locations[index].name;
                        return ListTile(
                          title: Text(item),
                          onTap: () {
                            setState(() {
                              controller.closeView(item);
                            });
                          },
                        );
                      });
                    }),
                    ExampleParallax(locations: locations),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<List<Location>> fetchPokemonLocations() async {
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Location> locations = [];

      for (int i = 0; i < data.length; i++) {
        final String name = data[i]['name'];
        final String url =
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${i + 1}.png';

        // Ganti 'place' dengan 'name'
        locations.add(Location(name: name, place: name, imageUrl: url));
      }

      return locations;
    } else {
      throw Exception('Failed to load Pokemon locations');
    }
  }
}

class ExampleParallax extends StatelessWidget {
  final List<Location> locations;

  const ExampleParallax({Key? key, required this.locations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 20, height: 34),
              Text(
                'All',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontSize: 15),
              ),
              const SizedBox(width: 24),
              Text(
                'Woman',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontSize: 15),
              ),
              const SizedBox(width: 24),
              Text(
                'Men',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontSize: 15),
              ),
            ],
          ),
          for (final location in locations)
            LocationListItem(
              imageUrl: location.imageUrl,
              name: location.name,
              country: location.place,
            ),
        ],
      ),
    );
  }
}

class LocationListItem extends StatelessWidget {
  LocationListItem({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.country,
  }) : super(key: key);

  final String imageUrl;
  final String name;
  final String country;
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              ImageColorExtractor(imageUrl: imageUrl),
              Parallax(
                background: Image.network(
                  imageUrl,
                  key: _backgroundImageKey,
                  fit: BoxFit.cover,
                ),
              ),
              _buildGradient(),
              _buildTitleAndSubtitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
  return Positioned(
    left: 20,
    bottom: 20,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
          ],
        ),
        SizedBox(width: 6), // Adjust spacing between text and button
        ElevatedButton(
  onPressed: () {
    // Add your button action here
  },
  style: ElevatedButton.styleFrom(
    shape: CircleBorder(), // This makes the button circular
    padding: EdgeInsets.all(5), // Adjust the padding as needed
  ),
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      // color: Colors.blue, // Choose the color you want
    ),
    padding: EdgeInsets.all(5), // Adjust the padding as needed
    child: Icon(Icons.arrow_forward, size: 14, color: Colors.black),
  ),
),

      ],
    ),
  );
}

}

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
        listItemBox.size.centerLeft(Offset.zero),
        ancestor: scrollableBox);

    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
        (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect =
        verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    context.paintChild(
      0,
      transform:
          Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

class Parallax extends SingleChildRenderObjectWidget {
  const Parallax({
    Key? key,
    required Widget background,
  }) : super(key: key, child: background);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParallax(scrollable: Scrollable.of(context));
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderParallax renderObject) {
    renderObject.scrollable = Scrollable.of(context);
  }
}

class ParallaxParentData extends ContainerBoxParentData<RenderBox> {}

class RenderParallax extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin {
  RenderParallax({
    required ScrollableState scrollable,
  }) : _scrollable = scrollable;

  ScrollableState _scrollable;

  ScrollableState get scrollable => _scrollable;

  set scrollable(ScrollableState value) {
    if (value != _scrollable) {
      if (attached) {
        _scrollable.position.removeListener(markNeedsLayout);
      }
      _scrollable = value;
      if (attached) {
        _scrollable.position.addListener(markNeedsLayout);
      }
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _scrollable.position.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ParallaxParentData) {
      child.parentData = ParallaxParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    final background = child!;
    final backgroundImageConstraints =
        BoxConstraints.tightFor(width: size.width);
    background.layout(backgroundImageConstraints, parentUsesSize: true);

    (background.parentData as ParallaxParentData).offset = Offset.zero;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final viewportDimension = scrollable.position.viewportDimension;

    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final backgroundOffset =
        localToGlobal(size.centerLeft(Offset.zero), ancestor: scrollableBox);

    final scrollFraction =
        (backgroundOffset.dy / viewportDimension).clamp(0.0, 1.0);

    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    final background = child!;
    final backgroundSize = background.size;
    final listItemSize = size;
    final childRect =
        verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    context.paintChild(
        background,
        (background.parentData as ParallaxParentData).offset +
            offset +
            Offset(0.0, childRect.top));
  }
}

class Location {
  const Location({
    required this.name,
    required this.place,
    required this.imageUrl,
  });

  final String name;
  final String place;
  final String imageUrl;
}

class ImageColorExtractor extends StatefulWidget {
  final String imageUrl;

  const ImageColorExtractor({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  _ImageColorExtractorState createState() => _ImageColorExtractorState();
}

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
        ? CircularProgressIndicator()
        : ColorExtractor(palette: _paletteGenerator!.dominantColor!.color);
  }
}

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
            color: ThemeData.estimateBrightnessForColor(palette) ==
                    Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }
}
class PokemonSearch {
  final String apiUrl = 'https://pokeapi.co/api/v2/pokemon';

  Future<List<Location>> searchPokemon(String query) async {
    final response = await http.get(Uri.parse('$apiUrl?name=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Location> searchResults = [];

      for (int i = 0; i < data.length; i++) {
        final String name = data[i]['name'];
        final String url =
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${i + 1}.png';

        searchResults.add(Location(name: name, place: name, imageUrl: url));
      }

      return searchResults;
    } else {
      throw Exception('Failed to load Pokemon search results');
    }
  }
}