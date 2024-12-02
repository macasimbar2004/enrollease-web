enum Grade {
  nursery,
  k1,
  k2,
  g1,
  g2,
  g3,
  g4,
  g5,
  g6,
}

extension GradeString on Grade {
  String formalString() => '${name[0].toUpperCase()}-${name[1]}';
  String formalLongString() {
    switch (name[0]) {
      case 'n':
        return '${name[0].toUpperCase()}${name.substring(1)}';
      case 'k':
        return '${name[0].toUpperCase()}inder ${name[1]}';
      case 'g':
        return '${name[0].toUpperCase()}rade ${name[1]}';
      default:
        return 'ERROR';
    }
  }
}
