enum FontSize {
  small("Small"),
  medium("Medium"),
  large("Large");

  const FontSize(this.name);
  final String name;

  static FontSize fromString(String name) {
    return values.firstWhere((element) => element.toString() == "FontSize.${name.toLowerCase()}");
  }
}
