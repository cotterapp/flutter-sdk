class RefreshTokenNotExistException implements Exception {
  final String message;

  const  RefreshTokenNotExistException({this.message=''});

  String toString() => 'RefreshTokenNotExistException: $message';
}