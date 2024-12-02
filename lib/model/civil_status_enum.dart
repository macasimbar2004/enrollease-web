enum CivilStatus {
  single,
  married,
}

extension CivilStatusString on CivilStatus {
  String formalName() => '${name[0].toUpperCase()}${name.substring(1)}';
}
