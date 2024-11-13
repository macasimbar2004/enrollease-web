// identification_generator.dart
class IdentificationGenerator {
  int _lastIncrement = 0; // Keeps track of the last increment value

  String generateNewId() {
    // Base prefix, e.g., "SDA" and last two digits of the current year
    final prefix = 'SDA${DateTime.now().year % 100}-';

    // Convert the increment to a 6-digit number with leading zeros
    final incrementalNumber = _lastIncrement.toString().padLeft(6, '0');

    // Concatenate prefix and incremental number to form the new ID
    final newId = '$prefix$incrementalNumber';

    // Increment the counter for the next ID
    _lastIncrement++;

    return newId;
  }

  // Optionally, reset the generator or set a specific start increment
  void resetIncrement([int start = 0]) {
    _lastIncrement = start;
  }
}
