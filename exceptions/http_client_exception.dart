abstract interface class HttpClientException implements Exception {
  String get message;
}

/// case for socket exception
class NoInternetException implements HttpClientException {
  const NoInternetException() : message = 'no_internet';

  @override
  final String message;

  @override
  String toString() => 'No internet access';
}

class InternetPermissionException implements HttpClientException {
  const InternetPermissionException() : message = 'permission_required';

  @override
  final String message;

  @override
  String toString() => 'Permission to access device internet required';
}

class TimedOut implements HttpClientException {
  const TimedOut.request() : message = 'request_time_out';
  const TimedOut.respose() : message = 'response_time_out';

  @override
  final String message;

  @override
  String toString() => switch (message) {
        'request_time_out' => 'Server took too long to respond to our request',
        _ => 'Server took too long to send a response message'
      };
}
