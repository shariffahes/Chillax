import 'dart:convert';
import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhotoProvider with ChangeNotifier {
  //images are stored in a map.
  //this makes the get faster when you have id.
  //data might grow big
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

  int requests = 0;

  Future<List<String>> fetchImagesFor(
    int tmdbId,
    int id,
    DataType type, {
    int? season,
    int? seasonId,
    int? episode,
    int? epsId,
  }) async {
    try {
      //data are cached locally
      if (episode != null && showsImages[epsId] != null)
        return showsImages[epsId]!;
      else if (season != null && showsImages[seasonId] != null) {
        return showsImages[seasonId]!;
      } else if (season == null) {
        if (type == DataType.tvShow && showsImages[id] != null)
          return showsImages[id]!;

        if (type == DataType.movie && moviesImages[id] != null)
          return moviesImages[id]!;

        if (type == DataType.person && peopleImages[id] != null)
          return peopleImages[id]!;
      }

      //Data reached here so it is not locally cached yet.
      //Check if it is stored in database which also has a varinish cach

      //otherwise fetch image from tmdb api
      var url = 'https://api.themoviedb.org/3/${type.toShortString()}/$tmdbId';
      if (episode != null) {
        url += '/season/$season/episode/$episode';
      } else if (season != null) {
        url += '/season/$season';
      }
      final URL =
          Uri.parse(url + '/images?api_key=dd5468d7aa41e016a24fa6bce058252d');

      final response = await http.get(URL);
      final decodedData = json.decode(response.body);

      List<String> images =
          _extractData(decodedData, type, isEpisode: epsId != null);

      if (type == DataType.person) {
        _peopleProfiles[id] = images;
      } else if (type == DataType.movie) {
        _moviesImage[id] = images;
      } else if (type == DataType.tvShow) {
        if (epsId != null) {
          if (images[1] == Global.defaultImage) {
            images = await fetchImagesFor(tmdbId, id, type);
          }
          _showsImage[epsId] = images;
        } else if (seasonId != null) {
          if (images[0] == Global.defaultImage) {
            images = await fetchImagesFor(tmdbId, id, type);
          }
          _showsImage[seasonId] = images;
          
        } else {
          _showsImage[id] = images;
        }
      }

      notifyListeners();
      return images;
    } catch (error) {
      print(error);
      return [];
    }
  }

  List<String> _extractData(dynamic response, DataType type,
      {bool isEpisode = false}) {
    List<String> _images = [];
//fill data according to the type in its right map
//each has a default image if the images are not avaible
    switch (type) {
      case DataType.person:
        final profiles = response['profiles'] ?? {};

        final profile = profiles.isNotEmpty
            ? (profiles[0]['file_path'] == null
                ? Global.defaultImage
                : Global.baseImageURL + '/w185' + profiles[0]['file_path'])
            : Global.defaultImage;

        final backDropProfile = profiles.isNotEmpty
            ? (profiles[0]['file_path'] == null
                ? Global.defaultImage
                : Global.baseImageURL + '/h632' + profiles[0]['file_path'])
            : Global.defaultImage;

        _images.add(profile);
        _images.add(backDropProfile);
        break;

      default:
        final posterImages = response['posters'] != null
            ? (response['posters'].isNotEmpty ? response['posters'][0] : {})
            : {};
        final path = isEpisode ? 'stills' : 'backdrops';
        final quality = isEpisode ? '/w300' : '/w1280';
        final backdropImages = response[path] != null
            ? (response[path].isNotEmpty ? response[path][0] : {})
            : {};

        final imageURL = posterImages['file_path'] == null
            ? Global.defaultImage
            : Global.baseImageURL + '/w500' + posterImages['file_path'];

        final backDropURL = backdropImages['file_path'] == null
            ? Global.defaultImage
            : Global.baseImageURL + quality + backdropImages['file_path'];

        _images.add(imageURL);
        _images.add(backDropURL);

        break;
    }

    return _images;
  }
}
