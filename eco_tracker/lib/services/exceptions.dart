class ReauthenticationRequiredException implements Exception {
  final String message;

  ReauthenticationRequiredException(this.message);

  @override
  String toString() => message;
}
