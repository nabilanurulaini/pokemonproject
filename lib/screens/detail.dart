import 'dart:convert';
import 'dart:developer';
 
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:basic_utils/basic_utils.dart';
 
class PokemonDetailPage extends StatefulWidget {
  // final String photoUrl;
  final String name;
  // final String ability;
  // final double weight;
  // final double height;
  // final String category;
  // final String description;
 
  PokemonDetailPage({
    // required this.photoUrl,
    required this.name,
    // required this.ability,
    // required this.weight,
    // required this.height,
    // required this.category,
    // required this.description,
  });
 
  @override
  _PokemonDetailPageState createState() => _PokemonDetailPageState();
}
 
class _PokemonDetailPageState extends State<PokemonDetailPage> {
  Map<String, dynamic> _pokemonEvolution = Map<String, dynamic>();
  Map<String, dynamic> _dataEvo1 = Map<String, dynamic>();
  Map<String, dynamic> _dataEvo2 = Map<String, dynamic>();
  Map<String, dynamic> _dataEvo3 = Map<String, dynamic>();
  Map<String, dynamic> _dataDescription = Map<String, dynamic>();
  PaletteGenerator? _paletteGenerator;
  Map<String, dynamic> _pokemonData = Map<String, dynamic>();
 
  @override
  void initState() {
    super.initState();
    _generatePalette();
    _fetchPokemonData();
    _fetchEvolution();
    _fetchPhotoEvolution();
    _fetchDescription();
  }
 
  Future<void> _generatePalette() async {
    await _fetchPokemonData();
    final paletteGenerator = await PaletteGenerator.fromImageProvider(NetworkImage(_pokemonData['sprites']['other']['official-artwork']['front_default']));
    setState(() {
      _paletteGenerator = paletteGenerator;
    });
  }
 
  Future<void> _fetchPokemonData() async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.name}/'));
    if (response.statusCode == 200) {
      setState(() {
        _pokemonData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load Pokemon data');
    }
  }
 
  Future<void> _fetchEvolution() async {
    // int idpokemon = idname/3;
    await _fetchPokemonData();
    double idpokemon = _pokemonData['id'] / 3;
    int idevolution = idpokemon.ceil();
    final response1 = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/evolution-chain/${idevolution}/'));
    if (response1.statusCode == 200) {
      // print("OK ${inspect(json.decode(response1.body))}");
      setState(() {
        _pokemonEvolution = json.decode(response1.body);
      });
    } else {
      throw Exception('Failed to load Pokemon data');
    }
  }
 
  Future<void> _fetchPhotoEvolution() async {
    // int idpokemon = idname/3;
    await _fetchPokemonData();
    await _fetchEvolution();
    String nameEvo1 = _pokemonEvolution['chain']['species']['name'];
    String nameEvo2 =
        _pokemonEvolution['chain']['evolves_to'][0]['species']['name'];
    String nameEvo3 = _pokemonEvolution['chain']['evolves_to'][0]['evolves_to']
        [0]['species']['name'];
    final responseimage1 = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${nameEvo1}/'));
    final responseimage2 = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${nameEvo2}/'));
    final responseimage3 = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${nameEvo3}/'));
    if (responseimage1.statusCode == 200 &&
        responseimage2.statusCode == 200 &&
        responseimage3.statusCode == 200) {
      // print("OK ${inspect(json.decode(response1.body))}");
      setState(() {
        _dataEvo1 = json.decode(responseimage1.body);
        _dataEvo2 = json.decode(responseimage2.body);
        _dataEvo3 = json.decode(responseimage3.body);
      });
    } else {
      throw Exception('Failed to load Pokemon Evolution Chain');
    }
  }
 
  Future<void> _fetchDescription() async {
    // int idpokemon = idname/3;
    await _fetchPokemonData();
    double iddescription = _pokemonData['id'];
    final responsedescription = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon-species/${iddescription}/'));
    if (responsedescription.statusCode == 200) {
      // print("OK ${inspect(json.decode(response1.body))}");
      setState(() {
        _dataDescription = json.decode(responsedescription.body);
      });
    } else {
      throw Exception('Failed to load Pokemon Description');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor:
                _paletteGenerator?.dominantColor?.color ?? Colors.yellow,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [];
            },
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(190),
                      bottomRight: Radius.circular(190),
                    ),
                    color: _paletteGenerator?.dominantColor?.color ??
                        Colors.yellow,
                  ),
                  child: Center(
                      child: Card(
                    color: Colors.white.withOpacity(0.0),
                    elevation: 0,
                    child: CachedNetworkImage(
                      imageUrl: _pokemonData['sprites']['other']['official-artwork']['front_default'],
                      height: 175,
                      maxWidthDiskCache: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: Offset(0.0, -70.0),
                        child: Center(
                          child: Text(
                            '${StringUtils.capitalize(_pokemonData["name"])}',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      TabBar(
                        tabs: [
                          Tab(text: 'About'),
                          Tab(text: 'Status'),
                          Tab(text: 'Evolution'),
                        ],
                        indicatorColor:
                            _paletteGenerator?.dominantColor?.color ??
                                Colors.yellow,
                        labelColor: Colors.black,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        indicatorWeight: 6.0,
                        // indicatorSize: TabBarIndicatorSize(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: AboutTab(
                            ability: StringUtils.capitalize(_pokemonData["abilities"][0]["ability"]["name"]) ,
                            weight: _pokemonData["weight"],
                            height: _pokemonData["height"],
                            category: StringUtils.capitalize(_pokemonData["types"][0]["type"]["name"]),
                            description: _dataDescription["flavor_text_entries"]
                                [6]['flavor_text']),
                      ),
                      SingleChildScrollView(
                          child: StatusTab(
                        hp: _pokemonData["stats"][0]["base_stat"],
                        attack: _pokemonData["stats"][1]["base_stat"],
                        defense: _pokemonData["stats"][2]["base_stat"],
                        spattack: _pokemonData["stats"][3]["base_stat"],
                        spdefense: _pokemonData["stats"][4]["base_stat"],
                        speed: _pokemonData["stats"][5]["base_stat"],
                      )),
                      SingleChildScrollView(
                          child: EvolutionTab(
                        evo1: _pokemonEvolution['chain']['species']['name'] ??
                            "saya evo 1",
                        // evo1: _pokemonEvolution['id'],
                        evo2: _pokemonEvolution['chain']['evolves_to'][0]
                                ['species']['name'] ??
                            "saya evo2",
                        evo3: _pokemonEvolution['chain']['evolves_to'][0]
                                ['evolves_to'][0]['species']['name'] ??
                            "saya evo3",
                        imageevo1: _dataEvo1['sprites']['other']
                            ['official-artwork']['front_default'],
                        imageevo2: _dataEvo2['sprites']['other']
                            ['official-artwork']['front_default'],
                        imageevo3: _dataEvo3['sprites']['other']
                            ['official-artwork']['front_default'],
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
 
class AboutTab extends StatelessWidget {
  final String ability;
  final double weight;
  final double height;
  final String category;
  final String description;
 
  AboutTab({
    required this.ability,
    required this.weight,
    required this.height,
    required this.category,
    required this.description,
  });
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pokémon are the creatures that inhabit the world of the Pokémon games. They can be caught using Pokéballs and trained by battling with other Pokémon.",
              style: TextStyle(
                  fontSize: 12,
                  color: Color.fromRGBO(0, 0, 0, 0.6),
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                      'Weight', '$weight kg', _getIconForData("Weight")),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoField(
                      'Height', '$height cm', _getIconForData("Height")),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                      'Category', category, _getIconForData("Category")),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoField(
                      'Ability', ability, _getIconForData("Ability")),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
 
  IconData _getIconForData(String dataIcon) {
    if (dataIcon == 'Weight') {
      return Icons.catching_pokemon;
    } else if (dataIcon == 'Height') {
      return Icons.height;
    } else if (dataIcon == 'Category') {
      return Icons.category;
    } else {
      return Icons.catching_pokemon;
    }
  }
 
  Widget _buildInfoField(String label, String value, IconData iconData) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(iconData, size: 14),
            ),
            TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 0.6),
                fontWeight: FontWeight.bold,
              ),
              text: " ${label}",
            ),
          ],
        ),
      ),
      SizedBox(height: 5),
      TextFormField(
        textAlign: TextAlign.center,
        initialValue: value,
        readOnly: true,
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ]);
  }
}
 
class StatusTab extends StatelessWidget {
  final int hp;
  final int attack;
  final int defense;
  final int spattack;
  final int spdefense;
  final int speed;
  // final double height;
  // final String category;
  // final String description;
 
  StatusTab({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spattack,
    required this.spdefense,
    required this.speed,
    // required this.height,
    // required this.category,
    // required this.description,
  });
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatBar('HP', hp),
          _buildStatBar('Attack', attack),
          _buildStatBar('Defense', defense),
          _buildStatBar('Sp. Atk', spattack),
          _buildStatBar('Sp. Def', spdefense),
          _buildStatBar('Speed', speed),
          SizedBox(height: 16),
          Text(
            'Stats determine certain aspects of battles. Each Pokémon has a value for each stat which grows as they gain levels and can be altered momentarily by effects in battles.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            'Weaknesses:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoField('Weakness 1', 'Fire'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInfoField('Weakness 2', 'Psychic'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Type Defenses:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Add your brief type defenses description here...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
 
  Widget _buildStatBar(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$value',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(width: 8),
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 1.0,
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildInfoField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
 
class EvolutionTab extends StatelessWidget {
  final String evo1;
  final String evo2;
  final String evo3;
  final String imageevo1;
  final String imageevo2;
  final String imageevo3;
  // final double height;
  // final String category;
  // final String description;
 
  EvolutionTab({
    required this.evo1,
    required this.evo2,
    required this.evo3,
    required this.imageevo1,
    required this.imageevo2,
    required this.imageevo3,
    // required this.height,
    // required this.category,
    // required this.description,
  });
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEvolution(
              photoUrl: imageevo1,
              title: StringUtils.capitalize(evo1),
            ),
            SizedBox(height: 16),
            _buildEvolution(
              photoUrl: imageevo2,
              title: StringUtils.capitalize(evo2),
            ),
            SizedBox(height: 16),
            _buildEvolution(
              photoUrl: imageevo3,
              title: StringUtils.capitalize(evo3),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildEvolution({
    required String photoUrl,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          photoUrl,
          height: 150, // Sesuaikan tinggi gambar sesuai desain Anda
          width: double.infinity,
          // fit: BoxFit.cover,
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
 