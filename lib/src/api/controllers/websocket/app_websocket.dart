import 'package:shelfster/src/api/controllers/app/api_handler.dart';
import 'package:shelfster/src/api/route/http_method.dart';

class AppWebsocket extends ApiHandler {
  AppWebsocket({
    required super.name,
    required super.handler,
    super.description,
    super.querySchema,
  }) : super(method: HttpMethod.GET);
}
