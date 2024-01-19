import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokemon/screens/color_extractor.dart';
class SearchPages extends StatefulWidget {
  const SearchPages({super.key});

  @override
  State<SearchPages> createState() => _SearchPagesState();
}

class _SearchPagesState extends State<SearchPages> {
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  String urlPokemon = "";
  String namaPokemon = " ";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading : false,
          centerTitle: true,
          title: Center(
            child: Image.asset('assets/img/Logo.png', height: 160, width: 160),
          ),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 24),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(217, 217, 217, 217),
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 36, bottom: 2, top: 20),
                    child: SearchBar(
                      backgroundColor: const MaterialStatePropertyAll<Color>(
                        Color.fromARGB(217, 217, 217, 217),
                      ),
                      controller: _searchController,
                      padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      hintText: "Search",
                      hintStyle: const MaterialStatePropertyAll<TextStyle>(
                        TextStyle(color: Color.fromARGB(126, 126, 126, 126)),
                      ),
                      leading: const Icon(
                        Icons.search,
                        color: Color.fromARGB(126, 126, 126, 126),
                      ),
                      onSubmitted: (String value) async {
                        var test = await _searchPokemon(value);

                        print(test?.name ?? "Kosong abilitynya bozku");
                        print(value);

                        setState(() {
                          namaPokemon = test!.name;
                          urlPokemon = test.sprites.frontDefault;
                        });
                      },
                      elevation: const MaterialStatePropertyAll<double>(2.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 36, bottom: 2, top: 20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          urlPokemon == ""
                              ? FlutterLogo(
                                  size: 120,
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 80.0, bottom: 8, right: 20),
                                  child: Image.network(
                                    urlPokemon,
                                    height: 220,
                                    width: 220,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(),
                            child: Text(
                              namaPokemon,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class SearchPokemonDetail {
  Future<PokemonDetail?> searchPokemonDetail(String pokemonName) async {
    try {
      String baseUrl = 'https://pokeapi.co/api/v2/pokemon/';
      final response = await http.get(Uri.parse('$baseUrl$pokemonName'));

      if (response.statusCode == 200) {
        var decodedJson = json.decode(response.body);
        var pokemonDetail = PokemonDetail.fromJson(decodedJson);
        return pokemonDetail;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}

// Call PokemonSearch with the query
Future<PokemonDetail?> _searchPokemon(String query) async {
  PokemonDetail? pokemonDetailResult;
  SearchPokemonDetail service = SearchPokemonDetail();

  try {
    pokemonDetailResult = await service.searchPokemonDetail(query);
    return pokemonDetailResult;
    // Do something with the searchResults, e.g., update the UI
  } catch (e) {
    print('Error searching Pokemon: $e');
  }
  return null;
}

class PokemonDetail {
  final List<Ability> abilities;
  // final int baseExperience;
  // final List<Species> forms;
  // final List<GameIndex> gameIndices;
  // final int height;
  // final List<dynamic> heldItems;
  // final int id;
  // final bool isDefault;
  // final String locationAreaEncounters;
  // final List<Move> moves;
  final String name;
  // final int order;
  // final List<dynamic> pastAbilities;
  // final List<dynamic> pastTypes;
  // final Species species;
  final Sprites sprites;
  // final List<Stat> stats;
  // final List<Type> types;
  // final int weight;

  PokemonDetail({
    required this.abilities,
    // required this.baseExperience,
    // required this.forms,
    // required this.gameIndices,
    // required this.height,
    // required this.heldItems,
    // required this.id,
    // required this.isDefault,
    // required this.locationAreaEncounters,
    // required this.moves,
    required this.name,
    // required this.order,
    // required this.pastAbilities,
    // required this.pastTypes,
    // required this.species,
    required this.sprites,
    // required this.stats,
    // required this.types,
    // required this.weight,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) => PokemonDetail(
        abilities: List<Ability>.from(
            json["abilities"].map((x) => Ability.fromJson(x))),
        // baseExperience: json["base_experience"],
        // forms: List<Species>.from(json["forms"].map((x) => Species.fromJson(x))),
        // gameIndices: List<GameIndex>.from(json["game_indices"].map((x) => GameIndex.fromJson(x))),
        // height: json["height"],
        // heldItems: List<dynamic>.from(json["held_items"].map((x) => x)),
        // id: json["id"],
        // isDefault: json["is_default"],
        // locationAreaEncounters: json["location_area_encounters"],
        // moves: List<Move>.from(json["moves"].map((x) => Move.fromJson(x))),
        name: json["name"],
        // order: json["order"],
        // pastAbilities: List<dynamic>.from(json["past_abilities"].map((x) => x)),
        // pastTypes: List<dynamic>.from(json["past_types"].map((x) => x)),
        // species: Species.fromJson(json["species"]),
        sprites: Sprites.fromJson(json["sprites"]),
        // stats: List<Stat>.from(json["stats"].map((x) => Stat.fromJson(x))),
        // types: List<Type>.from(json["types"].map((x) => Type.fromJson(x))),
        // weight: json["weight"],
      );

  Map<String, dynamic> toJson() => {
        "abilities": List<dynamic>.from(abilities.map((x) => x.toJson())),
        // "base_experience": baseExperience,
        // "forms": List<dynamic>.from(forms.map((x) => x.toJson())),
        // "game_indices": List<dynamic>.from(gameIndices.map((x) => x.toJson())),
        // "height": height,
        // "held_items": List<dynamic>.from(heldItems.map((x) => x)),
        // "id": id,
        // "is_default": isDefault,
        // "location_area_encounters": locationAreaEncounters,
        // "moves": List<dynamic>.from(moves.map((x) => x.toJson())),
        "name": name,
        // "order": order,
        // "past_abilities": List<dynamic>.from(pastAbilities.map((x) => x)),
        // "past_types": List<dynamic>.from(pastTypes.map((x) => x)),
        // "species": species.toJson(),
        // "sprites": sprites.toJson(),
        // "stats": List<dynamic>.from(stats.map((x) => x.toJson())),
        // "types": List<dynamic>.from(types.map((x) => x.toJson())),
        // "weight": weight,
      };
}

class Ability {
  final String ability;
  final bool isHidden;
  final int slot;
  Ability({
    required this.ability,
    required this.isHidden,
    required this.slot,
  });
  factory Ability.fromJson(Map<String, dynamic> json) => Ability(
        ability: json["ability"]["name"],
        isHidden: json["is_hidden"],
        slot: json["slot"],
      );
  Map<String, dynamic> toJson() => {
        "ability": ability,
        "is_hidden": isHidden,
        "slot": slot,
      };
}

class Sprites {
  final String frontDefault;

  Sprites({
    required this.frontDefault,
  });

  factory Sprites.fromJson(Map<String, dynamic> json) => Sprites(
        frontDefault: json["front_default"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "front_default": frontDefault,
      };
}
