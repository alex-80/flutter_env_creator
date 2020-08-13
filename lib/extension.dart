extension StringExtension on String {
  String toFirstUpperCase() {
    return replaceRange(0, 1, this[0].toUpperCase());
  }
}
