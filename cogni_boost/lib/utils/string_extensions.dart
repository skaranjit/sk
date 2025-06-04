// cogni_boost/lib/utils/string_extensions.dart
extension StringExtension on String {
  String capitalizeWords() {
    if (this.isEmpty) return "";
    // Split by capital letters to separate words, then capitalize first letter of each
    // e.g. "sequenceRecall" -> "Sequence Recall"
    String spaced = this.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').trim();
    if (spaced.isEmpty) return this.toUpperCase(); // Handle case like "a" -> "A" or if no caps found
    return spaced.split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
  }
}
