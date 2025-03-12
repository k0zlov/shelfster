import 'package:shelfster/src/api/handlers/api_handler.dart';
import 'package:shelfster/src/api/route/http_method.dart';

class ApiWebsocket extends ApiHandler {
  ApiWebsocket({
    required super.name,
    required super.handler,
    super.description,
    super.querySchema,
  }) : super(method: HttpMethod.GET);
}
