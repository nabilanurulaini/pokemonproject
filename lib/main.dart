import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokemon/screens/search_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/image_parallax.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Go',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // Your theme data
          ),
      home: const SplashScreen(), // Show splash screen first
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
  List<Name> allPokemonNames = [];

  final PokemonSearch pokemonSearch =
      PokemonSearch(); // Instantiate PokemonSearch
  Timer? debouncerTime;

  @override
  void dispose() {
    debouncerTime?.cancel();
    super.dispose();
  }

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
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Name> Names = snapshot.data!;
                return Column(
                  children: [
                    SearchAnchor(
                      builder:
                          (BuildContext context, SearchController controller) {
                        // var text;
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, bottom: 2, top: 32),
                          child: SearchBar(
                            backgroundColor: isDark == false
                                ? const MaterialStatePropertyAll<Color>(
                                    Color.fromARGB(240, 240, 240, 240))
                                : const MaterialStatePropertyAll<Color>(
                                    Color.fromARGB(0, 0, 0, 0)),
                            controller: controller,
                            padding: const MaterialStatePropertyAll<EdgeInsets>(
                                EdgeInsets.symmetric(horizontal: 16.0)),
                            // onChanged: (String query) {
                            //   // Handle the onTap event for SearchBar
                            //   // You can call the PokemonSearch here
                            //   var query = controller.value.text;

                            //   if (debouncerTime?.isActive ?? false)
                            //     debouncerTime?.cancel();

                            //   debouncerTime =
                            //       Timer(const Duration(seconds: 1), () {
                            //     _searchPokemon(query);
                            //     print("Query " + query);
                            //   });
                            // },
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return SearchPages();
                              }));
                            },
                            hintText: "Search",
                            hintStyle:
                                const MaterialStatePropertyAll<TextStyle>(
                                    TextStyle(
                                        color: Color.fromARGB(
                                            126, 126, 126, 126))),
                            leading: const Icon(
                              Icons.search,
                              color: Color.fromARGB(126, 126, 126, 126),
                            ),
                            elevation:
                                const MaterialStatePropertyAll<double>(2.0),
                          ),
                        );
                      },
                      suggestionsBuilder:
                          (BuildContext context, SearchController controller) {
                        return List<ListTile>.generate(Names.length, (index) {
                          final String item = Names[index].name;
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

      // Do something with the searchResults, e.g., update the UI
      print('Search Results: $searchResults');
    } catch (e) {
      print('Error searching Pokemon: $e');
    }
  }
}

// menggunakan stateless widget karena tidak ada perubahan state

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
