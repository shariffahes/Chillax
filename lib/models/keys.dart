import 'dart:convert';

import 'package:http/http.dart' as http;

enum DiscoverTypes { trending, popular, top_rated, now_playing, upcoming }

extension ParseToString on DiscoverTypes {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class keys {
  static const String apiKey = "dd5468d7aa41e016a24fa6bce058252d";
  static String baseImageURL = "https://image.tmdb.org/t/p/w500";
  static String baseURL = "https://api.themoviedb.org/3/";
  void fetchConfig() async {
    final url =
        Uri.parse("https://api.themoviedb.org/3/configuration?api_key=$apiKey");
    final response = await http.get(url);
    final decodedData = json.decode(response.body);
    baseImageURL = decodedData['images']['base_url'];
    print(baseImageURL);
  }
}
