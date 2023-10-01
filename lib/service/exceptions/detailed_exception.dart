class DetailedException implements Exception {
  String title;
  String? message;
  DetailedException(this.title, this.message);
}