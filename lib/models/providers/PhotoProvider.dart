import 'dart:convert';
import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/keys.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhotoProvider with ChangeNotifier {
  Map<int, List<String>> _moviesImage = {};
  Map<int, List<String>> _showsImage = {};
  Map<int, List<String>> _peopleProfiles = {};

  Map<int, List<String>> get moviesImages {
    return {..._moviesImage};
  }

  List<String>? getPersonProfiles(int id) {
    return _peopleProfiles[id];
  }

  Map<int, List<String>> get peopleImages {
    return {..._peopleProfiles};
  }

  List<String>? getMovieImages(int id) {
    return _moviesImage[id];
  }

  List<String>? getShowImages(int id) {
    return _showsImage[id];
  }

  Map<int, List<String>> get showsImages {
    return {..._showsImage};
  }

  void fetchImagesFor(int tmdbId, int id, DataType type) async {
    print('tmdb: $tmdbId');
    final url = Uri.parse(
        'https://api.themoviedb.org/3/${type.toShortString()}/$tmdbId/images?api_key=dd5468d7aa41e016a24fa6bce058252d');
    final response = await http.get(url);
    final decodedData = json.decode(response.body);

    final List<String> images = _extractData(decodedData, type);
    if (type == DataType.person) {
      _peopleProfiles[id] = images;
    } else if (type == DataType.movie) {
      _moviesImage[id] = images;
      print(images);
    } else if (type == DataType.tvShow) {
      _showsImage[id] = images;
    }

    notifyListeners();
  }

  List<String> _extractData(dynamic response, DataType type) {
    List<String> _images = [];

    switch (type) {
      case DataType.person:
        final profiles = response['profiles'] ?? {};

        final profile = profiles.isNotEmpty
            ? (profiles[0]['file_path'] == null
                ? keys.defaultImage
                : keys.baseImageURL + '/w185' + profiles[0]['file_path'])
            : keys.defaultImage;

        final backDropProfile = profiles.isNotEmpty
            ? (profiles[0]['file_path'] == null
                ? keys.defaultImage
                : keys.baseImageURL + '/h632' + profiles[0]['file_path'])
            : keys.defaultImage;

        _images.add(profile);
        _images.add(backDropProfile);
        break;

      default:
        final posterImages = response['posters'] != null
            ? (response['posters'].isNotEmpty ? response['posters'][0] : {})
            : {};
        final backdropImages = response['backdrops'] != null
            ? (response['backdrops'].isNotEmpty ? response['backdrops'][0] : {})
            : {};

        final imageURL = posterImages['file_path'] == null
            ? keys.defaultImage
            : keys.baseImageURL + '/w500' + posterImages['file_path'];

        final backDropURL = backdropImages['file_path'] == null
            ? keys.defaultImage
            : keys.baseImageURL + '/w1280' + backdropImages['file_path'];

        _images.add(imageURL);
        _images.add(backDropURL);

        break;
    }

    return _images;
  }
}
