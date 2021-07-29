enum MovieTypes {
  boxoffice,
  genre,
  search,
  trending,
  popular,
  upcoming,
}

extension ParseToStringType on MovieTypes {
  String toShortString() {
    return this.toString().split('.').last;
  }

  String toNormalString() {
    return this.toShortString().toString().replaceAll('_', ' ');
  }
}

enum TvTypes {
  played,
  genre,
  search,
  trending,
  popular,
  recommended,
}

extension ParseToStringTv on TvTypes {
  String toShortString() {
    return this.toString().split('.').last;
  }

  String toNormalString() {
    return this.toShortString().toString().replaceAll('_', ' ');
  }
}

enum DataType {
  movie,
  tvShow,
  person,
}

extension ParseToStringImg on DataType {
  String toShortString() {
    if (this.index == 1) return 'tv';
    return this.toString().split('.').last;
  }
}
