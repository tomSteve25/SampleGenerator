

enum Colour {
  black("Black"),
  white("White"),
  red("Red"),
  blue("Blue"),
  green("Green");

  const Colour(this.name);
  final String name;

  static Colour fromString(String name) {
    return values.firstWhere((element) => element.toString() == "Colour.${name.toLowerCase()}");
  }
}


