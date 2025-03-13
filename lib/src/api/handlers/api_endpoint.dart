import 'package:shelfster/shelfster.dart';

final class ApiEndpoint extends ApiHandler {
  ApiEndpoint({
    required super.method,
    required super.name,
    required super.handler,
    super.description,
    super.summary,
    super.middlewares,
    super.bodySchema,
    super.querySchema,
  });

  ApiEndpoint.get({
    required super.name,
    required super.handler,
    super.description,
    super.middlewares,
    super.summary,
    super.bodySchema,
    super.querySchema,
  }) : super(method: HttpMethod.GET);

  ApiEndpoint.post({
    required super.name,
    required super.handler,
    super.description,
    super.summary,
    super.middlewares,
    super.bodySchema,
    super.querySchema,
  }) : super(method: HttpMethod.POST);

  ApiEndpoint.put({
    required super.name,
    required super.handler,
    super.description,
    super.summary,
    super.middlewares,
    super.bodySchema,
    super.querySchema,
  }) : super(method: HttpMethod.PUT);

  ApiEndpoint.patch({
    required super.name,
    required super.handler,
    super.description,
    super.summary,
    super.middlewares,
    super.bodySchema,
    super.querySchema,
  }) : super(method: HttpMethod.PATCH);

  ApiEndpoint.delete({
    required super.name,
    required super.handler,
    super.description,
    super.summary,
    super.middlewares,
    super.bodySchema,
    super.querySchema,
  }) : super(method: HttpMethod.DELETE);

  ApiEndpoint.head({
    required super.name,
    required super.handler,
    super.description,
    super.summary,
    super.middlewares,
    super.bodySchema,
    super.querySchema,
  }) : super(method: HttpMethod.HEAD);

  ApiEndpoint.options({
    required super.name,
    required super.handler,
    super.description,
    super.summary,
    super.middlewares,
    super.bodySchema,
    super.querySchema,
  }) : super(method: HttpMethod.OPTIONS);
}
