class UserNotLoggedInException implements Exception {
  final String message;

  const UserNotLoggedInException({this.message = ''});

  String toString() => 'UserNotLoggedInException: $message';
}
