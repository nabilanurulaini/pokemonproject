import 'dart:convert';
 
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'package:pokemon/main.dart';
 
class PokemonDetailPage extends StatefulWidget {
  final String photoUrl;
  final String name;
  final String ability;
  final double weight;
  final double height;
  final String category;
  final String description;
 
  PokemonDetailPage({
    required this.photoUrl,
    required this.name,
    required this.ability,
    required this.weight,
    required this.height,
    required this.category,
    required this.description,
  });
 
  @override
  _PokemonDetailPageState createState() => _PokemonDetailPageState();
}
 
class _PokemonDetailPageState extends State<PokemonDetailPage> {
  PaletteGenerator? _paletteGenerator;
  double _appBarMaxHeight = 350.0;
  double _appBarMinHeight = 0.0;
  late Map<String, dynamic> _pokemonData;
 
  @override
  void initState() {
    super.initState();
    _generatePalette();
    _fetchPokemonData();
  }
 
  Future<void> _generatePalette() async {
    final paletteGenerator =
        await PaletteGenerator.fromImageProvider(NetworkImage(widget.photoUrl));
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
 
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Pokemon Go"),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);// Do something when the back button is pressed.
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
                      bottomLeft: Radius.circular(470),
                      bottomRight: Radius.circular(470),
                    ),
                    color: _paletteGenerator?.dominantColor?.color ??
                        Colors.yellow,
                  ),
                  child: Center(
                      child: Card(
                    color: Colors.white.withOpacity(0.0),
                    elevation: 0,
                    child: CachedNetworkImage(
                      imageUrl: widget.photoUrl,
                      height: 378,
                      maxWidthDiskCache: 326,
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
                            '${_pokemonData["name"] ?? widget.name}',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'sans-serif',
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
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      AboutTab(
                        ability: _pokemonData["abilities"][0]["ability"]
                            ["name"],
                        weight: _pokemonData["weight"],
                        height: _pokemonData["height"],
                        category: _pokemonData["types"][0]["type"]["name"] ??
                            widget.category,
                        description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. ",
                      ),
                      SingleChildScrollView(child: StatusTab(
                        hp: _pokemonData["stats"][0]["base_stat"],
                        attack: _pokemonData["stats"][1]["base_stat"],
                        defense: _pokemonData["stats"][2]["base_stat"],
                        spattack: _pokemonData["stats"][3]["base_stat"],
                        spdefense: _pokemonData["stats"][4]["base_stat"],
                        speed: _pokemonData["stats"][5]["base_stat"],
                      )),
                      SingleChildScrollView(child: EvolutionTab()),
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
            Row(
              children: [
                Expanded(
                  child: _buildInfoField('Weight', '$weight kg'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoField('Height', '$height cm'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoField('Category', category),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoField('Ability', ability),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Description:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Markdown(data: description),
                ),
              ),
            ),
          ],
        ),
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
 
class StatusTab extends StatelessWidget {
  final int hp;
  final int attack;
  final int defense;
  final int spattack;
  final int spdefense;
  final int speed;
 
  StatusTab({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spattack,
    required this.spdefense,
    required this.speed,
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
            'Description:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Add your brief description here...',
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
                valueColor: AlwaysStoppedAnimation(Colors.blue),
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEvolution(
              photoUrl:
                  'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/1f619ed0-b566-4538-8392-bf02ca7a76cd/dck5gnp-4ba6e734-e9ab-415b-9e73-8a3118bd39d1.png/v1/fill/w_600,h_624/001_bulbasaur_png_0__1__by_andersonaas107_dck5gnp-fullview.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9NjI0IiwicGF0aCI6IlwvZlwvMWY2MTllZDAtYjU2Ni00NTM4LTgzOTItYmYwMmNhN2E3NmNkXC9kY2s1Z25wLTRiYTZlNzM0LWU5YWItNDE1Yi05ZTczLThhMzExOGJkMzlkMS5wbmciLCJ3aWR0aCI6Ijw9NjAwIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmltYWdlLm9wZXJhdGlvbnMiXX0.Oss-5PbiSo0aprhpBnsG3RdV9DQplTGb3luUzcaqNug', // Ganti dengan URL foto Ivysaur
              title: 'Ivysaur',
              description: 'The evolved form of Bulbasaur.',
            ),
            SizedBox(height: 16),
            _buildEvolution(
              photoUrl:
                  'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/1f619ed0-b566-4538-8392-bf02ca7a76cd/dck5gnp-4ba6e734-e9ab-415b-9e73-8a3118bd39d1.png/v1/fill/w_600,h_624/001_bulbasaur_png_0__1__by_andersonaas107_dck5gnp-fullview.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9NjI0IiwicGF0aCI6IlwvZlwvMWY2MTllZDAtYjU2Ni00NTM4LTgzOTItYmYwMmNhN2E3NmNkXC9kY2s1Z25wLTRiYTZlNzM0LWU5YWItNDE1Yi05ZTczLThhMzExOGJkMzlkMS5wbmciLCJ3aWR0aCI6Ijw9NjAwIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmltYWdlLm9wZXJhdGlvbnMiXX0.Oss-5PbiSo0aprhpBnsG3RdV9DQplTGb3luUzcaqNug', // Ganti dengan URL foto Venusaur
              title: 'Venusaur',
              description: 'The final evolution of Bulbasaur.',
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildEvolution({
    required String photoUrl,
    required String title,
    required String description,
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
 
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        // colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.yellow),
      ),
      home: PokemonDetailPage(
        photoUrl:
            'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/1f619ed0-b566-4538-8392-bf02ca7a76cd/dck5gnp-4ba6e734-e9ab-415b-9e73-8a3118bd39d1.png/v1/fill/w_600,h_624/001_bulbasaur_png_0__1__by_andersonaas107_dck5gnp-fullview.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9NjI0IiwicGF0aCI6IlwvZlwvMWY2MTllZDAtYjU2Ni00NTM4LTgzOTItYmYwMmNhN2E3NmNkXC9kY2s1Z25wLTRiYTZlNzM0LWU5YWItNDE1Yi05ZTczLThhMzExOGJkMzlkMS5wbmciLCJ3aWR0aCI6Ijw9NjAwIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmltYWdlLm9wZXJhdGlvbnMiXX0.Oss-5PbiSo0aprhpBnsG3RdV9DQplTGb3luUzcaqNug',
        name: 'Pikachu',
        ability: 'Thunderbolt',
        weight: 6.0,
        height: 10.0,
        category: 'Electric',
        description:
            '*Pikachu* is an Electric-type PokÃ©mon known for its lightning abilities. It is one of the most iconic PokÃ©mon and is often associated with the PokÃ©mon franchise.',
      ),
    ),
  );
}
 