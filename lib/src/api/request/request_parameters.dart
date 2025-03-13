part of 'request_context.dart';

class RequestParameters {
  RequestParameters({
    required List<String> uriSegments,
    required String routePattern,
    required this.query,
    required this.body,
  }) {
    path = _parsePathParams(uriSegments, routePattern);
  }

  final Map<String, dynamic> query;
  final Future<Map<String, dynamic>> body;

  late final Map<String, String> path;

  Future<Map<String, dynamic>> call() async {
    return {
      ...query,
      ...(await body),
      ...path,
    };
  }

  Map<String, String> _parsePathParams(
    List<String> uriSegments,
    String routePattern,
  ) {
    final patternSegments = Uri.parse(routePattern).pathSegments;

    if (uriSegments.length != patternSegments.length) return {};

    final params = <String, String>{};
    for (var i = 0; i < patternSegments.length; i++) {
      if (patternSegments[i].startsWith('<') &&
          patternSegments[i].endsWith('>')) {
        final key =
            patternSegments[i].substring(1, patternSegments[i].length - 1);
        params[key] = uriSegments[i];
      }
    }
    return params;
  }
}
