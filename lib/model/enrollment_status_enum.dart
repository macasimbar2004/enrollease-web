enum EnrollmentStatus {
  approved,
  disapproved,
  pending,
}

extension StringName on EnrollmentStatus {
  String formalName() => '${name[0].toUpperCase()}${name.substring(1)}';
  String asVerb() => '${name[0]}${name.substring(1, name.length - 1)}';
  String asVerbUpper() => '${name[0].toUpperCase()}${name.substring(1, name.length - 1)}';
}
