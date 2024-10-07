abstract interface class ApiException implements Exception {
  int get code;
  String get reason;
}

class BadRequest implements ApiException {
  const BadRequest(this.reason) : code = 400;

  @override
  final int code;
  @override
  final String reason;

  @override
  String toString() => '[$code] Bad Request:\nreason: $reason';
}

class Unauthorized implements ApiException {
  const Unauthorized()
      : code = 401,
        reason = 'Unauthorized';

  @override
  final int code;
  @override
  final String reason;

  @override
  String toString() => '[$code] $reason';
}

class NotFound implements ApiException {
  const NotFound()
      : code = 404,
        reason = 'Not Found';

  @override
  final int code;
  @override
  final String reason;

  @override
  String toString() => '[$code] $reason';
}

class TooManyRequests implements ApiException {
  const TooManyRequests()
      : code = 429,
        reason = 'Too Many Requests';

  @override
  final int code;
  @override
  final String reason;

  @override
  String toString() => '[$code] $reason';
}

class ServerException implements ApiException {
  const ServerException(this.code, this.reason);

  @override
  final int code;
  @override
  final String reason;

  @override
  String toString() => '[$code] Server Exception\nReason: $reason';
}
