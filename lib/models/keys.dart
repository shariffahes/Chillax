import 'dart:convert';

import 'package:http/http.dart' as http;

class keys {
  static const String apiKey = "dd5468d7aa41e016a24fa6bce058252d";
  static String baseURL = "https://image.tmdb.org/t/p/w500";
  static const List<String> discover = [
    'popular',
    'now_playing',
    'top_rated',
    'upcoming',
  ];
  void fetchConfig() async {
    final url =
        Uri.parse("https://api.themoviedb.org/3/configuration?api_key=$apiKey");
    final response = await http.get(url);
    final decodedData = json.decode(response.body);
    baseURL = decodedData['images']['base_url'];
    print(baseURL);
  }
}
