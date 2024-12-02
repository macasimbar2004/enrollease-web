class FeesModel {
  final double entrance;
  final double tuition;
  final double misc;
  final double books;
  final double watchman;
  final double aircon;
  final double others;

  FeesModel({
    required this.entrance,
    required this.tuition,
    required this.misc,
    required this.books,
    required this.watchman,
    required this.aircon,
    required this.others,
  });

  double total() {
    return entrance + tuition + misc + books + watchman + aircon + others;
  }

  FeesModel copyWith({
    final double? entrance,
    final double? tuition,
    final double? misc,
    final double? books,
    final double? watchman,
    final double? aircon,
    final double? others,
  }) {
    return FeesModel(
      entrance: entrance ?? this.entrance,
      tuition: tuition ?? this.tuition,
      misc: misc ?? this.misc,
      books: books ?? this.books,
      watchman: watchman ?? this.watchman,
      aircon: aircon ?? this.aircon,
      others: others ?? this.others,
    );
  }

  factory FeesModel.fromMap(Map<String, dynamic> data) {
    return FeesModel(
      entrance: data['entrance'],
      tuition: data['tuition'],
      misc: data['misc'],
      books: data['books'],
      watchman: data['watchman'],
      aircon: data['aircon'],
      others: data['others'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entrance': entrance,
      'tuition': tuition,
      'misc': misc,
      'books': books,
      'watchman': watchman,
      'aircon': aircon,
      'others': others,
    };
  }
}

enum FeeType {
  entrance,
  tuition,
  misc,
  books,
  watchman,
  aircon,
  others,
}

extension FeeStrings on FeeType {
  String firstLetter() => name[0];
  String formalName() => '${name[0].toUpperCase()}${name.substring(1)}';
}
