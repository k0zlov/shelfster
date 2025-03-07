enum HttpMethod {
  GET('GET'),
  POST('POST'),
  PUT('PUT'),
  DELETE('DELETE'),
  PATCH('PATCH'),
  HEAD('HEAD'),
  OPTIONS('OPTIONS'),
  CONNECT('CONNECT'),
  TRACE('TRACE');

  final String name;

  const HttpMethod(this.name);

  @override
  String toString() => name;
}
