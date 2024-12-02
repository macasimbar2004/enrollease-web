enum Gender {
  male,
  female,
}

extension FormalName on Gender {
  String capName() => '${name[0]}${name.substring(1)}';
}
