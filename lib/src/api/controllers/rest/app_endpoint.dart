import 'package:shelfster/src/api/controllers/app/api_handler.dart';

final class AppEndpoint extends ApiHandler {
  AppEndpoint({
    required super.method,
    required super.name,
    required super.handler,
    super.description,
    super.middlewares,
    super.bodySchema,
    super.querySchema,
  });
}
