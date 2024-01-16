import 'dart:html';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:palette_generator/palette_generator.dart';
import 'screens/splash_screen.dart';
import 'screens/detail.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Go',
      theme: ThemeData(
          // Your theme data
          ),
      home: SplashScreen(), // Show splash screen first
    );
  }
}

// search bar code menggunakan stateful widget karena ada perubahan state
class SearchBarApp extends StatefulWidget {
  const SearchBarApp({Key? key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

// ini state nya
class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;
   List<Name> searchResults = [];
  List<Name> allPokemonNames = [];

  final PokemonSearch pokemonSearch =
      PokemonSearch(); // Instantiate PokemonSearch

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
          child: FutureBuilder<List<Name>>(
            // future digunakan untuk menunggu data yang akan diambil dari api
            future: fetchPokemonNames(),
            // snapshot untuk menampilkan data yang sudah diambil dari api
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Name> Names = snapshot.data!;
                return Column(
                  children: [
                    SearchAnchor(
                      builder:
                          (BuildContext context, SearchController controller) {
                        var text;
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, bottom: 2, top: 32),
                          child: SearchBar(
                            backgroundColor: isDark == false
                                ? MaterialStatePropertyAll<Color>(
                                    Color.fromARGB(217, 217, 217, 217))
                                : MaterialStatePropertyAll<Color>(
                                    Color.fromARGB(0, 0, 0, 0)),
                            controller: controller,
                            padding: const MaterialStatePropertyAll<EdgeInsets>(
                                EdgeInsets.symmetric(horizontal: 16.0)),
                            onChanged: (String query) {
                              var query = controller.value.text;
                              _searchPokemon(query);
                              print("Query $query");
                            },
                            hintText: "Search",
                            leading: Icon(
                              Icons.search,
                              color: Color.fromARGB(126, 126, 126, 126),
                            ),
                            elevation: MaterialStatePropertyAll<double>(2.0),
                          ),
                        );
                      },
                      suggestionsBuilder:
                          (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(searchResults.length, (index) {
              final String item = searchResults[index].name;
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(item);
                              });
                            },
                          );
                        });
                      },
                    ),
                    // ini untuk menampilkan gambar yang digunakan
                    ExampleParallax(Names: Names),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // future digunakan untuk mengambil list yang isinya nama dengan menggunakan async dan await karena menunggu data yang diambil dari api
  Future<List<Name>> fetchPokemonNames() async {
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Name> Names = [];

      for (int i = 0; i < data.length; i++) {
        final String name = data[i]['name'];
        final String url =
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${i + 1}.png';

        Names.add(Name(name: name, imageUrl: url));
      }

      return Names;
    } else {
      throw Exception('Failed to load Pokemon Names');
    }
  }

  // Call PokemonSearch with the query
  void _searchPokemon(String query) async {
    try {
      List<Name> searchResults = await pokemonSearch.searchPokemon(query);
      List<Name> results = await pokemonSearch.searchPokemon(query);
      setState(() {

        searchResults = results;
      });
      // Do something with the searchResults, e.g., update the UI
      print('Search Results: $searchResults');
    } catch (e) {
      print('Error searching Pokemon: $e');
    }
  }
}

// menggunakan stateless widget karena tidak ada perubahan state
class ExampleParallax extends StatelessWidget {
  final List<Name> Names;

  const ExampleParallax({Key? key, required this.Names}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 20, height: 24),
            ],
          ),
          for (final Name in Names)
            NameListItem(
              imageUrl: Name.imageUrl,
              name: Name.name,
            ),
        ],
      ),
    );
  }
}

class NameListItem extends StatelessWidget {
  NameListItem({Key? key, required this.imageUrl, required this.name})
      : super(key: key);

  final String imageUrl;
  final String name;
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
              Padding(
                padding: const EdgeInsets.only(left: 150.0),
                child: Parallax(
                  background: Image.network(
                    imageUrl,
                    key: _backgroundImageKey,
                    width: 326,
                    height: 186,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              _buildGradient(),
              _buildTitleAndSubtitle(context),
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
            colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: const [0.6, 1.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle(BuildContext context) {
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PokemonDetailPage(
                          name: name,
                          photoUrl: imageUrl,
                          ability: '',
                          weight: 10,
                          height: 10,
                          category: 'Fairy',
                          description: '')));
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(), // This makes the button circular
              padding: EdgeInsets.all(2), // Adjust the padding as needed
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: Colors.blue, // Choose the color you want
              ),
              padding: EdgeInsets.all(2), // Adjust the padding as needed
              child: Icon(Icons.arrow_forward, size: 24, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

// parallax flow delegate untuk mengatur posisi dari gambar
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

// untuk mengatur posisi dari gambar
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

class Name {
  const Name({
    required this.name,
    required this.imageUrl,
  });

  final String name;
  final String imageUrl;
}

class PokemonDetail {
  const PokemonDetail({
    required this.name,
    required this.imageUrl,
    required this.ability,
    required this.weight,
    required this.height,
    required this.category,
    required this.description,
  });

  final String name;
  final String imageUrl;
  final String ability;
  final double weight;
  final double height;
  final String category;
  final String description;
}

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
        ? CircularProgressIndicator()
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

class PokemonSearch {
  final String apiUrl = 'https://pokeapi.co/api/v2/pokemon/';

  Future<List<Name>> searchPokemon(String query) async {
    final response = await http.get(Uri.parse('$apiUrl?name=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Name> searchResults = [];

      for (int i = 0; i < data.length; i++) {
        final String name = data[i]['name'];
        final String url =
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${i + 1}.png';

        searchResults.add(Name(name: name, imageUrl: url));
      }

      return searchResults;
    } else {
      throw Exception('Failed to load Pokemon search results');
    }
  }
}
