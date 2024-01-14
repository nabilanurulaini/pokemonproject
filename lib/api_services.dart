import 'dart:convert';
import 'package:http/http.dart' as http;

 class FetchUser {
  var data = [];

  String fetchurl = "https://pokeapi.co/api/v2/pokemon";
    getUserList() async {
      var url = Uri.parse(fetchurl);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        data = json.decode(response.body);
      }
    }
  
   
 } 