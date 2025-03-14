import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelfster/src/api/request/request_context.dart';
import 'package:shelfster/src/api/request/request_validation.dart';
import 'package:shelfster/src/api/route/http_method.dart';

typedef AppHandler = FutureOr<Response> Function(RequestContext context);

abstract class ApiHandler {
  ApiHandler({
    required this.method,
    required this.name,
    required AppHandler handler,
    this.description,
    this.summary,
    this.middlewares = const [],
    this.bodySchema = const {},
    this.querySchema = const {},
  }) : _handler = handler;

  final String name;
  final String? description;
  final String? summary;
  final List<Object> middlewares;
  final AppHandler _handler;
  final HttpMethod method;

  final Set<Field<Object>> bodySchema;
  final Set<Field<Object>> querySchema;

  Handler call() {
    return (Request request) async {
      final context = RequestContext(request, name);
      await validateRequest(
        context: context,
        body: bodySchema,
        query: querySchema,
      );
      return await _handler(context);
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiHandler &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          method == other.method;

  @override
  int get hashCode => name.hashCode ^ method.hashCode;
}
