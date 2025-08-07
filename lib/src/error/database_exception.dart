class DatabaseErorr implements Exception {
  final String message;
  final dynamic cause;

  DatabaseErorr(this.message, [this.cause]);
}
